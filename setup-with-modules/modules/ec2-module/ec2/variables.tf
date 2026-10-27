
variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet for EC2"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to EC2"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
