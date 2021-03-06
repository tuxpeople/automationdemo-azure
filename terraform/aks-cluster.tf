resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name                = "default"
    node_count          = 2
    vm_size             = "Standard_B2s"
    type                = "VirtualMachineScaleSets"
    availability_zones  = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    os_disk_size_gb     = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
}

resource "local_file" "kube_config" {
  content              = azurerm_kubernetes_cluster.default.kube_config_raw
  filename             = "../kube_config"
  directory_permission = "0750"
  file_permission      = "0750"
}