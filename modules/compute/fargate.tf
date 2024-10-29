# Define the ECS Cluster
resource "aws_ecs_cluster" "insurance_cluster" {
  name = "insurance-cluster"
}


# Network Security
resource "aws_security_group" "fargate_tasks_sg" {
    name = "fargate-tasks-sg"
    description = "Security Group for Fargate Tasks"
    vpc_id = var.vpc_id

    # Only allow inbound from ALB
    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        security_groups = [var.alb_sg_id]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}

# Fargate Task Definition for Fraud Detection Engine
resource "aws_ecs_task_definition" "fraud_detection_engine_task" {
    family = "fraud-detection-engine-task"
    execution_role_arn = var.fargate_execution_role_arn
    task_role_arn = var.fargate_task_role_arn
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "1024"
    memory = "2048"

    container_definitions = jsonencode([
        {
            name = "fraud-detection-engine"
            image = "${var.repository_urls["fraud_detection"]}:latest"

            portMappings = [{
            containerPort = 8000
            protocol = "tcp"
            }]

            environment = [
                {name = "DYNAMODB_TABLE", value = var.dynamodb_table_name},
                {name = "AURORA_HOST", value = var.aurora_endpoint},
                {name = "S3_BUCKET", value = var.insurance_bucket_id}
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = "aws/fargate/fraud-detection-engine"
                    "awslogs-region" = "eu-west-2"
                    "awslogs-stream-prefix" = "risk"
                }
            }    
        },
        {
            name = "xray-daemon"
            image = "amazon/aws-xray-daemon"
            essential = false
            portMappings = [
                {
                    containerPort = 2000
                    protocol = "udp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = var.xray_log_group_arn
                    "awslogs-region" = "eu-west-2"
                    "awslogs-stream-prefix" = "xray"
                }
            }
        }
    ])

    tags = merge(var.base_tags, {
        Service = "fraud-detection-engine"
    })
}

# Fargate Task Definition for Risk Assessment Service
resource "aws_ecs_task_definition" "risk_assessment_service_task" {
    family = "risk-assessment-service-task"
    execution_role_arn = var.fargate_execution_role_arn
    task_role_arn = var.fargate_task_role_arn
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "1024"
    memory = "2048"

    container_definitions = jsonencode([
        {
            name = "risk-assessment-service"
            image = "${var.repository_urls["risk_assessment"]}:latest"

            portMappings = [{
            containerPort = 8000
            protocol = "tcp"
            }]

            environment = [
                {name = "DYNAMODB_TABLE", value = var.dynamodb_table_name},
                {name = "AURORA_HOST", value = var.aurora_endpoint},
                {name = "S3_BUCKET", value = var.insurance_bucket_id}
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = "aws/fargate/risk-assessment-service"
                    "awslogs-region" = "eu-west-2"
                    "awslogs-stream-prefix" = "risk"
                }
            }    
        },
        {
            name = "xray-daemon"
            image = "amazon/aws-xray-daemon"
            essential = false
            portMappings = [
                {
                    containerPort = 2000
                    protocol = "udp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = var.xray_log_group_arn
                    "awslogs-region" = "eu-west-2"
                    "awslogs-stream-prefix" = "xray"
                }
            }
        }
    ])

    tags = merge(var.base_tags, {
        Service = "risk-assessment-service"
    })
}

# Fargate Task Definition for Claims Processing Service
resource "aws_ecs_task_definition" "claims_processing_service_task" {
    family = "claims-processing-service-task"
    execution_role_arn = var.fargate_execution_role_arn
    task_role_arn = var.fargate_task_role_arn
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "1024"
    memory = "2048"

    container_definitions = jsonencode([
        {
            name = "claims-processing-service"
            image = "${var.repository_urls["claims_processing"]}:latest"

            portMappings = [{
            containerPort = 8000
            protocol = "tcp"
            }]

            environment = [
                {name = "DYNAMODB_TABLE", value = var.dynamodb_table_name},
                {name = "AURORA_HOST", value = var.aurora_endpoint},
                {name = "S3_BUCKET", value = var.insurance_bucket_id}
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = "aws/fargate/claims-processing-service"
                    "awslogs-region" = "eu-west-2"
                    "awslogs-stream-prefix" = "risk"
                }
            }    
        },
        {
            name = "xray-daemon"
            image = "amazon/aws-xray-daemon"
            essential = false
            portMappings = [
                {
                    containerPort = 2000
                    protocol = "udp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = var.xray_log_group_arn
                    "awslogs-region" = "eu-west-2"
                    "awslogs-stream-prefix" = "xray"
                }
            }
        }
    ])

    tags = merge(var.base_tags, {
        Service = "claims-processing-service"
    })
}

# Define the 3 Fargate Services
resource "aws_ecs_service" "fraud_detection_engine" {
    name = "fraud-detection-engine"
    cluster = aws_ecs_cluster.insurance_cluster.id
    task_definition = aws_ecs_task_definition.fraud_detection_engine_task.arn
    launch_type = "FARGATE"
    desired_count = 1

    deployment_controller {
      type = "CODE_DEPLOY"
    }

    load_balancer {
        target_group_arn = var.fraud_detection_engine_blue_tg_arn
        container_name = "fraud-detection-engine"
        container_port = 80
    }

    network_configuration {
      subnets = var.private_subnets
      security_groups = [aws_security_group.fargate_tasks_sg.id]
      assign_public_ip = false
    }

    tags = merge(var.base_tags, {
        Service = "fraud-detection-engine"
        Type = "ecs-service"
        Layer = "compute"
    })
}

resource "aws_ecs_service" "risk_assessment_service" {
    name = "risk-assessment-service"
    cluster = aws_ecs_cluster.insurance_cluster.id
    task_definition = aws_ecs_task_definition.risk_assessment_service_task.arn
    launch_type = "FARGATE"
    desired_count = 1

    deployment_controller {
      type = "CODE_DEPLOY"
    }

    load_balancer {
        target_group_arn = var.risk_assessment_service_blue_tg_arn
        container_name = "risk-assessment-service"
        container_port = 80
    }

    network_configuration {
      subnets = var.private_subnets
      security_groups = [aws_security_group.fargate_tasks_sg.id]
      assign_public_ip = false
    }

    tags = merge(var.base_tags, {
        Service = "risk-assessment-service"
        Type = "ecs-service"
        Layer = "compute"
    })
}

resource "aws_ecs_service" "claims_processing_service" {
    name = "claims-processing-service"
    cluster = aws_ecs_cluster.insurance_cluster.id
    task_definition = aws_ecs_task_definition.claims_processing_service_task.arn
    launch_type = "FARGATE"
    desired_count = 1

    deployment_controller {
      type = "CODE_DEPLOY"
    }

    load_balancer {
        target_group_arn = var.claims_processing_service_blue_tg_arn
        container_name = "claims-processing-service"
        container_port = 80
    }

    network_configuration {
      subnets = var.private_subnets
      security_groups = [aws_security_group.fargate_tasks_sg.id]
      assign_public_ip = false
    }

    tags = merge(var.base_tags, {
        Service = "claims-processing-service"
        Type = "ecs-service"
        Layer = "compute"
    })
}

