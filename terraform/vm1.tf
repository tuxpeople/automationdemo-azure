resource "azurerm_network_interface" "nic1" {
  name                = "${var.vm_name}-1-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = "azurerm_network_interface.nic1.id"
  network_security_group_id = azurerm_network_security_group.k3sserver.id
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                  = "${var.vm_name}-vm-1"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2s"
  network_interface_ids = azurerm_network_interface.nic1.id
  admin_username        = "adminuser"
  custom_data           = base64encode(data.template_file.master-cloud-init.rendered)

  os_disk {
    name                 = "osdisk-1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  resource "azurerm_managed_disk" "managed_disk-1" {
    name                 = datadisk-1
    location             = azurerm_resource_group.rg.location
    resource_group_name  = azurerm_resource_group.rg.name
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
    disk_size_gb         = 10
    tags                 = var.tags
  }

  resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach" {
    managed_disk_id    = azurerm_managed_disk.managed_disk-1.id
    virtual_machine_id = azurerm_linux_virtual_machine.vm1.id
    lun                = 10
    caching            = "ReadWrite"
  }

  tags = var.tags
}