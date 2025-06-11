provider "aws" {
  region = var.home_region
}

locals {
  all_account_ids = flatten([
    for k, v in module.service_catalog_accounts : v.account_ids
  ])
}

provider "aws" {
  alias  = each.key
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${each.value}:role/OrganizationAccountAccessRole"
  }
}