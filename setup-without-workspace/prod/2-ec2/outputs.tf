
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.web.private_ip
}

output "ec2_subnet_id" {
  description = "Private subnet containing the EC2 instance"
  value       = aws_instance.web.subnet_id
}

output "vpc_id" {
  description = "VPC used by EC2"
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "alb_url" {
  description = "URL to access the sample web page"
  value       = "http://${aws_lb.web_alb.dns_name}"
}


