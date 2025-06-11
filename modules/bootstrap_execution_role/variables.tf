variable "cross_account_role_name" {
  description = "Name of the cross-account role to create"
  type        = string
  default     = "CrossAccountExecutionRole"
}

variable "trusted_account_id" {
  description = "Account ID of the trusted AWS account that can assume this role"
  type        = string
}

variable "organization_id" {
  description = "ID of the AWS Organization"
  type        = string
}

variable "policy_arn" {
  description = "ARN of the IAM policy to attach to the role"
  type        = string
  default     = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
