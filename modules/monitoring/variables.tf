# modules/monitoring/variables.tf
variable "log_retention_days" {
 description = "CloudWatch log retention in days"
 type        = number
 default     = 30
}

variable "kinesis_shard_count" {
 description = "Number of Kinesis shards"
 type        = number
 default     = 1
}

variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}

# Analytics
variable "sagemaker_endpoint_name" {
  type = string
  description = "SageMaker Endpoint Name"
}


# Compute
variable "api_gateway_id" {
  type = string
  description = "API Gateway ID"
}

variable "ecs_cluster_name" {
  type = string
  description = "ECS Cluster Name"
}

# Data Storage
variable "aurora_cluster_arn" {
  type = string
  description = "Aurora Cluster ARN"
}


# Networking
variable "fargate_alb_arn" {
  type = string
  description = "Fargate ALB ARN"
}

variable "fraud_detection_engine_blue_tg_arn" {
  type = string
  description = "Fraud Detection Engine Target Group ARN"
}

variable "risk_assessment_service_blue_tg_arn" {
  type = string
  description = "Risk Assessment Service Target Group ARN"
}

variable "claims_processing_service_blue_tg_arn" {
  type = string
  description = "Claims Processing Service Target Group ARN"
}

# Security
variable "waf_web_acl_name" {
  type = string
  description = "WAF Web ACL Name"
}

variable "classification_job_id" {
  type = string
  description = "Macie Classification Job ID"
}