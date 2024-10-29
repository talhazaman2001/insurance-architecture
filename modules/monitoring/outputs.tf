# CloudWatch
output "api_gateway_log_group_arn" {
    description = "API Gateway CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.api_gateway.arn
}

output "alb_log_group_arn" {
    description = "ALB CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.alb.arn
}

output "fraud_detection_engine_log_group_arn" {
    description = "Fraud Detection CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.fraud_detection_engine.arn
}

output "risk_assessment_service_log_group_arn" {
    description = "Risk Assessment CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.risk_assessment_service.arn
}

output "claims_processing_service_log_group_arn" {
    description = "Claims Processing CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.claims_processing_service.arn
}

output "fraud_detection_engine_log_group_name" {
    description = "Fraud Detection CloudWatch Log Group Name"
    value = aws_cloudwatch_log_group.fraud_detection_engine.name
}

output "risk_assessment_service_log_group_name" {
    description = "Risk Assessment CloudWatch Log Group Name"
    value = aws_cloudwatch_log_group.risk_assessment_service.name
}

output "claims_processing_service_log_group_name" {
    description = "Claims Processing CloudWatch Log Group Name"
    value = aws_cloudwatch_log_group.claims_processing_service.name
}

output "aurora_log_group_arn" {
    description = "Aurora CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.aurora.arn
}

output "sagemaker_log_group_arn" {
    description = "SageMaker CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.sagemaker.arn
}

output "sns_topic_arn" {
    description = "SNS Topic ARN"
    value = aws_sns_topic.service_alerts.arn
}

output "kinesis_stream_arn" {
    description = "Kinesis Stream ARN"
    value = aws_kinesis_stream.iot_data_stream.arn
}

output "waf_log_group_arn" {
    description = "WAF Log Group ARN"
    value = aws_cloudwatch_log_group.waf.arn
}

output "macie_log_group_arn" {
    description = "Macie Log Group ARN"
    value = aws_cloudwatch_log_group.macie.arn
}

output "xray_log_group_arn" {
    description = "xray Log Group ARN"
    value = aws_cloudwatch_log_group.xray.arn
}