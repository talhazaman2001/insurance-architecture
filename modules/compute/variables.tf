variable "private_subnets" {
  type = list(string)
  description = "Private Subnets"
}

variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}

# Data Storage
variable "insurance_bucket_arn" {
  type = string
  description = "Insurance S3 Bucket ARN"
}

variable "dynamodb_table_arn" {
  type = string
  description = "DynamoDB Table ARN"
}

variable "repository_urls" {
  description = "ECR Repository URLs"
  type = map(string)
}

variable "dynamodb_table_name" {
  description = "DynamoDB Table Name"
  type = string
}

variable "aurora_endpoint" {
  type = string
  description = "Aurora Endpoint"
}

variable "insurance_bucket_id" {
  type = string
  description = "Insurance Bucket ID"
}

# Monitoring
variable "kinesis_stream_arn" {
  type = string
  description = "Kinesis Stream ARN"
}

variable "fraud_detection_engine_log_group_name" {
  type = string
  description = "Fraud Detection CloudWatch Log Group ARN"
}

variable "risk_assessment_service_log_group_name" {
  type = string
  description = "Risk Assessment CloudWatch Log Group Name"
}

variable "claims_processing_service_log_group_name" {
  type = string
  description = "Claims Processing CloudWatch Log Group Name"
}

variable "xray_log_group_arn" {
  type = string
  description = "XRay Log Group ARN"
}

# Networking
variable "alb_sg_id" {
  type = string
  description = "ALB SG ID"
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "fargate_alb_listener_arn" {
  type = string
  description = "Fargate ALB Listener ARN"
}

variable "fraud_detection_engine_blue_tg_arn" {
  type = string 
}

variable "risk_assessment_service_blue_tg_arn" {
  type = string
}

variable "claims_processing_service_blue_tg_arn" {
  type = string
}

# Security
variable "api_gateway_role_arn" {
  type = string
  description = "API Gateway Role ARN"
}

variable "api_gateway_attach" {
  type = string
  description = "Attaches API Gateway Policy to Role"
}

variable "fargate_execution_role_arn" {
  type = string
  description = "Fargate Task Execution Role ARN"
}

variable "fargate_task_role_arn" {
  type = string
  description = "Fargate Task Role ARN"
}
