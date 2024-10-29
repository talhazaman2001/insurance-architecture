# variables.tf
variable "environment" {
  description = "Environment name like prod, dev, staging"
  type        = string
}

variable "project_name" {
  description = "Project or application name"
  type        = string
}

# Compute
variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}


# Networking
variable "api_gateway_endpoint" {
  type = string
  description = "API Gateway Endpoint"
  default     = "https://placeholder.execute-api.region.amazonaws.com"
}

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

variable "waf_log_group_arn" {
  type = string
  description = "WAF Log Group ARN"
  default     = "arn:aws:wafv2:eu-west-2:463470963000:regional/webacl/placeholder-log-group"
}

# Security
variable "cdn_arn" {
  type = string
  description = "CloudFront ARN"
  default     = "arn:aws:cloudfront::463470963000:distribution/placeholder"
}

variable "api_gateway_log_group_arn" {
  type = string
  description = "API Gateway CloudWatch Log Group ARN"
  default = "arn:aws:logs:eu-west-2:463470963000:log-group:placeholder-log-group"
}
