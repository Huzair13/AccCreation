resource "aws_s3_bucket" "cloudtrail" {
  bucket = var.s3_bucket
}

resource "aws_cloudtrail" "trail" {
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = var.name
  role_arn = var.recorder_role_arn
}
