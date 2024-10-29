# Configure Route 53
resource "aws_route53_zone" "my_zone" {
    name = "api-example-insurance.com"
}


resource "aws_route53_record" "cloudfront_record" {
    zone_id = aws_route53_zone.my_zone.zone_id
    name = "api.example-insurance.com"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.cdn.domain_name
        zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
        evaluate_target_health = false
    }
}

