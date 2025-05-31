output "ou_ids" {
  value = { for k, v in aws_organizations_organizational_unit.ou : k => v.id }
}
output "root_id" {
  value = data.aws_organizations_organization.org.roots[0].id
}
