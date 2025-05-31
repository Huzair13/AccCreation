data "aws_organizations_organization" "org" {}

resource "aws_organizations_organizational_unit" "ou" {
  for_each  = var.ous
  name      = each.key
  parent_id = each.value == "ROOT" ? data.aws_organizations_organization.org.roots[0].id : each.value
}
