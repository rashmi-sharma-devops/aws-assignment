
# --------------------------------------------------
# 1. AWS Provider
# --------------------------------------------------
provider "aws" {
  region = "ap-south-1"
}

# --------------------------------------------------
# 2. Read the PROD VPC State from S3
# --------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-state-assignment-2026-xyz789"
    key    = "network/prod/terraform.tfstate"
    region = "ap-south-1"
  }
}

# --------------------------------------------------
# 3. Find the Latest Amazon Linux 2023 AMI
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
  name = "assignment-prod-ec2-ssm-role"

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
    Name        = "assignment-prod-ec2-ssm-role"
    Environment = "prod"
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
# 6. IAM Instance Profile
# --------------------------------------------------
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "assignment-prod-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "assignment-prod-ec2-ssm-profile"
    Environment = "prod"
  }
}

# --------------------------------------------------
# 7. ALB Security Group
# Allow internet HTTP access to the ALB
# --------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "assignment-prod-alb-sg"
  description = "Allow HTTP traffic to production ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "assignment-prod-alb-sg"
    Environment = "prod"
  }
}

# --------------------------------------------------
# 8. EC2 Security Group
# Allow HTTP only from the ALB
# --------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "assignment-prod-private-ec2-sg"
  description = "Allow HTTP from production ALB only"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description     = "HTTP from production ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "assignment-prod-private-ec2-sg"
    Environment = "prod"
  }
}

# --------------------------------------------------
# 9. Production EC2 in a Private Subnet
# --------------------------------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd

    TOKEN=$(curl -s -X PUT \
      "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    PRIVATE_IP=$(curl -s \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/local-ipv4)

    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Production Web Server</title>
    </head>
    <body>
      <h1>Hello from AWS EC2 Production!</h1>
      <p><strong>Server Private IP:</strong> $PRIVATE_IP</p>
      <p><strong>Server Environment:</strong> prod</p>
      <p>Apache installed using Terraform User Data.</p>
    </body>
    </html>
    HTML

    systemctl enable httpd
    systemctl start httpd
  EOF

  tags = {
    Name        = "assignment-prod-private-ec2"
    Environment = "prod"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}

# --------------------------------------------------
# 10. Production Application Load Balancer
# --------------------------------------------------
resource "aws_lb" "web_alb" {
  name               = "assignment-prod-web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  tags = {
    Name        = "assignment-prod-web-alb"
    Environment = "prod"
  }
}

# --------------------------------------------------
# 11. Target Group
# --------------------------------------------------
resource "aws_lb_target_group" "web_tg" {
  name        = "assignment-prod-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "assignment-prod-web-tg"
    Environment = "prod"
  }
}

# --------------------------------------------------
# 12. Register EC2 in the Target Group
# --------------------------------------------------
resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# --------------------------------------------------
# 13. HTTP Listener
# --------------------------------------------------
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
