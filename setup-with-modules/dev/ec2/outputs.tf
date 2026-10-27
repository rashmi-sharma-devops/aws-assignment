
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.private_ip
}

output "ec2_subnet_id" {
  description = "Private subnet containing the EC2 instance"
  value       = module.ec2.subnet_id
}

output "vpc_id" {
  description = "Existing VPC used by the compute infrastructure"
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL to access the sample web page"
  value       = module.alb.alb_url
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = module.security_groups.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "Security group ID for the private EC2 instance"
  value       = module.security_groups.ec2_security_group_id
}
