output "provisioned_products" {
  value       = aws_servicecatalog_provisioned_product.new_accounts
  description = "The provisioned products created by this module"
}

output "account_ids" {
  value = [
    for product in aws_servicecatalog_provisioned_product.new_accounts : [
      for output in product.outputs : output.value if output.key == "AccountId"
    ][0]
  ]
  description = "The IDs of the accounts created by this module"
}

output "account_configs" {
  value = {
    for i, product in aws_servicecatalog_provisioned_product.new_accounts : 
    [for output in product.outputs : output.value if output.key == "AccountId"][0] => {
      share_tgw = var.new_accounts[i].share_tgw
      share_subnets = var.new_accounts[i].share_subnets
    }
  }
  description = "The account IDs with their TGW and subnet sharing preferences"
}
