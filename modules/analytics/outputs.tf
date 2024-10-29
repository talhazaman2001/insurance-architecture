# SageMaker
output "sagemaker_endpoint_name" {
    description = "Name of SageMaker Endpoint"
    value = aws_sagemaker_endpoint.fraud_detection.name
}

output "sagemaker_model_arn" {
    description = "SageMaker Model ARN"
    value = aws_sagemaker_model.fraud_detection_model.arn
}

output "sagemaker_endpoint_arn" {
    description = "SageMaker Endpoint ARN"
    value = aws_sagemaker_endpoint.fraud_detection.arn
}

# Glue
output "glue_database_name" {
    description = "Glue Catalog Database Name"
    value = aws_glue_catalog_database.insurance_claims.name
}

# Athena
output "athena_workgroup" {
    description = "Athena Workgroup Name"
    value = aws_athena_workgroup.insurance_analytics.name
}
