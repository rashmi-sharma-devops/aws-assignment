
provider "aws" {
  region = "ap-south-1"
}


# Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group shared by the instances
resource "aws_security_group" "demo" {
  name        = "demo-100-ec2-sg"
  description = "Security group for Terraform module demonstration"
  vpc_id      = "vpc-12dae17a"
  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "demo-100-ec2-sg"
    Environment = "demo"
  }
}

# Call the module once; it creates the requested number of instances
module "ec2_fleet" {
  source = "../ec2-module"

  instance_count     = var.instance_count
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_id          = "subnet-faca5bb6"
  security_group_ids = [aws_security_group.demo.id]
  environment        = "demo"
}
