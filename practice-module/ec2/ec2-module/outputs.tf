
output "instance_ids" {
  description = "IDs of all created EC2 instances"
  value       = aws_instance.this[*].id
}

output "private_ips" {
  description = "Private IP addresses of all EC2 instances"
  value       = aws_instance.this[*].private_ip
}
