source "azure-arm" "isucon" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  image_offer     = var.image_offer
  image_publisher = var.image_publisher
  image_sku       = var.image_sku
  managed_image_name                               = var.managed_image_name
  managed_image_resource_group_name                = var.managed_image_resource_group_name
  build_resource_group_name                        = var.managed_image_resource_group_name
  os_type                                          = var.os_type
  subscription_id                                  = var.subscription_id
  tenant_id                                        = var.tenant_id
  vm_size                                          = var.vm_size
  shared_gallery_image_version_exclude_from_latest = var.shared_gallery_image_version_exclude_from_latest
  shared_image_gallery_destination {
    gallery_name        = var.gallery_name
    image_name          = var.image_name
    image_version       = var.image_version
    replication_regions = var.replication_regions
    resource_group      = var.resource_group
    subscription        = var.subscription_id
  }
}
