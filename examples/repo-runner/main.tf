
provider "azurerm" {
  alias           = "image_gallery"
  subscription_id = "ed5e2254-5d87-4255-b70e-1b5eba509f73"
  features {}
}

data "azurerm_shared_image" "shared" {
  provider            = azurerm.image_gallery
  name                = "ubuntu20"
  gallery_name        = "ubuntu20"
  resource_group_name = "app-imagegallery-prod-eastus2"
}

module "runner" {
  #source = "github.com/LexisNexis-RBA/terraform-azure-vm-github-runner.git"
  source = "../../"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id = module.virtual_network.subnets["iaas-private"].id

  custom_ubuntu_image_id = data.azurerm_shared_image.shared.id


  runner_scope     = "repo"
  runner_name      = "my-linux-runner"
  github_repo_name = var.repo_name
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.runner_token

  enable_diagnostics = true

  runner_labels = ["azure", "dev"]
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
  type        = string
  sensitive   = true
}

variable "repo_name" {
  description = "the name of the rba repository the runner will be associated to"
  type        = string
}

# Outputs
output "outputs" {
  value = module.runner
}
