


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
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "assignment-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "assignment-ec2-ssm-profile"
    Environment = var.environmen
    Owner       = "Rashmi" 
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0ba051b596cabfebe"
  instance_type = var.instance_type

  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd

    PRIVATE_IP=$(TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && \
      curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/local-ipv4)

    ENVIRONMENT="${var.environment}"

    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Terraform EC2 Web Server</title>
    </head>
    <body>
      <h1>Hello from AWS EC2!</h1>
      <p><strong>Server Private IP:</strong> $PRIVATE_IP</p>
      <p><strong>Server Environment:</strong> $ENVIRONMENT</p>
      <p>Web server installed using Terraform User Data.</p>
    </body>
    </html>
    HTML

    systemctl enable httpd
    systemctl start httpd
  EOF

  tags = {
    Name        = "assignment-private-ec2"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}
