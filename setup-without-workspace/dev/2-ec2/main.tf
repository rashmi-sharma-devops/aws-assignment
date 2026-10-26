
# --------------------------------------------------
# 1. AWS Provider
# --------------------------------------------------
provider "aws" {
  region = "ap-south-1"
}

# --------------------------------------------------
# 2. Read Existing VPC State from S3
# --------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-state-assignment-2026-xyz789"
    key    = "network/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

# --------------------------------------------------
# 3. Find Latest Amazon Linux 2023 AMI
# --------------------------------------------------
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

# --------------------------------------------------
# 4. IAM Role for Systems Manager
# --------------------------------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name = "assignment-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "assignment-ec2-ssm-role"
    Environment = "dev"
  }
}

# --------------------------------------------------
# 5. Attach Systems Manager Permissions
# --------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --------------------------------------------------
# 6. Create IAM Instance Profile
# --------------------------------------------------
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "assignment-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "assignment-ec2-ssm-profile"
    Environment = "dev"
  }
}

# --------------------------------------------------
# 7. Security Group for Private EC2
# --------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "assignment-private-ec2-sg"
  description = "Security group for private EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # No inbound SSH rule is required for Session Manager.

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "assignment-private-ec2-sg"
    Environment = "dev"
  }
}

# --------------------------------------------------
# 8. Create EC2 Instance in Private Subnet
# --------------------------------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  # Use the first private subnet from VPC remote state
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]

  # Attach the private EC2 security group
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  # Do not assign a public IP
  associate_public_ip_address = false

  # Enable Systems Manager Session Manager access
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  tags = {
    Name        = "assignment-private-ec2"
    Environment = "dev"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}
