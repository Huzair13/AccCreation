variable "new_accounts" {
  type = list(object({
    AccountName  = string
    AccountEmail = string
    ManagedOrganizationalUnit = string
    share_tgw = bool
    share_subnets = bool
  }))
  description = "List of new accounts to be created with TGW and subnet sharing preferences"
}

variable "account_region" {
  type        = string
  description = "The region for the new accounts"
}

variable "product_id" {
  type        = string
  description = "The ID of the AWS Service Catalog product"
}

variable "provisioning_artifact_name" {
  type        = string
  description = "The name of the provisioning artifact"
}
