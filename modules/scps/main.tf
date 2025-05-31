resource "aws_organizations_policy" "scp" {
  name        = var.name
  description = var.description
  content     = var.content
  type        = "SERVICE_CONTROL_POLICY"
}
resource "aws_organizations_policy_attachment" "attachment" {
  for_each  = var.targets
  policy_id = aws_organizations_policy.scp.id
  target_id = each.value
}
