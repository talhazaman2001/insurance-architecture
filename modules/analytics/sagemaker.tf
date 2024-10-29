# SageMaker Model
resource "aws_sagemaker_model" "fraud_detection_model" {
    name = "fraud-detection-model"
    execution_role_arn = var.sagemaker_role_arn

    primary_container {
      image = "764403040460.dkr.ecr.eu-west-2.amazonaws.com/sagemaker-xgboost:1.5-1"
      model_data_url = "s3://${var.sagemaker_model_artifacts_id}/models/fraud-detection/model.tar.gz"
    }

    tags = merge(var.base_tags, {
        Service = "sagemaker"
        Type = "ml-model"
    })
}

# SageMaker Endpoint Configuration
resource "aws_sagemaker_endpoint_configuration" "fraud_detection" {
    name = "fraud-detection-endpoint-config"

    production_variants {
      variant_name = "fraud-detection-variant"
      model_name = aws_sagemaker_model.fraud_detection_model.name
      initial_instance_count = 1
      instance_type = "ml.t2.medium"
      initial_variant_weight = 1.0
    }

    tags = var.base_tags
}

# SageMaker Endpoint
resource "aws_sagemaker_endpoint" "fraud_detection" {
    name = "fraud-detection-endpoint"
    endpoint_config_name = aws_sagemaker_endpoint_configuration.fraud_detection.name

    tags = var.base_tags
}

