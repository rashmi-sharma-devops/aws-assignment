
variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
