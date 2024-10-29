# Create VPC Link configured with Private Subnets
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
    name = "vpclink-toapigw-to-alb"
    security_group_ids = [var.alb_sg_id]
    subnet_ids = var.private_subnets
    tags = local.api_gateway_tags
}

# Enable CloudWatch for API Gateway
resource "aws_api_gateway_account" "main" {
    cloudwatch_role_arn = var.api_gateway_role_arn

    depends_on = [var.api_gateway_attach]
}

# API Gateway HTTP Endpoint to route traffic to ALB
resource "aws_apigatewayv2_api" "http_api" {
    name = "CloudFronttoALBAPI"
    protocol_type = "HTTP"
    tags = local.api_gateway_tags
}

# ALB Integration with API Gateway
resource "aws_apigatewayv2_integration" "alb_integration" {
    api_id = aws_apigatewayv2_api.http_api.id
    integration_type = "HTTP_PROXY"
    integration_uri = var.fargate_alb_listener_arn

    integration_method = "ANY"
    connection_type = "VPC_LINK"
    connection_id = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
    payload_format_version = "1.0"
    depends_on = [
        aws_apigatewayv2_api.http_api,
        aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb,
        var.fargate_alb_listener_arn
    ]
}

# Route for Fraud Detection Engine
resource "aws_apigatewayv2_route" "fraud_detection_engine_route" {
    api_id = aws_apigatewayv2_api.http_api.id
    route_key = "ANY /fraud-detection-engine/{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# Route for Risk Assessment Service
resource "aws_apigatewayv2_route" "risk_assessment_service_route" {
    api_id = aws_apigatewayv2_api.http_api.id
    route_key = "ANY /risk-assessment-service/{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

# Route for Claims Processing Service
resource "aws_apigatewayv2_route" "claims_processing_service_route" {
    api_id = aws_apigatewayv2_api.http_api.id
    route_key = "ANY /claims-processing-service/{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}


# API Gateway Stage (Deploy)
resource "aws_apigatewayv2_stage" "api_stage" {
    api_id = aws_apigatewayv2_api.http_api.id
    name = "prod"
    auto_deploy = true

    default_route_settings {
      logging_level = "INFO"
      data_trace_enabled = true
      detailed_metrics_enabled = true 
    }

    tags = local.api_gateway_tags
}
