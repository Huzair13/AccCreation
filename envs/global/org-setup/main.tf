module "org" {
  source = "../../../modules/organizations"
  ous = {
    Security       = "ROOT"
    # SharedServices = "ROOT"
    # Sandbox        = "ROOT"
    # TestAccount    = "ROOT"
    # Production     = "ROOT"
    # Dev            = "ROOT"
  }
}

module "security_account" {
  source        = "../../../modules/account"
  name          = "Security"
  email         = var.security_email
  parent_ou_id  = module.org.ou_ids["Security"]
}

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

module "scp_baseline" {
  source      = "../../../modules/scps"
  name        = "BaselineDeny"
  description = "Deny everything except a few services"
  content     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1"
          ]
        }
      }
    }
  ]
}
EOF
  targets = {
    SecurityOU = module.org.ou_ids["Security"]
    # SharedOU   = module.org.ou_ids["SharedServices"]
  }
}

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


variable "new_accounts" {
  type = list(object({
    AccountName  = string
    AccountEmail = string
  }))
  default = []
}

variable "managed_organizational_unit" {
  type    = string
  default = "SharedServices"
}

variable "account_region" {
  type    = string
  default = "us-east-1"
}

resource "aws_servicecatalog_provisioned_product" "new_accounts" {
  count                      = length(var.new_accounts)
  name                       = var.new_accounts[count.index].AccountName
  product_id                 = "prod-xmve3rknwimb6"
  provisioning_artifact_name = "AWS Control Tower Account Factory"

  provisioning_parameters {
    key   = "AccountEmail"
    value = var.new_accounts[count.index].AccountEmail
  }
  provisioning_parameters {
    key   = "AccountName"
    value = var.new_accounts[count.index].AccountName
  }
  provisioning_parameters {
    key   = "SSOUserEmail"
    value = var.new_accounts[count.index].AccountEmail
  }
  provisioning_parameters {
    key   = "SSOUserFirstName"
    value = split("@", var.new_accounts[count.index].AccountEmail)[0]
  }
  provisioning_parameters {
    key   = "SSOUserLastName"
    value = "User"
  }
  provisioning_parameters {
    key   = "ManagedOrganizationalUnit"
    value = var.managed_organizational_unit
  }
  provisioning_parameters {
    key   = "AccountRegion"
    value = var.account_region
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
