
# 1. ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "assignment-alb-sg"
  description = "Allow HTTP traffic from the internet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "assignment-alb-sg"
  }
}

# 2. Allow HTTP from the internet to the ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id

  description = "Allow HTTP from anywhere"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

# 3. EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "assignment-ec2-sg"
  description = "Allow HTTP only from the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "assignment-ec2-sg"
  }
}

# 4. Allow HTTP to EC2 only from the ALB Security Group
resource "aws_vpc_security_group_ingress_rule" "ec2_http_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id

  description                  = "Allow HTTP only from ALB"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb_sg.id
}
