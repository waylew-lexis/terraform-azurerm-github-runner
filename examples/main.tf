
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

module "runner" {
  source              = "../"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = var.name
  tags                = module.metadata.tags

  subnet_id = module.virtual_network.subnets["iaas-private"].id

  runner_scope     = "repo"
  runner_os        = "linux"
  github_repo_name = var.gh_repo_name
  github_org_name  = var.gh_org_name
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.gh_runner_token

  enable_boot_diagnostics         = true
  diagnostics_storage_account_uri = module.storage_account.primary_blob_endpoint

  runner_labels = ["azure", "dev"]
}

## grant runner access to api.
resource "azurerm_role_assignment" "sub" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = module.runner.principal_id

  depends_on = [module.runner]
}
