resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "tedops-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  domain_name_label   = "automationdemo-tedops"
  reverse_fqdn        = "automationdemo-tedops.${azurerm_resource_group.rg.location}.cloudapp.azure.com."
}

resource "azurerm_lb" "lb" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_nat_rule" "http" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "publicIPAddress"
}

resource "azurerm_lb_nat_rule" "https" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "publicIPAddress"
}

resource "azurerm_lb_nat_rule" "api" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "api"
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "publicIPAddress"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  count               = "3"

  ip_configuration {
    name                          = "testconfiguration${count.index}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "dynamic"
  }
}

#resource "azurerm_network_interface_backend_address_pool_association" "association" {
#  network_interface_id    = "azurerm_network_interface.main.${count.index}.id"
#  ip_configuration_name   = "testconfiguration${count.index}"
#  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
#  count                   = "3"
#}