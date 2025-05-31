terraform {
  backend "s3" {
    bucket         = "my-landing-zone-tfstate"
    key            = "global/landing-zone.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-landing-zone-tfstate-lock"
  }
}
