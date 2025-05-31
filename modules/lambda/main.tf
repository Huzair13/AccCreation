# resource "aws_iam_role" "lambda_role" {
#   name = "${var.function_name}_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "${var.function_name}_policy"
#   role = aws_iam_role.lambda_role.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "servicecatalog:ListPortfolios",
#           "servicecatalog:SearchProductsAsAdmin",
#           "servicecatalog:ListProvisioningArtifacts",
#           "servicecatalog:ProvisionProduct",
#           "organizations:DescribeOrganizationalUnit",
#           "organizations:ListAccounts",
#           "organizations:ListOrganizationalUnitsForParent",
#           "organizations:DescribeAccount"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_file = var.source_path
#   output_path = "${path.module}/lambda_function_${var.function_name}.zip"
# }

# resource "aws_lambda_function" "lambda_function" {
#   function_name    = var.function_name
#   role             = aws_iam_role.lambda_role.arn
#   runtime          = var.runtime
#   handler          = var.handler
#   filename         = data.archive_file.lambda_zip.output_path
#   timeout          = var.timeout
#   memory_size      = var.memory_size
#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256

#   environment {
#     variables = {
#       PYTHONPATH = "/var/task/lib"
#     }
#   }
# }


resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Control Tower API permissions
          "controltower:EnableBaseline",
          "controltower:DisableBaseline",
          "controltower:GetEnabledBaseline",
          "controltower:ListEnabledBaselines",
          "controltower:RegisterOrganizationalUnit",
          "controltower:DeregisterOrganizationalUnit",
          "controltower:EnrollAccount",
          "controltower:GetAccountInfo",
          "controltower:ListManagedAccounts",
          "controltower:ListManagedOrganizationalUnits",
          # Service Catalog permissions (for fallback)
          "servicecatalog:ListPortfolios",
          "servicecatalog:SearchProductsAsAdmin",
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:ProvisionProduct",
          "servicecatalog:ListLaunchPaths",
          "servicecatalog:DescribeProvisioningParameters",
          # Organizations permissions
          "organizations:DescribeOrganizationalUnit",
          "organizations:ListAccounts",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:DescribeAccount",
          "organizations:ListChildren",
          "organizations:ListParents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.source_path
  output_path = "${path.module}/lambda_function_${var.function_name}.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.runtime
  handler          = var.handler
  filename         = data.archive_file.lambda_zip.output_path
  timeout          = var.timeout
  memory_size      = var.memory_size
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  environment {
    variables = {
      PYTHONPATH = "/var/task/lib"
    }
  }
}