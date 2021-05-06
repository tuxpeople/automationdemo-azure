output "server1" {
  value = azurerm_linux_virtual_machine.k3s.1.private_ip_address
}

output "server2" {
  value = azurerm_linux_virtual_machine.k3s.2.private_ip_address
}

output "server3" {
  value = azurerm_linux_virtual_machine.k3s.3.private_ip_address
}

output "web" {
  value = azurerm_public_ip.pip.fqdn
}

output "bastion" {
  value = azurerm_public_ip.pip-bastion.fqdn
}