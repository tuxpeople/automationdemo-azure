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

variable "tags" {
  type = map(any)
}

variable "vnet_name" {
  description = "Name of the virtual network to create"
  default     = "tfvnet"
}

variable "vm_name" {
  description = "Name of the virtual machine to create"
  default     = "tfvm"
}