terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_iam_role" "cross_account_role" {
  name     = var.cross_account_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:root"
        }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID": var.organization_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cross_account_role_policy" {
  role       = aws_iam_role.cross_account_role.name
  policy_arn = var.policy_arn
}
