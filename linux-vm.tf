resource "tls_private_key" "ssh_key" {
  count = var.runner_os == "linux" ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "linux_script" {
  template = file("${path.module}/scripts/startup.sh")
  vars = {
    github_repo   = var.github_repo_name
    github_org    = var.github_org_name
    runner_token  = var.github_runner_token
    runner_name   = local.name
    runner_group  = var.runner_group
    runner_labels = lower(join(",", var.runner_labels))
    runner_scope  = lower(var.runner_scope)
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.runner_os == "linux" ? 1 : 0
  name                            = local.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tags                            = var.tags
  size                            = var.virtual_machine_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.dynamic.id]
  source_image_id                 = var.custom_ubuntu_image_id

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key[count.index].public_key_openssh
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? ["enabled"] : []
    content {
      storage_account_uri = var.diagnostics_storage_account_uri
    }
  }

  custom_data = base64encode(data.template_file.linux_script.rendered)

  dynamic "source_image_reference" {
    for_each = var.custom_ubuntu_image_id == null ? ["no-custom-image"] : []

    content {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
  }

  os_disk {
    caching                   = "ReadWrite"
    storage_account_type      = "StandardSSD_LRS"
    write_accelerator_enabled = false
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}
