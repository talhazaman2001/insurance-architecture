# VPC
output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_interface_endpoint_sg_id" {
  value = aws_security_group.endpoint_sg.id
}

output "private_rt_id" {
  value = aws_route_table.private_rt.id
}

# ALB
output "fraud_detection_engine_blue_tg_arn" {
  value = aws_lb_target_group.fraud_detection_engine_blue_tg.arn
  description = "ARN of the Fargate ALB Blue Target Group for Fraud Detection Engine"
}

output "risk_assessment_service_blue_tg_arn" {
  value = aws_lb_target_group.risk_assessment_service_blue_tg.arn
  description = "ARN of the Fargate ALB Blue Target Group for Risk Assessment Service"
}

output "claims_processing_service_blue_tg_arn" {
  value = aws_lb_target_group.claims_processing_service_blue_tg.arn
  description = "ARN of the Fargate ALB Blue Target Group for Claims Processing Service"
}

output "fargate_alb_arn" {
  value = aws_lb.fargate_alb.arn
  description = "ARN of the Fargate ALB"
}

output "fargate_alb_listener_arn" {
  value = aws_lb_listener.fargate_listener.arn
}

# CloudFront
output "cdn_arn" {
  value = aws_cloudfront_distribution.cdn.arn  
}

# Route53
output "route53_zone_arn" {
  value = aws_route53_zone.my_zone.arn
}