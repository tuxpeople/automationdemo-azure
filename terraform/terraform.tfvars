prefix = "tedops"

resource_group_name = "rg_${var.prefix}"
location            = "eastus2"

domainname = "automationdemo-${var.prefix}"

tags = {
  environment = "production"
}