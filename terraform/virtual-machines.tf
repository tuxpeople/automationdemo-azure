resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}

resource "azurerm_linux_virtual_machine" "k3s" {
  name                  = "${var.vm_name}-vm-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"] #["${azurerm_network_interface.main.id}"]
  availability_set_id   = azurerm_availability_set.avset.id
  size                  = "Standard_B2s"
  count                 = "3"
  admin_username        = "adminuser"
  custom_data           = filebase64("../scripts/master-cloud-init.txt")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("id_rsa.pub")
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