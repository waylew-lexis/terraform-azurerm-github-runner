resource "tls_private_key" "ssh_key" {
  count = var.runner_os == "linux" ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.runner_os == "linux" ? 1 : 0

  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  size = var.virtual_machine_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key[count.index].public_key_openssh
  }

  network_interface_ids = [azurerm_network_interface.dynamic.id]

  source_image_id = var.custom_ubuntu_image_id

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? one(azurerm_storage_account.storage.*.primary_blob_endpoint) : null
  }

  custom_data = base64encode(data.template_file.script.rendered)

  dynamic "source_image_reference" {
    for_each = var.custom_ubuntu_image_id == null ? ["dummy"] : []

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
