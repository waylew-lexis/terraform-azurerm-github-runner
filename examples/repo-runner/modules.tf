data "azurerm_subscription" "current" {
}


resource "random_string" "random" {
  length  = 12
  upper   = false
  special = false
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/Azure-Terraform/terraform-azurerm-virtual-network/tree/master/example/bastion"
  location            = "eastus2"
  environment         = "sandbox"
  product_name        = "waylew"
  business_unit       = "infra"
  product_group       = "contoso"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v5.0.0"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.0.0/24"]

  subnets = {
    "iaas-private" = {
      cidrs                   = ["10.1.0.0/24"]
      allow_vnet_inbound      = true
      allow_vnet_outbound     = true
      allow_internet_outbound = true
      service_endpoints       = ["Microsoft.Storage"]
    }
  }
}

module "storage_account" {
  source              = "github.com/Azure-Terraform/terraform-azurerm-storage-account.git?ref=v0.12.1"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = module.metadata.tags
  account_kind        = "StorageV2"
  replication_type    = "LRS"
  account_tier        = "Standard"
  # Serial Console requires shared access key and does not work with firewall rules enabled.
  shared_access_key_enabled = true
  default_network_rule      = "Allow"
  traffic_bypass            = ["AzureServices", "Logging"]
  service_endpoints = {
    "iaas-outbound" = module.virtual_network.subnet["iaas-private"].id
  }
}
