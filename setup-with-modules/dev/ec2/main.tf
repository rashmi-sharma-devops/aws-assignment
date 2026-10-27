
# Read the existing VPC outputs from the S3 state
# Read the existing VPC outputs from S3
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-state-assignment-2026-xyz789"
    key    = "network-module/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

# Create security groups
module "security_groups" {
  source = "../../modules/ec2-module/security_groups"

  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  environment = var.environment
}

# Create the private EC2 instance and its SSM IAM resources
module "ec2" {
  source = "../../modules/ec2-module/ec2"

  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  security_group_id = module.security_groups.ec2_security_group_id

  instance_type = var.instance_type
  environment   = var.environment
}

# Create the ALB and register the EC2 instance
module "alb" {
  source = "../../modules/ec2-module/alb"

  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids     = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  ec2_instance_id       = module.ec2.instance_id

  environment = var.environment
}
