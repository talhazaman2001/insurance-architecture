# Define Locals for CodeBuild
locals {
  common_build_config = {
    build_timeout = 30
    compute_type = "BUILD_GENERAL1_SMALL"
    container_image = "aws/codebuild/standard:5.0"
    github_repo = "https://github.com/talhazaman2001/insurance-architecture.git"
  }

  services = {
    fraud-detection-engine = {
        name = "FraudDetectionEngineBuild"
        buildspec = "cicd/fraud-buildspec/buildspec.yml"
    }
    risk-assessment-service = {
        name = "RiskAssessmentServiceBuild"
        buildspec = "cicd/risk-buildspec/buildspec.yml"
    }
    claims-processing-service = {
        name = "ClaimsProcessingServiceBuild"
        buildspec = "cicd/claims-buildspec/buildspec.yml"
    }
  }
}

# Create CodeBuild Projects
resource "aws_codebuild_project" "microservices_build" {
    for_each = local.services
    
    name = each.value.name
    service_role = aws_iam_role.codebuild_role.arn
    build_timeout = local.common_build_config.build_timeout

    source {
      type = "GITHUB"
      location = local.common_build_config.github_repo
      buildspec = each.value.buildspec
      git_clone_depth = 1
    }

    artifacts {
      type = "S3"
      location = var.codepipeline_artifacts_bucket
      encryption_disabled = false
    }

    environment {
      compute_type = local.common_build_config.compute_type
      image = local.common_build_config.container_image
      type = "LINUX_CONTAINER"
      privileged_mode = true

      environment_variable {
        name = "AWS_DEFAULT_REGION"
        value = "eu-west-2"
      }

      environment_variable {
        name = "ECR_REGISTRY"
        value = "463470963000.dkr.ecr.eu-west-2.amazonaws.com"
      }

      environment_variable {
        name = "ECR_REPOSITORY"
        value = "${each.key}"
      }
    }  

    cache {
      type = "LOCAL"
      modes = ["LOCAL_DOCKER_LAYER_CACHE"]
    } 
}

# Create CodeDeploy Application
resource "aws_codedeploy_app" "codedeploy_app" {
    name = "insurance-microservices"
    compute_platform = "ECS"
}

# Deployment Group for Fraud Detection Engine
resource "aws_codedeploy_deployment_group" "fraud_detection_deployment_group" {
    app_name = aws_codedeploy_app.codedeploy_app.name
    deployment_group_name = "FraudDetectionBlueGreenDeploymentGroups"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }

    blue_green_deployment_config {
      deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
      }

      terminate_blue_instances_on_deployment_success {
        action = "TERMINATE"
        termination_wait_time_in_minutes = 5
      }
    }

    load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.fargate_alb_listener_arn]
        }

        target_group {
          name = var.fraud_detection_engine_blue_tg_arn
        }

        target_group {
          name = var.fraud_detection_engine_green_tg_arn
        }
      }
    }

    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

    ecs_service {
      cluster_name = var.ecs_cluster_name
      service_name = var.service_names["fraud_detection"]
    }
}

# Deployment Group for Risk Assessment Service
resource "aws_codedeploy_deployment_group" "risk_assessment_deployment_group" {
    app_name = aws_codedeploy_app.codedeploy_app.name
    deployment_group_name = "RiskAssessmentBlueGreenDeploymentGroups"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }

    blue_green_deployment_config {
      deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
      }

      terminate_blue_instances_on_deployment_success {
        action = "TERMINATE"
        termination_wait_time_in_minutes = 5
      }
    }

    load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.fargate_alb_listener_arn]
        }

        target_group {
          name = var.risk_assessment_service_blue_tg_arn
        }

        target_group {
          name = var.risk_assessment_service_green_tg_arn
        }
      }
    }

    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

    ecs_service {
      cluster_name = var.ecs_cluster_name
      service_name = var.service_names["risk_assessment"]
    }
}

# Deployment Group for Claims Processing Service
resource "aws_codedeploy_deployment_group" "claims_processing_deployment_group" {
    app_name = aws_codedeploy_app.codedeploy_app.name
    deployment_group_name = "ClaimsProcessingBlueGreenDeploymentGroups"
    service_role_arn = aws_iam_role.codedeploy_role.arn 

    auto_rollback_configuration {
      enabled = true
      events = ["DEPLOYMENT_FAILURE"]
    }

    deployment_style {
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN"
    }

    blue_green_deployment_config {
      deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
      }

      terminate_blue_instances_on_deployment_success {
        action = "TERMINATE"
        termination_wait_time_in_minutes = 5
      }
    }

    load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.fargate_alb_listener_arn]
        }

        target_group {
          name = var.claims_processing_service_blue_tg_arn
        }

        target_group {
          name = var.claims_processing_service_green_tg_arn
        }
      }
    }

    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

    ecs_service {
      cluster_name = var.ecs_cluster_name
      service_name = var.service_names["claims_processing"]
    }
}

# Create CodeStar Connection
resource "aws_codestarconnections_connection" "github_connection" {
    name = "my-github-connection"
    provider_type = "GitHub"
}

