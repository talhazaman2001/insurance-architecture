# ANALYTICS 

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
    name = "glue-service-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "glue.amazonaws.com"
            }
        }]
    })
}

# IAM Policy for Glue to access S3 insurance bucket
resource "aws_iam_policy" "glue_s3_policy" {
    name = "glue-s3-access"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    var.insurance_bucket_arn,
                    "${var.insurance_bucket_arn}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
    role = aws_iam_role.glue_role.name
    policy_arn = aws_iam_policy.glue_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_service" {
    role = aws_iam_role.glue_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# IAM Role and Policy for Athena to output to S3 and query from Glue
resource "aws_iam_role" "athena_role" {
    name = "athena-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "sagemaker.amazonaws.com"
            }
        }]
    })

}

resource "aws_iam_policy" "athena_policy" {
    name = "athena-s3-glue-access"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket",
                    "s3:GetBucketLocation"
                ]
                Resource = [
                    var.athena_results_arn,
                    "${var.athena_results_arn}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "athena_attach" {
    role = aws_iam_role.athena_role.name
    policy_arn = aws_iam_policy.athena_policy.arn
}

# SageMaker IAM Role 
resource "aws_iam_role" "sagemaker_role" {
    name = "sagemaker-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "sagemaker.amazonaws.com"
            }
        }]
    })
}

# SageMaker IAM Policy 
resource "aws_iam_policy" "sagemaker_s3_policy" {
    name = "sagemaker-s3-policy"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    var.insurance_bucket_arn,
                    "${var.insurance_bucket_arn}/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "cloudwatch:PutMetricData",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:CreateLogGroup",
                    "logs:DescribeLogStreams"
                ]
                Resource = var.sagemaker_log_group_arn
            },
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:BatchCheckLayerAvailability"
                ]
                Resource = var.sagemaker_xgboost_repository_arn
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "sagemaker_s3_attach" {
    role = aws_iam_role.sagemaker_role.name
    policy_arn = aws_iam_policy.sagemaker_s3_policy.arn
}

# COMPUTE

# API Gateway Role and Policy 
resource "aws_iam_role" "api_gateway_role" {
    name = "api-gateway-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "apigateway.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_policy" "api_gateway_policy" {
    name = "api-gateway-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "elasticloadbalancing:DescribeLoadBalancers",
                    "elasticloadbalancing:DescribeTargetGroups",
                    "elasticloadbalancing:DescribeTargetHealth"
                ]
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams",
                    "logs:PutLogEvents",
                    "logs:GetLogEvents",
                    "logs:FilterLogEvents"
                ]
                Resource = [
                    var.api_gateway_log_group_arn,
                    "${var.api_gateway_log_group_arn}:*"
                ]
            }   
        ]
    })
}

resource "aws_iam_role_policy_attachment" "api_gateway_attach" {
    role = aws_iam_role.api_gateway_role.name
    policy_arn = aws_iam_policy.api_gateway_policy.arn
}

# IAM Role for Fargate Task Execution
resource "aws_iam_role" "fargate_execution_role" {
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }]
    })
}

# IAM Policy for Fargate Execution Role with Specific Permissions (Least Privilege with broader permissions for overall execution of task)
resource "aws_iam_policy" "fargate_execution_policy" {
    name = "fargate-task-policy-talha"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            # S3 Specific Actions
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    var.insurance_bucket_arn,
                    "${var.insurance_bucket_arn}/*"
                ]
            },
            # DynamoDB Specific Actions
            {
                Effect = "Allow"
                Action = [
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:Query",
                    "dynamodb:UpdateItem"
                ]
                Resource = [
                    var.dynamodb_table_arn
                ]
            },
            # ECR Specific Actions
            {
                Effect = "Allow"
                Action = [
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage"
                ]
                Resource = var.repository_arns
            },
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetAuthorizationToken"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "fargate_execution_attach" {
    role = aws_iam_role.fargate_execution_role.name
    policy_arn = aws_iam_policy.fargate_execution_policy.arn
}

# IAM Role for Fargate Tasks (minimum permissions for Fargate Task to perform core functions)
resource "aws_iam_role" "fargate_task_role" {

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Fargate Task Role
resource "aws_iam_policy" "fargate_task_policy" {
    name = "fargate-task-policy-talha"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            
            # CloudWatch Specific Log Groups
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                    ]
                Resource = [
                    "${var.fraud_detection_engine_log_group_arn}:*",
                    "${var.risk_assessment_service_log_group_arn}:*",
                    "${var.claims_processing_service_log_group_arn}:*"       
                ]
            },
            # X-Ray Specific Actions
            {
                Effect = "Allow"
                Action = [
                    "xray:PutTraceSegments",
                    "xray:PutTelemetryRecords",
                    "xray:GetSamplingRules",
                    "xray:GetSamplingTargets",
                    "xray:GetSamplingStatisticSummaries"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "fargate_task_attach" {
    role = aws_iam_role.fargate_task_role.name
    policy_arn = aws_iam_policy.fargate_task_policy.arn
}


# NETWORKING

# CloudFront WAF Role
resource "aws_iam_role" "cloudfront_waf_role" {
    name = "cloudfront-waf-role-talha"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "cloudfront.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_policy" "cloudfront_waf_policy" {
    name = "cloudfront-waf-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "wafv2:GetWebACL",
                    "wafv2:GetWebACLForResource"
                ]
                Resource = aws_wafv2_web_acl.global_insurance.arn
            },
            {
                Effect = "Allow" 
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "${var.waf_log_group_arn}:*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_waf_attach" {
    role = aws_iam_role.cloudfront_waf_role.name
    policy_arn = aws_iam_policy.cloudfront_waf_policy.arn
}

# IAM Role and Policy for Macie
resource "aws_iam_role" "macie_role" {
    name = "macie-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "macie.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_policy" "macie_policy" {
    name = "macie-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:GetObjectLocation"
                ]
                Resource = [
                var.insurance_bucket_arn,
                "${var.insurance_bucket_arn}/*"
                ]
            },
            {
                Effect = "Allow" 
                Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
                ]
                Resource = var.macie_log_group_arn
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "macie_attach" {
    role = aws_iam_role.macie_role.name
    policy_arn = aws_iam_policy.macie_policy.arn
}
