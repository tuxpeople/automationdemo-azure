resource "azurerm_linux_virtual_machine" "test" {
  name                  = "${var.vm_name}-vm-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"] #["${azurerm_network_interface.main.id}"]
  size                  = "Standard_B2s"
  count                 = "3"
  admin_username        = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/github/workspace/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = var.tags
}