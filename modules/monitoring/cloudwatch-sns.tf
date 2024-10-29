# SNS Topic for Alerts
resource "aws_sns_topic" "service_alerts" {
    name = "insurance-service-alerts"
    tags = var.base_tags
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email" {
    topic_arn = aws_sns_topic.service_alerts.arn
    protocol = "email"
    endpoint = "mtalhazamanb@gmail.com"
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
    name = "/aws/api-gateway"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "api-gateway"
        Type = "logs"
    })
}

# API Gateway Alarms
resource "aws_cloudwatch_metric_alarm" "api_gateway_errors" {
    alarm_name = "api-gateway-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "5XXError"
    namespace = "AWS/ApiGateway"
    period = "300"
    statistic = "Sum"
    threshold = "5"
    alarm_description = "API Gateway 5XX Errors"

    dimensions = {
      ApiID = var.api_gateway_id
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "api-gateway"
        Type = "alarm"
    })
}

# CloudWatch Log Group for ALB
resource "aws_cloudwatch_log_group" "alb" {
    name = "/aws/alb"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "alb"
        Type = "logs"
    })
}

# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "alb_errors" {
    alarm_name = "alb-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "HTTPCode_ELB_5XX_Count"
    namespace = "AWS/ELB"
    period = "300"
    statistic = "Sum"
    threshold = "5"
    alarm_description = "ALB 5XX Errors"

    dimensions = {
      LoadBalancer = var.fargate_alb_arn
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "alb"
        Type = "alarm"
    })
}


# CloudWatch Log Groups for Fargate Microservices
resource "aws_cloudwatch_log_group" "fraud_detection_engine" {
    name = "/aws/fargate/fraud-detection-engine"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "fraud-detection-engine"
        Type = "logs"
    })
}

resource "aws_cloudwatch_log_group" "risk_assessment_service" {
    name = "/aws/fargate/risk-assessment-service"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "risk-assessment-service"
        Type = "logs"
    })
}

resource "aws_cloudwatch_log_group" "claims_processing_service" {
    name = "/aws/fargate/claims-processing-service"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "claims-processing-service"
        Type = "logs"
    })
}

# CloudWatch Alarms for Fargate Microservices
resource "aws_cloudwatch_metric_alarm" "fraud_detection_engine_errors" {
    alarm_name = "fraud-detection-engine-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "HTTP_CODE_Target_5XX_Count"
    namespace = "AWS/ApplicationELB"
    period = "300"
    statistic = "Sum"
    threshold = "5"
    alarm_description = "HTTP 5XX errors for Fraud Detection Engine"

    dimensions = {
      TargetGroup = var.fraud_detection_engine_blue_tg_arn
      LoadBalancer = var.fargate_alb_arn
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "fraud-detection-engine"
        Type = "alarm"
    })
}

resource "aws_cloudwatch_metric_alarm" "risk_assessment_service_errors" {
    alarm_name = "risk-assessment-service-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "HTTP_CODE_Target_5XX_Count"
    namespace = "AWS/ApplicationELB"
    period = "300"
    statistic = "Sum"
    threshold = "5"
    alarm_description = "HTTP 5XX errors for Risk Assessment Service"

    dimensions = {
      TargetGroup = var.risk_assessment_service_blue_tg_arn
      LoadBalancer = var.fargate_alb_arn
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "risk-assessment-service"
        Type = "alarm"
    })
}

resource "aws_cloudwatch_metric_alarm" "claims_processing_service_errors" {
    alarm_name = "claims-processing-service-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "HTTP_CODE_Target_5XX_Count"
    namespace = "AWS/ApplicationELB"
    period = "300"
    statistic = "Sum"
    threshold = "5"
    alarm_description = "HTTP 5XX errors for Claims Processing Service"

    dimensions = {
      TargetGroup = var.claims_processing_service_blue_tg_arn
      LoadBalancer = var.fargate_alb_arn
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "claims-processing-service"
        Type = "alarm"
    })
}

