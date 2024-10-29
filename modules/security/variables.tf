variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}

# Analytics
variable "sagemaker_model_arn" {
  type = string
  description = "SageMaker Model ARN"
}

variable "sagemaker_endpoint_arn" {
  type = string
  description = "SageMaker Endpoint ARN"
}

# Compute


# Data Storage
variable "insurance_bucket_arn" {
  type = string
  description = "Insurance S3 Bucket ARN"
}

variable "athena_results_arn" {
  type = string
  description = "Athena Results S3 Bucket ARN"
}

variable "dynamodb_table_arn" {
  type = string
  description = "DynamoDB Table S3 Bucket ARN"
}

variable "sagemaker_model_artifacts_arn" {
  type = string
  description = "SageMaker Model Artifacts S3 Bucket ARN"
}

variable "aurora_cluster_arn" {
  type = string
  description = "Aurora Cluster ARN"
}

variable "repositories" {
  description = "Names of ECR repositories"
  type = map(string)
  default = {
    fraud_detection_engine  = "fraud-detection-engine"
    risk_assessment_service  = "risk-assessment-service"
    claims_processing_service = "claims-processing-service"
  }
}

variable "sagemaker_xgboost_repository_arn" {
  description = "ARN of SageMaker XGBoost Repository"
  type = string
}

variable "repository_arns" {
  description = "ECR Repository ARNs"
  type = map(string)
}

# Monitoring
variable "sagemaker_log_group_arn" {
  type = string
  description = "SageMaker CloudWatch Log Group ARN"
}

variable "api_gateway_log_group_arn" {
  type = string
  description = "API Gateway CloudWatch Log Group ARN"
  default = "arn:aws:logs:eu-west-2:463470963000:log-group:placeholder-log-group"
}

variable "fraud_detection_engine_log_group_arn" {
  type = string
  description = "Fraud Detection CloudWatch Log Group ARN"
}

variable "risk_assessment_service_log_group_arn" {
  type = string
  description = "Risk Assessment CloudWatch Log Group ARN"
}

variable "claims_processing_service_log_group_arn" {
  type = string
  description = "Claims Processing CloudWatch Log Group ARN"
}

variable "macie_log_group_arn" {
  type = string
  description = "Macie CloudWatch Log Group ARN"
}

variable "alb_log_group_arn" {
  type = string
  description = "ALB CloudWatch Log Group ARN"
}

variable "sns_topic_arn" {
  type = string
  description = "SNS Topic ARN"
}

variable "kinesis_stream_arn" {
  type = string
  description = "Kinesis Stream ARN"
}

variable "waf_log_group_arn" {
  type = string
  description = "WAF CloudWatch Log Group ARN"
}

# Networking
variable "fargate_alb_arn" {
  type = string
  description = "Fargate ALB ARN"
}

variable "cdn_arn" {
  type = string
  description = "CloudFront ARN"
  default     = "arn:aws:cloudfront::463470963000:distribution/placeholder"
}

variable "route53_zone_arn" {
  type = string
  description = "Route 53 Zone ARN"
}
