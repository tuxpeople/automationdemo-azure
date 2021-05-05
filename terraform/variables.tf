variable "prefix" {
  type    = string
  default = "myprefix"
}

variable "resource_group_name" {
  type    = string
  default = "myrg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "domainname" {
  type    = string
  default = "mydomain"
}

variable "instances" {
  type = list(string)
}

variable "tags" {
  type = list(object({
    environment = string
  }))
}
