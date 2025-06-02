variable "new_accounts" {
  type = list(object({
    AccountName  = string
    AccountEmail = string
  }))
  description = "List of new accounts to be created"
}

variable "managed_organizational_unit" {
  type        = string
  description = "The organizational unit to place the new accounts in"
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
