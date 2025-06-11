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
  for_each = { for account in flatten([for sc in module.service_catalog_accounts : sc.account_ids]) : account => account }

  providers = {
    aws = aws.cross_account
  }

  cross_account_role_name = "AWSControlTowerExecution"
  trusted_account_id      = var.management_account_id
  organization_id         = var.organization_id
  policy_arn              = "arn:aws:iam::aws:policy/AdministratorAccess"
  region                  = var.home_region
}
