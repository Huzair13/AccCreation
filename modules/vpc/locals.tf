locals {
  default_azs = length(var.azs) > 0 ? var.azs : data.aws_availability_zones.available.names
}
