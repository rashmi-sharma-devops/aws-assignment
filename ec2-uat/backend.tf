terraform {
  backend "s3" {
    bucket       = "terraform-state-assignment-2026-xyz789"
    key          = "aws-assignment-uat/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}