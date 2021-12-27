resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_windows_virtual_machine" "vm" {
  count = var.runner_os == "windows" ? 1 : 0

  name                  = local.name
  computer_name         = var.win_computer_name == null ? local.name : var.win_computer_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
  size                  = var.virtual_machine_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password == null ? random_password.password.result : var.admin_password
  network_interface_ids = [azurerm_network_interface.dynamic.id]

  ## will force vm to be re-created
  custom_data = base64encode(timestamp())

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? ["enabled"] : []
    content {
      storage_account_uri = var.diagnostics_storage_account_uri
    }
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}

locals {
  scriptName = "startup.ps1"

  templateFile = base64encode(templatefile("${path.module}/scripts/${local.scriptName}", {
    runner_token = var.github_runner_token
    runner_url   = "https://github.com/${var.github_org_name}/${var.github_repo_name}"
    password     = random_password.password.result
    user         = var.admin_username
    labels       = lower(join(",", var.runner_labels))
  }))

  powershell_cmd = "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.templateFile}')) | Out-File -filepath ${local.scriptName}\" && powershell -ExecutionPolicy Unrestricted -File ${local.scriptName}"

  commandToExecute = jsonencode({
    commandToExecute = local.powershell_cmd
  })
}

resource "azurerm_virtual_machine_extension" "ext" {
  count = var.runner_os == "windows" ? 1 : 0

  name = "customscript"

  virtual_machine_id = azurerm_windows_virtual_machine.vm[count.index].id

  # windows
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = local.commandToExecute
}
