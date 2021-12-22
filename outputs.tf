# Outputs
output "computer_name" {
  description = "The virtual machine and github runner name"
  value = coalesce(one(azurerm_linux_virtual_machine.vm.*.computer_name),
  one(azurerm_windows_virtual_machine.vm.*.computer_name))
}

output "private_ip" {
  description = "Private IP Address of the virtual machine"
  value = coalesce(one(azurerm_linux_virtual_machine.vm.*.private_ip_address),
  one(azurerm_windows_virtual_machine.vm.*.private_ip_address))
}

output "principal_id" {
  description = "The principal id of the managed identity"
  value       = var.runner_os == "linux" ? azurerm_linux_virtual_machine.vm.0.identity.0.principal_id : azurerm_windows_virtual_machine.vm.0.identity.0.principal_id
}