# CodePipeline to automate Fraud Detection deployment process
resource "aws_codepipeline" "fraud_detection" {
    name = "fraud-detection-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
      type = "S3"
      location = "${var.codepipeline_artifacts_bucket}"
    }

    stage {
        name = "Source"
        
        action {
            name = "GitHubSource"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["SourceOutput"]
            configuration = {
                ConnectionArn = "arn:aws:codestar-connections:eu-west-2:463470963000:connection/5bcc636d-e780-4617-a94e-957c222cf902"
                FullRepositoryId = "talhazaman2001/insurance-architecture"
                BranchName = "main"
            }
        }
    }

    stage {
        name = "Build"

        action {
          name = "Build"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          input_artifacts = ["SourceOutput"]
          output_artifacts = ["BuildOutput"]
          configuration = {
            ProjectName = aws_codebuild_project.microservices_build["fraud-detection-engine"].name
          }
        }
    }

    stage {
        name = "Deploy"

        action {
          name = "Deploy"
          category = "Deploy"
          owner = "AWS"
          provider = "CodeDeployToECS"
          input_artifacts = ["BuildOutput"]
          version = "1"

          configuration = {
            ApplicationName = aws_codedeploy_app.codedeploy_app.name
            DeploymentGroupName = aws_codedeploy_deployment_group.fraud_detection_deployment_group.deployment_group_name
            TaskDefinitionTemplateArtifact = "BuildOutput"
            AppSpecTemplateArtifact = "BuildOutput"
            AppSpecTemplatePath = "cicd/fraud-appspec/appspec.yml"
            TaskDefinitionTemplatePath = "services/fraud-detection-engine/taskdef.json"
          }
        }
    }
}

# CodePipeline to automate Risk Assessment deployment process
resource "aws_codepipeline" "risk_assessment" {
    name = "risk-assessment-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
      type = "S3"
      location = "${var.codepipeline_artifacts_bucket}"
    }

    stage {
        name = "Source"
        
        action {
            name = "GitHubSource"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["SourceOutput"]
            configuration = {
                ConnectionArn = "arn:aws:codestar-connections:eu-west-2:463470963000:connection/5bcc636d-e780-4617-a94e-957c222cf902"
                FullRepositoryId = "talhazaman2001/insurance-architecture"
                BranchName = "main"
            }
        }
    }

    stage {
        name = "Build"

        action {
          name = "Build"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          input_artifacts = ["SourceOutput"]
          output_artifacts = ["BuildOutput"]
          configuration = {
            ProjectName = aws_codebuild_project.microservices_build["risk-assessment-service"].name
          }
        }
    }

    stage {
        name = "Deploy"

        action {
          name = "Deploy"
          category = "Deploy"
          owner = "AWS"
          provider = "CodeDeployToECS"
          input_artifacts = ["BuildOutput"]
          version = "1"

          configuration = {
            ApplicationName = aws_codedeploy_app.codedeploy_app.name
            DeploymentGroupName = aws_codedeploy_deployment_group.risk_assessment_deployment_group.deployment_group_name
            TaskDefinitionTemplateArtifact = "BuildOutput"
            AppSpecTemplateArtifact = "BuildOutput"
            AppSpecTemplatePath = "cicd/risk-appspec/appspec.yml"
            TaskDefinitionTemplatePath = "services/risk-assessment-service/taskdef.json"
          }
        }
    }
}

# CodePipeline to automate Claims Processing deployment process
resource "aws_codepipeline" "claims_processing" {
    name = "claims-processing-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
      type = "S3"
      location = "${var.codepipeline_artifacts_bucket}"
    }

    stage {
        name = "Source"
        
        action {
            name = "GitHubSource"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["SourceOutput"]
            configuration = {
                ConnectionArn = "arn:aws:codestar-connections:eu-west-2:463470963000:connection/5bcc636d-e780-4617-a94e-957c222cf902"
                FullRepositoryId = "talhazaman2001/insurance-architecture"
                BranchName = "main"
            }
        }
    }

    stage {
        name = "Build"

        action {
          name = "Build"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          input_artifacts = ["SourceOutput"]
          output_artifacts = ["BuildOutput"]
          configuration = {
            ProjectName = aws_codebuild_project.microservices_build["claims-processing-service"].name
          }
        }
    }

    stage {
        name = "Deploy"

        action {
          name = "Deploy"
          category = "Deploy"
          owner = "AWS"
          provider = "CodeDeployToECS"
          input_artifacts = ["BuildOutput"]
          version = "1"

          configuration = {
            ApplicationName = aws_codedeploy_app.codedeploy_app.name
            DeploymentGroupName = aws_codedeploy_deployment_group.claims_processing_deployment_group.deployment_group_name
            TaskDefinitionTemplateArtifact = "BuildOutput"
            AppSpecTemplateArtifact = "BuildOutput"
            AppSpecTemplatePath = "cicd/claims-appspec/appspec.yml"
            TaskDefinitionTemplatePath = "services/claims-procesing-service/taskdef.json"
          }
        }
    }
}

