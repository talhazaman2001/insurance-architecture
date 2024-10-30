# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
    name = "codepipeline-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "codepipeline.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# IAM Policy for CodePipeline to use CodeStarConnection
resource "aws_iam_policy" "codestar_connections_policy" {
    name        = "codestar-connections-policy"
    description = "Policy to allow CodePipeline to use CodeStar Connections"
    policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = "codestar-connections:UseConnection"
            Resource = "arn:aws:codestar-connections:*:*:connection/*"
        }]
    })
}

# IAM Policy for CodePipeline to upload artifacts to S3
resource "aws_iam_policy" "codepipeline_s3_access" {
    name = "codepipeline-s3-access-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            Resource = [
                var.codepipeline_artifacts_arn,        
                "${var.codepipeline_artifacts_arn}/*" 
            ]
        }]
    })
}

# IAM Policy for CodePipeline to create CodeDeploy Deployments
resource "aws_iam_policy" "codepipeline_codedeploy" {
    name = "codepipeline-codedeploy-policy"  

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentGroup",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetApplicationRevision"
            ],
            Resource = [
            "arn:aws:codedeploy:eu-west-2:463470963000:deploymentgroup:lambda-apps/*",
            "arn:aws:codedeploy:eu-west-2:463470963000:deploymentconfig:*",
            "arn:aws:codedeploy:eu-west-2:463470963000:application:lambda-apps*"
            ]
        }]
        
    })
}

# Attach IAM Policies to IAM Role

# CodePipeline
resource "aws_iam_role_policy_attachment" "codepipeline" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# CodeStar
resource "aws_iam_role_policy_attachment" "codestar_policy" {
    role       = aws_iam_role.codepipeline_role.name
    policy_arn = aws_iam_policy.codestar_connections_policy.arn
}

# CodePipeline to trigger CodeBuild
resource "aws_iam_role_policy_attachment" "codebuild_trigger" {
    role       = aws_iam_role.codepipeline_role.name 
    policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# CodePipeline to upload artifacts to S3 Bucket
resource "aws_iam_role_policy_attachment" "codepipeline_s3" {
    role       = aws_iam_role.codepipeline_role.name
    policy_arn = aws_iam_policy.codepipeline_s3_access.arn
}

# CodePipeline to create CodeDeploy Deployments
resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy" {
    role = aws_iam_role.codepipeline_role.name
    policy_arn = aws_iam_policy.codepipeline_codedeploy.arn
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
    name = "codebuild-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
            Service = "codebuild.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# IAM Policy for CodeBuild to create CloudWatch Logs
resource "aws_iam_policy" "codebuild_cloudwatch_policy" {
    name = "codebuild-cloudwatch-logs-policy"
    
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource = [
                "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/*",
                "arn:aws:logs:eu-west-2:463470963000:log-group:/aws/codebuild/*:*",
            ]
        }]
    })
}

# IAM Policy to allow CodeBuild to access S3 pipeline artifacts
resource "aws_iam_policy" "codebuild_s3_policy" {
    name = "codebuild-s3-access-policy"  

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            Resource = [
            var.codepipeline_artifacts_arn,        
            "${var.codepipeline_artifacts_arn}/*"
            ]
        }]
        
    })
}

# IAM Policy for CodeBuild to manage Fargate Microservices
resource "aws_iam_policy" "codebuild_fargate_update_policy" {
    name = "CodeBuildFargateUpdatePolicy"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage",
            "iam:PassRole"
            ],
            Resource = "*"
        }]
        
    })
}


# Attach IAM Policies to IAM Role

# CodeBuild
resource "aws_iam_role_policy_attachment" "codebuild" {
    role       = aws_iam_role.codebuild_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# CodeBuild CloudWatch Logs
resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch" {
    role       = aws_iam_role.codebuild_role.name
    policy_arn = aws_iam_policy.codebuild_cloudwatch_policy.arn
}

# CodeBuild access to S3 pipeline artifacts
resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

# CodeBuild to update Fargate Microservices
resource "aws_iam_role_policy_attachment" "codebuild_fargate_update_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_fargate_update_policy.arn
}

# IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
    name = "codedeploy-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "codedeploy.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# IAM Policy to allow CodeDeploy to manage Fargate Ddeployments
resource "aws_iam_policy" "codedeploy_fargate" {
  name = "codedeploy-fargate-policy"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Effect = "Allow",
            Action = [
                "s3:*"
            ]
            Resource = [
                var.codepipeline_artifacts_arn,        
                "${var.codepipeline_artifacts_arn}/*"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "ecs:UpdateService",
            "ecs:RegisterTaskDefinition",
            "ecs:DescribeServices",
            "ecs:DescribeTaskDefinition",
            "ecs:DescribeTasks",
            "iam:PassRole"
            ],
            Resource = "*"
        
        }
        ]
    })
}

# Attach IAM Polices to IAM Role
resource "aws_iam_role_policy_attachment" "codedeploy_fargate" {
    role = aws_iam_role.codedeploy_role.name
    policy_arn = aws_iam_policy.codedeploy_fargate.arn
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}