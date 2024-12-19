variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "subscription_id" {
  description = "Your Azure Subscription ID (required for the shared_image_gallery_destination block)."
  type        = string
  sensitive   = true
}

variable "gallery_name" {
  description = "The name of the Shared Image Gallery."
  type        = string
}

variable "image_name" {
  description = "The name of the image to be created."
  type        = string
}

variable "image_version" {
  description = "The version of the image to be created."
  type        = string
}

variable "replication_regions" {
  description = "A list of regions where the image will be replicated."
  type        = list(string)
}

variable "resource_group" {
  description = "The name of the resource group where the Shared Image Gallery will be created."
  type        = string
}

variable "shared_gallery_image_version_exclude_from_latest" {
  default = null
}

variable "owner" {
  description = "Value for the owner tag."
  type        = string
  default     = "ubuntu-24_04-lts" # Ubuntu 24.04 LTS
}

variable "image_publisher" {
  type    = string
  default = "canonical"
}
variable "image_sku" {
  type    = string
  default = "server"
}

variable "location" {
  type    = string
  default = "japaneast"
}
variable "managed_image_name" {
  type    = string
  default = "isucon-14-ubuntu-24-04-2-lts"
}

variable "managed_image_resource_group_name" {
  description = "An existing Azure Resource Group where the build will take place and images will be stored."
  type        = string
}
variable "os_type" {
  type    = string
  default = "Linux"
}
variable "vm_size" {
  type    = string
  default = "Standard_D2s_v4"
}

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  type        = string
  default     = "gpsjptech"
}

