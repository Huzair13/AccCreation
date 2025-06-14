variable "role_name"           { type = string }
variable "assume_role_policy"  { type = string }
variable "policy_name"         { type = string }
variable "description"         { type = string }
variable "policy_json"         { type = string }
variable "target_account_id" {
  description = "Account ID of the target child account"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild role which will assume this role"
  type        = string
}

variable "execution_role_name" {
  description = "Name of the execution role to create"
  type        = string
  default     = "TerraformExecutionRole"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
