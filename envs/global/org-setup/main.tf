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


module "bootstrap_execution_role" {
  for_each = toset(flatten(values(module.service_catalog_accounts[*].account_ids)))

  source = "../../../modules/bootstrap_execution_role"

  target_account_id  = each.value
  codebuild_role_arn = "arn:aws:iam::918116814056:role/codebuild-role"
  region             = "us-east-1"
}