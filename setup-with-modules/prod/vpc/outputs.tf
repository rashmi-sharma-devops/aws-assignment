
output "vpc_id" {
  description = "ID of the production VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the production VPC"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of production public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of production private subnets"
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the production Internet Gateway"
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the production NAT Gateway"
  value       = module.network.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the production NAT Gateway"
  value       = module.network.nat_gateway_public_ip
}

output "public_route_table_id" {
  description = "ID of the production public route table"
  value       = module.network.public_route_table_id
}

output "private_route_table_id" {
  description = "ID of the production private route table"
  value       = module.network.private_route_table_id
}
