variable "name" {
  type        = string
  description = "Account display name"
}
variable "email" {
  type        = string
  description = "Account email address"
}
variable "parent_ou_id" {
  type        = string
  description = "OU ID"
}
variable "role_name" {
  type    = string
  default = "OrganizationAccountAccessRole"
}
