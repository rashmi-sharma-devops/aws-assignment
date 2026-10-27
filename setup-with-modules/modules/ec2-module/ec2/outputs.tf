
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.web.private_ip
}

output "subnet_id" {
  description = "Private subnet ID of the EC2 instance"
  value       = aws_instance.web.subnet_id
}
