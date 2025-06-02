output "provisioned_products" {
  value = {
    for ou, module in module.service_catalog_accounts : ou => module.provisioned_products
  }
  description = "The provisioned products created by the service catalog accounts module, organized by OU"
}
