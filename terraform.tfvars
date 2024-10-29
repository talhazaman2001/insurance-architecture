# terraform.tfvars
environment  = "prod"
project_name = "insurance-architecture"

base_tags = {
  Name        = "InsuranceProject"
  Environment = "testing"
  Owner       = "Me"
}

# Place holders
api_gateway_endpoint = "https://placeholder.execute-api.region.amazonaws.com"
waf_web_acl_id       = "arn:aws:wafv2:eu-west-2:463470963000:regional/webacl/placeholder-id"
waf_web_acl_arn      = "arn:aws:wafv2:eu-west-2:463470963000:regional/webacl/placeholder-id"
waf_log_group_arn    = "arn:aws:logs:eu-west-2:463470963000:log-group:placeholder-log-group"
cdn_arn              = "arn:aws:cloudfront::463470963000:distribution/placeholder"
api_gateway_log_group_arn = "arn:aws:logs:eu-west-2:463470963000:log-group:placeholder-log-group"
