# Configure CloudFront
resource "aws_cloudfront_distribution" "cdn" {
    origin {
        domain_name = replace(var.api_gateway_endpoint, "https://", "")
        origin_id = "APIGatewayOrigin"

        custom_origin_config {
          http_port = 80
          https_port = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols = ["TLSv1.2"]
        }
    }

    enabled = true
    default_root_object = ""

    default_cache_behavior {
      target_origin_id = "APIGatewayOrigin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods = ["GET", "HEAD", "OPTIONS"]

      forwarded_values {
        query_string = true
        cookies {
          forward = "none"
        }
      }

      min_ttl = 0
      default_ttl = 3600
      max_ttl = 86400
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    web_acl_id = var.waf_web_acl_id

    tags = local.cloudfront_tags
}

# CloudFront WAF Role
resource "aws_iam_role" "cloudfront_waf_role" {
 name = "cloudfront-waf-role"
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
 tags = local.cloudfront_tags
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
        Resource = var.waf_web_acl_arn
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

