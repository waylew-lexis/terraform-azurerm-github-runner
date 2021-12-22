
module "runner" {
  #source = "github.com/LexisNexis-RBA/terraform-azure-vm-github-runner.git"
  source = "../../"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.virtual_network.subnets["iaas-private"].id

  runner_os = "linux"
  runner_scope     = "repo"
  runner_name      = "my-runner"
  github_repo_name = "terraform-azure-vm-github-runner"

  ## get repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.runner_token

  runner_labels = ["azure", "dev"]
}

## grant runner mi owner rights to sub
resource "azurerm_role_assignment" "sub" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = module.runner.principal_id

  depends_on = [module.runner]
}

variable "runner_token" {
  description = "github runner token"
  default     = "some-token"
  sensitive   = true
}

# Outputs
output "outputs" {
  value = module.runner
}
