variable "home_region"   { default = "us-east-1" }
variable "test_email"    { type = string }

variable "account_factory_product_id" {
  type        = string
  description = "The ID of the AWS Control Tower Account Factory product"
}

variable "ou_factory_product_id" {
  type        = string
  description = "The ID of the AWS Control Tower Organizational Unit Factory product"
  default = "prod-xmve3rknwimb6"
}

variable "sso_user_email" {
  type        = string
  description = "Email for the SSO user"
  default = "huz.aws.p+sample3@gmail.com"
}

variable "security_email" {
  type        = string
  description = "Email address for the Security account"
}

variable "shared_email" {
  type        = string
  description = "Email address for the Shared Services account"
}

variable "production_email" {
  type        = string
  description = "Email address for the Production account"
}

variable "dev_email" {
  type        = string
  description = "Email address for the Dev account"
}

variable "new_account_email" {
  type        = string
  description = "Email address for the new account created via Service Catalog"
}

variable "new_ou_name" {
  type        = string
  description = "Name of the new Organizational Unit to be created"
  default = "NewOrganizationalUnit"
}

variable "ou_product_id" {
  type        = string
  description = "The ID of the custom Service Catalog product for creating OUs"
  default     = "prod-xmve3rknwimb6" 
}

variable "ou_configs" {
  type = list(object({
    accounts = list(object({
      AccountName  = string
      AccountEmail = string
    }))
    ManagedOrganizationalUnit = string
    AccountRegion             = string
  }))
  description = "List of OU configurations with accounts"
}

variable "product_id" {
  type        = string
  default     = "prod-xmve3rknwimb6"
  description = "The ID of the AWS Service Catalog product"
}

variable "provisioning_artifact_name" {
  type        = string
  default     = "AWS Control Tower Account Factory"
  description = "The name of the provisioning artifact"
}

variable "trusted_account_id" {
  type        = string
  description = "The AWS account ID of your management account or the account from which you'll be running Terraform to manage other accounts. This account will be allowed to assume the cross-account role."
}

variable "organization_id" {
  type        = string
  description = "The ID of the AWS Organization"
}

variable "cross_account_policy_arn" {
  type        = string
  description = "The ARN of the IAM policy to attach to the cross-account role"
  default     = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "management_account_id" {
  type        = string
  description = "The AWS account ID of the management account"
}
