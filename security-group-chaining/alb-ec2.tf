
# Find the latest Amazon Linux 2023 AMI in ap-south-1
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

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

# EC2 instance in a private subnet
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    cat > /tmp/server.py <<'PYTHON'
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(b"<html><body><h1>Success!</h1><p>Traffic reached the EC2 instance through the Application Load Balancer.</p></body></html>")

    HTTPServer(("0.0.0.0", 80), Handler).serve_forever()
    PYTHON

    python3 /tmp/server.py
  EOF

  tags = {
    Name        = "assignment-web-server"
    Environment = "dev"
  }
}

# Target group forwards HTTP requests to EC2 on port 80
resource "aws_lb_target_group" "web" {
  name     = "assignment-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "assignment-web-tg"
  }
}

# Register the EC2 instance with the target group
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# Public Application Load Balancer across two public subnets
resource "aws_lb" "web" {
  name               = "assignment-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "assignment-web-alb"
  }
}

# Listener accepts HTTP traffic and forwards it to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
