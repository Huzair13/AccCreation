module "iam_admin" {
  source             = "../../../modules/iam"
  role_name          = var.role_name
  assume_role_policy = var.assume_role_policy
  policy_name        = var.policy_name
  description        = var.description
  policy_json        = var.policy_json
}
