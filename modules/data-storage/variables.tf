variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}

# Networking
variable "vpc_id" {
  type = string
  description = "ID of VPC"  
}

variable "private_subnets" {
  type = list(string)
  description = "Private Subnet IDs"
}

variable "endpoint_sg" {
  type = string
  description = "VPC Interface Endpoint Security Group"
}

variable "private_rt_id" {
  type = list(string)
  description = "Private Route Table IDs"
}

variable "fargate_tasks_sg_id" {
  type = string
  description = "Fargate Tasks Security Group ID"
}