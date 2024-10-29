# AWS Shield Advanced for CloudFront
resource "aws_shield_protection" "cloudfront_protection" {  
    name = "cloudfront-shield-advanced"
    resource_arn = var.cdn_arn
    tags = local.shield_tags
}

# AWS Shield Advanced for ALB
resource "aws_shield_protection" "alb_protection" {
    name = "alb-shield-advanced"
    resource_arn = var.fargate_alb_arn
    tags = local.shield_tags
}

# AWS Shield Advanced for Route 53
resource "aws_shield_protection" "route53_protection" {
    name = "route53-shield-advanced"
    resource_arn = var.route53_zone_arn
    tags = local.shield_tags
}

