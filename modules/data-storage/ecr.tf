# ECR Repositories
resource "aws_ecr_repository" "fraud_detection_engine" {
  name = "fraud-detection-engine"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(local.ecr_tags, local.container_tags.fraud_detection_engine)
}

resource "aws_ecr_repository" "risk_assessment_service" {
  name = "risk-assessment-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.ecr_tags, local.container_tags.risk_assessment_service)
}

resource "aws_ecr_repository" "claims_processing_service" {
  name = "claims-processing-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.ecr_tags, local.container_tags.claims_processing_service)
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "cleanup" {
  count = 3
  repository = element([
      aws_ecr_repository.fraud_detection_engine.name,
      aws_ecr_repository.risk_assessment_service.name,
      aws_ecr_repository.claims_processing_service.name
  ], count.index)

  policy = jsonencode({
      rules = [{
          rulePriority = 1
          description = "Keep last 5 images"
          selection = {
              tagStatus = "any"
              countType = "imageCountMoreThan"
              countNumber = 5
          }

          action = {
              type = "expire"
          }
      }]
  })
}

# ECR API VPC Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.ecr.api"  
  vpc_endpoint_type = "Interface"
  subnet_ids = var.private_subnets
  security_group_ids = [var.endpoint_sg]  
}

# ECR DKR VPC Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.ecr.dkr"  
  vpc_endpoint_type = "Interface"
  subnet_ids = var.private_subnets
  security_group_ids = [var.endpoint_sg]  
}

# ECR Repository for SageMaker XGBoost Model
resource "aws_ecr_repository" "sagemaker_xgboost" {
  name = "sagemaker-xgboost"
}

resource "aws_ecr_repository_policy" "sagemaker_xgboost_policy" {
  repository = aws_ecr_repository.sagemaker_xgboost.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
