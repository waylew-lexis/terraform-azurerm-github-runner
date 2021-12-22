resource "random_string" "random" {
  length  = 24
  special = false
  upper   = false
}


resource "azurerm_storage_account" "storage" {
  count = var.enable_diagnostics ? 1 : 0

  name                     = random_string.random.result
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  ## currently, serial console does not work with firewall rules enforced 'Deny'
  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = [var.subnet_id]
    bypass                     = ["Logging", "Metrics", "AzureServices"]
  }

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }
}
