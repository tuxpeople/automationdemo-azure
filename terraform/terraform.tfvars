prefix = "tedops"

resource_group_name = "rg_${var.prefix}"
location            = "eastus2"

domainname = "automationdemo-${var.prefix}"

instances             = ["vm-k3s-1", "vm-k3s-2", "vm-k3s-3"]

tags = {
  environment = "production"
}