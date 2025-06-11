output "provisioned_products" {
  value       = aws_servicecatalog_provisioned_product.new_accounts
  description = "The provisioned products created by this module"
}

output "account_ids" {
  value = [
    for account in aws_organizations_account.this : account.id
  ]
}
