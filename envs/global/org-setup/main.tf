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
  source = "../../../modules/service_catalog_account"
  count  = length(var.ou_configs)

  new_accounts = [
    for account in var.ou_configs[count.index].accounts : {
      AccountName               = account.AccountName
      AccountEmail              = account.AccountEmail
      ManagedOrganizationalUnit = var.ou_configs[count.index].ManagedOrganizationalUnit
      share_tgw                 = account.share_tgw
      share_subnets             = account.share_subnets
    }
  ]
  account_region             = var.ou_configs[count.index].AccountRegion
  product_id                 = var.product_id
  provisioning_artifact_name = var.provisioning_artifact_name
  create_ssm_parameter       = count.index == 0 ? true : false
}
