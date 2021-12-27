
variable "name" {
  description = "The name of the created resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "win_computer_name" {
  description = "The windows computer name."
  type        = string
  default     = null
}

variable "enable_boot_diagnostics" {
  description = "Whether to enable boot diagnostics on the runner which enables the serial console"
  type        = bool
  default     = false
}

variable "diagnostics_storage_account_uri" {
  description = "The Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
  type        = string
  default     = null
}

variable "admin_username" {
  description = "the admin user"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "the admin password. leave blank to assign a random password"
  type        = string
  sensitive   = true
  default     = null
}

variable "subnet_id" {
  description = "Virtual network subnet ID"
  type        = string
}

# VM Resources
variable "virtual_machine_size" {
  description = "Virtual machine instance size"
  type        = string
  default     = "Standard_D2s_v4"
}

variable "custom_ubuntu_image_id" {
  description = "the custom vm image to use"
  type        = string
  default     = null
}

variable "ubuntu_source_image_reference" {
  description = "The linux Ubuntu publisher image to use."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

# VM Identity
variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine. Possible values are SystemAssigned (where Azure will generate a Service Principal for you), UserAssigned (where you can specify the Service Principal ID's)."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = (contains(["systemassigned", "userassigned"], lower(var.identity_type)))
    error_message = "The identity type can only be \"UserAssigned\" or \"SystemAssigned\"."
  }
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM"
  type        = list(string)
  default     = []
}

# GitHub
variable "github_runner_token" {
  description = "Github access token to use to create runner"
  type        = string
  sensitive   = true
}

variable "github_repo_name" {
  description = "Github repository where the runner should register"
  type        = string
  default     = null
}

variable "github_org_name" {
  description = "The GitHub organization."
  type        = string
}

variable "runner_os" {
  description = "Whether to create the vm resource"
  type        = string
  default     = "linux"

  validation {
    condition     = (contains(["linux", "windows"], lower(var.runner_os)))
    error_message = "The runner os can only be \"linux\" or \"windows\"."
  }
}

variable "runner_labels" {
  description = "list of labels to associate to the runner"
  type        = list(string)
}

variable "runner_group" {
  description = "the group this runner belongs to. required if runner-scope is \"org\" "
  type        = string
  default     = ""
}

variable "runner_scope" {
  description = "The scope of the runner. Choices are \"Org\" or \"Repo\". "
  type        = string
  default     = "repo"

  validation {
    condition     = contains(["org", "repo"], lower(var.runner_scope))
    error_message = "The runner scope can only be \"org\" or \"repo\"."
  }
}
