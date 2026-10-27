
resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = false

  tags = {
    Name        = "${var.environment}-ec2-${format("%03d", count.index + 1)}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
