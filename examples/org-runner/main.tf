
provider "azurerm" {
  features {}
}

## see link below for requesting a github app and runner group for org scoped runners
## https://reedelsevier.sharepoint.com/sites/OG-EnterpriseToolsOnlineCommunity/SitePages/Github-Process-%26-Automation.aspx
module "runner" {
  source = "../../"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.virtual_network.subnets["iaas-private"].id

  custom_ubuntu_image_id = data.azurerm_shared_image.shared.id

  runner_scope = "org"
  runner_name  = "my-org-runner"
  runner_group = "assigned-runner-group"
  ## a github app token is needed for org scoped runners.
  github_runner_token = var.runner_token

  runner_labels = ["azure", "dev"]
}

data "azurerm_subscription" "current" {

}

## grant runner mi owner rights to sub
resource "azurerm_role_assignment" "sub" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = module.runner.principal_id

  depends_on = [module.runner]
}

variable "runner_token" {
  description = "github runner token"
  default     = "some-token"
  sensitive   = true
}
