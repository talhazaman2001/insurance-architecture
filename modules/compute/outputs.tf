# For API Gateway configuration

output "api_gateway_endpoint" {
 description = "HTTP API Gateway endpoint URL"
 value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_gateway_id" {
 description = "HTTP API Gateway ID"
 value       = aws_apigatewayv2_api.http_api.id
}

output "vpc_link_id" {
 description = "VPC Link ID"
 value       = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
}

output "api_gateway_stage_name" {
 description = "API Gateway stage name"
 value       = aws_apigatewayv2_stage.api_stage.name
}

# For Fargate/ECS configuration
output "ecs_cluster_id" {
 description = "ID of the ECS cluster"
 value       = aws_ecs_cluster.insurance_cluster.id
}

output "ecs_cluster_name" {
  description = "Name of ECS Cluster"
  value = aws_ecs_cluster.insurance_cluster.name  
}

output "ecs_cluster_arn" {
 description = "ARN of the ECS cluster"
 value       = aws_ecs_cluster.insurance_cluster.arn
}

output "fargate_tasks_sg_id" {
 description = "Security group ID for Fargate tasks"
 value       = aws_security_group.fargate_tasks_sg.id
}

output "service_names" {
 description = "Names of the ECS services"
 value = {
   fraud_detection = aws_ecs_service.fraud_detection_engine.name
   risk_assessment = aws_ecs_service.risk_assessment_service.name
   claims_processing = aws_ecs_service.claims_processing_service.name
 }
}

# For IoT configuration
output "iot_certificate_arn" {
 description = "ARN of IoT certificate"
 value       = aws_iot_certificate.iot_cert.arn
}

output "iot_policy_arn" {
 description = "ARN of IoT policy"
 value       = aws_iot_policy.iot_device_policy.arn
}

output "iot_role_arn" {
 description = "ARN of IoT Core role"
 value       = aws_iam_role.iot_core_role.arn
}

output "iot_things" {
 description = "Created IoT things"
 value = {
   vehicle_telematics = aws_iot_thing.vehicle_telematics.name
   home_sensor       = aws_iot_thing.home_sensor.name
 }
}
