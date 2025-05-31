variable "name"        { type = string }
variable "description" { type = string }
variable "content"     { type = string }
variable "targets" {
  description = "Map of label to OU or account IDs"
  type        = map(string)
}
