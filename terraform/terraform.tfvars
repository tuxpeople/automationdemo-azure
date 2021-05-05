prefix                = "tedops"

resource_group_name = "rg_${var.prefix}"
location            = "eastus2"

domainname = "automationdemo-${var.prefix}"

instances             = ["vm-k3s-1", "vm-k3s-2", "vm-k3s-3"]
nb_disks_per_instance = 1

tags = {
  environment = "production"
}