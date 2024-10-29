# modules/networking/variables.tf
variable "environment" {
 description = "Environment (dev/prod)"
 type        = string
}

variable "azs" {
 description = "Availability zones"
 type        = list(string)
 default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "public_subnets" {
  type = list(string)
  description = "Public Subnets"
}

variable "private_subnets" {
  type = list(string)
  description = "Private Subnets"
}

variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}

# Compute
variable "api_gateway_endpoint" {
  type = string
  description = "API Gateway Endpoint"
  default     = "https://placeholder.execute-api.region.amazonaws.com"
}

# Monitoring
variable "waf_log_group_arn" {
  type = string
  description = "WAF Log Group ARN"
  default     = "arn:aws:wafv2:eu-west-2:463470963000:regional/webacl/placeholder-log-group"
}

# Security
variable "waf_web_acl_id" {
  type = string
  description = "WAF Web ACL ID"
  default     = "arn:aws:wafv2:eu-west-2:463470963000:regional/webacl/placeholder-id"
}

variable "waf_web_acl_arn" {
  type = string
  description = "WAF Web ACL ARN"
  default     = "arn:aws:wafv2:eu-west-2:463470963000:regional/webacl/placeholder-id"
}