locals {
  all_account_ids = flatten([
    for k, v in module.service_catalog_accounts : v.account_ids
  ])
}

# Provider configurations for each account
provider "aws" {
  alias  = "management"
  region = var.home_region
}

# Provider for cross-account access
provider "aws" {
  alias  = "cross_account"
  region = var.home_region
  assume_role {
    role_arn = "arn:aws:iam::${var.trusted_account_id}:role/OrganizationAccountAccessRole"
  }
}
