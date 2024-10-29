# ECR configuration
output "repository_urls" {
  description = "URLs of ECR repositories"
  value = {
    fraud_detection = aws_ecr_repository.fraud_detection_engine.repository_url
    risk_assessment = aws_ecr_repository.risk_assessment_service.repository_url
    claims_processing = aws_ecr_repository.claims_processing_service.repository_url
  }
}

output "repository_arns" {
  description = "ARNs of ECR repositories"
  value = {
    fraud_detection = aws_ecr_repository.fraud_detection_engine.arn
    risk_assessment = aws_ecr_repository.risk_assessment_service.arn
    claims_processing = aws_ecr_repository.claims_processing_service.arn
  }
}

output "ecr_vpc_endpoints" {
  description = "VPC Endpoint IDs for ECR"
  value = {
    api = aws_vpc_endpoint.ecr_api_endpoint.id
    dkr = aws_vpc_endpoint.ecr_dkr_endpoint.id
  }
}

output "registry_id" {
  description = "Registry ID"
  value = aws_ecr_repository.fraud_detection_engine.registry_id
}

output "sagemaker_xgboost_repository_arn" {
  value = aws_ecr_repository.sagemaker_xgboost.arn
}


# Aurora 
output "aurora_endpoint" {
  description = "Aurora Cluster Endpoint"
  value = aws_rds_cluster.insurance_cluster.endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora Reader Endpoint"
  value = aws_rds_cluster.insurance_cluster.reader_endpoint
}

output "aurora_database_name" {
  description = "Aurora Database Name"
  value = aws_rds_cluster.insurance_cluster.database_name
}

output "aurora_port" {
  description = "Aurora Port"
  value = aws_rds_cluster.insurance_cluster.port
}

output "aurora_id" {
  description = "Aurora Insurance Cluster ID"
  value = aws_rds_cluster.insurance_cluster.id
}

output "aurora_cluster_arn" {
  description = "Aurora Insurance Cluster ARN"
  value = aws_rds_cluster.insurance_cluster.arn  
}

# DynamoDB
output "dynamodb_table_arn" {
  description = "ARN of insurance claims table"
  value = aws_dynamodb_table.insurance_claims.arn
}

output "dynamodb_table_name" {
  description = "Name of insurance claims table"
  value = aws_dynamodb_table.insurance_claims.name
}

output "dynamodb_table_hash_key" {
  description = "Hash key of insurance claims table"
  value = aws_dynamodb_table.insurance_claims.hash_key
}

# S3 
output "insurance_bucket_arn" {
  description = "Insurance Raw Data Bucket ARN"
  value = aws_s3_bucket.insurance_bucket.arn
}

output "insurance_bucket_id" {
  description = "Insurance Raw Data Bucket ID"  
  value = aws_s3_bucket.insurance_bucket.id
}

output "athena_results_bucket" {
  description = "S3 Bucket for Athena Query Results"
  value = aws_s3_bucket.athena_results.id
}

output "sagemaker_model_artifacts_arn" {
  description = "SageMaker Model Artifacts Bucket ARN"
  value = aws_s3_bucket.sagemaker_model_artifacts.arn
}

output "sagemaker_model_artifacts_id" {
  description = "SageMaker Model Artifacts Bucket ID"
  value = aws_s3_bucket.sagemaker_model_artifacts.id
}

output "athena_results_arn" {
  description = "Athena Results Bucket ARN"
  value = aws_s3_bucket.athena_results.arn
}