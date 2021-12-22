
provider "azurerm" {
  features {}
}

module "runner" {
  source = "../../"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name              = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.virtual_network.subnets["iaas-private"].id

  runner_scope     = "repo"
  runner_name      = "my-linux-runner"
  github_repo_name = var.repo_name
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.runner_token

  enable_boot_diagnostics = true

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
