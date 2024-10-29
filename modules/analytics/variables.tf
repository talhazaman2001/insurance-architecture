variable "base_tags" {
  description = "Base tags for all resources"
  type = map(string)
}

# Data Storage
variable "athena_results_bucket" {
  type = string
  description = "Athena Results S3 Bucket"
}

variable "insurance_bucket_id" {
  type = string
  description = "Insurance Bucket ID"
}

variable "sagemaker_model_artifacts_id" {
  type = string
  description = "SageMaker Model Artifacts Bucket ID"
}

# Security
variable "glue_role_arn" {
  type = string
  description = "IAM Role for Glue to access Insurance Bucket"
}

variable "sagemaker_role_arn" {
  type = string
  description = "SageMaker Role to access S3 Insurance Bucket"
}