# CPU/Memory Utilisation Alarms for Fargate Tasks
resource "aws_cloudwatch_metric_alarm" "service_cpu" {
    for_each = {
        fraud_detection_engine = "fraud-detection-engine"
        risk_assessment_service = "risk-assessment-service"
        claims_processing_service = "claims-processing-service"
    }

    alarm_name = "${each.value}-high.cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/ECS"
    period = "300"
    statistic = "Average"
    threshold = "85"
    alarm_description = "CPU Utilisation above 85% for ${each.value}"

    dimensions = {
      ClusterName = var.ecs_cluster_name
      ServiceName = each.value
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = each.value 
        Type = "alarm"
    })
}

# CloudWatch Log Group for Aurora
resource "aws_cloudwatch_log_group" "aurora" {
    name = "/aws/aurora"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "aurora"
        Type = "logs"
    })
}

# Aurora DB Alarms
resource "aws_cloudwatch_metric_alarm" "aurora_cpu" {
    alarm_name = "aurora-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/RDS"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "Aurora CPU Utilization above 80%"

    dimensions = {
      DBClusterIdentifier = var.aurora_cluster_arn
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "api-gateway"
        Type = "alarm"
    })
}

# CloudWatch Log Group for SageMaker
resource "aws_cloudwatch_log_group" "sagemaker" {
    name = "/aws/sagemaker"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "sagemaker"
        Type = "logs"
    })
}

# SageMaker Alarm 
resource "aws_cloudwatch_metric_alarm" "sagemaker_invocations" {
    alarm_name = "sagemaker-high-invocations"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "Invocations"
    namespace = "AWS/SageMaker"
    period = "300"
    statistic = "Sum"
    threshold = "1000"

    dimensions = {
      EndpointName = var.sagemaker_endpoint_name
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]

    tags = merge(var.base_tags, {
        Service = "sagemaker"
        Type = "alarms"
    })
}

# CloudWatch Log Group for WAF 
resource "aws_cloudwatch_log_group" "waf" {
    name = "/aws/waf"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "WAF"
        Type = "Logs"
    })
}

# WAF Alarm for Blocked Requests
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
    alarm_name = "waf-blocked-requests"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "BlockedRequests"
    namespace = "AWS/WAFV2"
    period = "300"
    statistic = "Sum"
    threshold = "100"
    alarm_description = "WAF Blocked Requests exceeded threshold"

    dimensions = {
      WEBACL = var.waf_web_acl_name
      Rule = "ALL"
      Region = "eu-west-2"
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "WAF"
        Type = "alarms"
    })
}

# WAF Alarm for Allowed Requests
resource "aws_cloudwatch_metric_alarm" "waf_allowed_requests" {
    alarm_name = "waf-allowed-requests"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "2"
    metric_name = "AllowedRequests"
    namespace = "AWS/WAFV2"
    period = "300"
    statistic = "Sum"
    threshold = "100"
    alarm_description = "Unusual Spike in Allowed Requests"

    dimensions = {
      WEBACL = var.waf_web_acl_name
      Rule = "ALL"
      Region = "eu-west-2"
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "WAF"
        Type = "alarms"
    })
}

# CloudWatch Log Group for Macie
resource "aws_cloudwatch_log_group" "macie" {
    name = "/aws/macie"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "WAF"
        Type = "Logs"
    })
}

# Macie Alarm for Sensitive Data Findings
resource "aws_cloudwatch_metric_alarm" "macie_findings" {
    alarm_name = "macie-sensitive-data-findings"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = "1"
    metric_name = "SensitiveDataDiscovered"
    namespace = "AWS/Macie"
    period = "300"
    statistic = "Sum"
    threshold = "0"
    alarm_description = "Macie discovered sensitive data"

    dimensions = {
      ClassificationJobId = var.classification_job_id
    }

    alarm_actions = [aws_sns_topic.service_alerts.arn]
    tags = merge(var.base_tags, {
        Service = "Macie"
        Type = "alarms"
    })
}

# CloudWatch Log Group for X-Ray
resource "aws_cloudwatch_log_group" "xray" {
    name = "/aws/xray"
    retention_in_days = 30
    tags = merge(var.base_tags, {
        Service = "xray"
        Type = "Logs"
    })
}
