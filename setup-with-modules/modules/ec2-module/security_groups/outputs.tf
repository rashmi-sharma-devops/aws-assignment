
output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "Security group ID for the private EC2 instance"
  value       = aws_security_group.ec2_sg.id
}
