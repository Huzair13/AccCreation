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

# module "security_account" {
#   source        = "../../../modules/account"
#   name          = "Security"
#   email         = var.security_email
#   parent_ou_id  = module.org.ou_ids["Security"]
# }

# module "test_account" {
#   source      = "../../../modules/account"
#   name        = "TestAccount"
#   email       = var.test_email
#   parent_ou_id = module.org.ou_ids["TestAccount"]
# }

# module "shared_account" {
#   source        = "../../../modules/account"
#   name          = "SharedServices"
#   email         = var.shared_email
#   parent_ou_id  = module.org.ou_ids["SharedServices"]
# }

# module "scp_baseline" {
#   source      = "../../../modules/scps"
#   name        = "BaselineDeny"
#   description = "Deny everything except a few services"
#   content     = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Deny",
#       "Action": "*",
#       "Resource": "*",
#       "Condition": {
#         "StringNotEquals": {
#           "aws:RequestedRegion": [
#             "us-east-1"
#           ]
#         }
#       }
#     }
#   ]
# }
# EOF
#   targets = {
#     SecurityOU = module.org.ou_ids["Security"]
#     # SharedOU   = module.org.ou_ids["SharedServices"]
#   }
# }

# module "lambda_enroll_account" {
#   source       = "../../../modules/lambda"
#   function_name = "MyEnrollLambda"
#   source_path  = "../../../lambda/enroll_account/lambda_function.py"
# }

# resource "aws_lambda_invocation" "enroll_shared_account" {
#   depends_on    = [module.shared_account, module.lambda_enroll_account]
#   function_name = module.lambda_enroll_account.function_name
#   input = jsonencode({
#     account_id    = module.shared_account.account_id
#     contact_email = var.shared_email
#     ou_id         = module.org.ou_ids["SharedServices"]
#   })
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
