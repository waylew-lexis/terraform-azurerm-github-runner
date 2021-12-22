# GitHub Runner Azure Virtual Machine
This Terraform module will create a self-hosted GitHub runner hosted on an Azure VM. The module will configure a Managed Identity for the VM.
See [examples](https://github.com/LexisNexis-RBA/terraform-azure-vm-github-runner/tree/main/examples) for recommended terraform implementation.


<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.72, < 3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 2.72, < 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.dynamic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_virtual_machine_extension.ext](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [template_file.script](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | the admin password. leave blank to assign a random password | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | the admin user | `string` | `"adminuser"` | no |
| <a name="input_custom_ubuntu_image_id"></a> [custom\_ubuntu\_image\_id](#input\_custom\_ubuntu\_image\_id) | the custom vm image to use | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to enable boot diagnostics on the runner which enables the serial console | `bool` | `false` | no |
| <a name="input_github_org_name"></a> [github\_org\_name](#input\_github\_org\_name) | GitHub Orginisation | `string` | `"LexisNexis-RBA"` | no |
| <a name="input_github_repo_name"></a> [github\_repo\_name](#input\_github\_repo\_name) | Github repository where the runner should register | `string` | `""` | no |
| <a name="input_github_runner_token"></a> [github\_runner\_token](#input\_github\_runner\_token) | Github access token to use to create runner | `string` | n/a | yes |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. Possible values are SystemAssigned (where Azure will generate a Service Principal for you), UserAssigned (where you can specify the Service Principal ID's). | `string` | `"SystemAssigned"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_names"></a> [names](#input\_names) | Names to be applied to resources | `map(string)` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_runner_group"></a> [runner\_group](#input\_runner\_group) | the group this runner belongs to. required if runner-scope is "org" | `string` | `""` | no |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels) | list of labels to associate to the runner | `list(string)` | <pre>[<br>  "azure"<br>]</pre> | no |
| <a name="input_runner_name"></a> [runner\_name](#input\_runner\_name) | Optional name of runner to overwrite module generated name | `string` | n/a | yes |
| <a name="input_runner_os"></a> [runner\_os](#input\_runner\_os) | Whether to create the vm resource | `string` | `"linux"` | no |
| <a name="input_runner_scope"></a> [runner\_scope](#input\_runner\_scope) | The scope of the runner. Choices are "Org" or "Repo". | `string` | `"repo"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Virtual network subnet ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | n/a | yes |
| <a name="input_virtual_machine_size"></a> [virtual\_machine\_size](#input\_virtual\_machine\_size) | Virtual machine instance size | `string` | `"Standard_D2s_v4"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_computer_name"></a> [computer\_name](#output\_computer\_name) | The virtual machine and github runner name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal id of the managed identity |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP Address of the virtual machine |

<!--- END_TF_DOCS --->
