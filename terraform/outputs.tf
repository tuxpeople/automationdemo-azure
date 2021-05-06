output "k3sservers" {
  value = ["${azurerm_linux_virtual_machine.k3s.*.private_ip_address}"]
}

output "web" {
  value = azurerm_public_ip.pip.fqdn
}

output "bastion" {
  value = azurerm_public_ip.pip-bastion.fqdn
}