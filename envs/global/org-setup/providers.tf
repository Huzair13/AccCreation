provider "aws" {
  region = var.home_region
}

locals {
  all_account_ids = flatten([
    for k, v in module.service_catalog_accounts : v.account_ids
  ])
}

# Dynamic provider configurations
locals {
  provider_config = {
    for account_id in local.all_account_ids :
    account_id => {
      alias  = account_id
      assume_role = {
        role_arn = "arn:aws:iam::${account_id}:role/OrganizationAccountAccessRole"
      }
    }
  }
}

# Generate provider configurations
module "providers" {
  source  = "terraform-aws-modules/dynamic-provider/aws"
  version = "~> 1.0"

  providers = local.provider_config
}
