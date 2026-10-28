
output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "vpc_id" {
  description = "Production VPC ID"
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "ec2_instance_id" {
  description = "Production EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_security_group_id" {
  description = "Production EC2 security group ID"
  value       = module.security_groups.ec2_security_group_id
}

output "alb_security_group_id" {
  description = "Production ALB security group ID"
  value       = module.security_groups.alb_security_group_id
}

output "alb_dns_name" {
  description = "Production Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}
