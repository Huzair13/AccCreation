provider "aws" {
  alias  = "target"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.target_account_id}:role/OrganizationAccountAccessRole"
  }
}

resource "aws_iam_role" "execution_role" {
  provider = aws.target
  name     = var.execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = var.codebuild_role_arn
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_admin" {
  provider        = aws.target
  role            = aws_iam_role.execution_role.name
  policy_arn      = "arn:aws:iam::aws:policy/AdministratorAccess" 
}
