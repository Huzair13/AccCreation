# module "org" {
#   source = "../../../modules/organizations"
#   ous = {
#     Security       = "ROOT"
#     # SharedServices = "ROOT"
#     # Sandbox        = "ROOT"
#     # TestAccount    = "ROOT"
#     # Production     = "ROOT"
#     # Dev            = "ROOT"
#   }
# }



module "service_catalog_accounts" {
  source   = "../../../modules/service_catalog_account"
  count    = length(var.ou_configs)

  new_accounts = [
    for account in var.ou_configs[count.index].accounts : {
      AccountName                = account.AccountName
      AccountEmail               = account.AccountEmail
      ManagedOrganizationalUnit  = var.ou_configs[count.index].ManagedOrganizationalUnit
    }
  ]
  account_region              = var.ou_configs[count.index].AccountRegion
  product_id                  = var.product_id
  provisioning_artifact_name  = var.provisioning_artifact_name
}

module "cross_account_role" {
  source = "../../../modules/bootstrap_execution_role"
  for_each = toset(local.all_account_ids)

  providers = {
    aws = aws.cross_account
  }

  cross_account_role_name = "CrossAccountExecutionRole-${each.key}"
  trusted_account_id      = var.trusted_account_id
  organization_id         = var.organization_id
  policy_arn              = var.cross_account_policy_arn
  region                  = var.home_region
}
