
variable "environment" {
  description = "production environment"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for production resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for production"
  type        = string
  default     = "t3.small"
}
