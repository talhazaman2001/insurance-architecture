# WAF Web ACL for CloudFront
    resource "aws_wafv2_web_acl" "global_insurance" {
    name = "global-insurance-waf"
    scope = "CLOUDFRONT"

    default_action {
      allow {}
    }

    # Rate Limiting
    rule {
        name = "RateLimit"
        priority = 1

        override_action {
          none{}
        }

        statement {
          rate_based_statement {
            limit = 2000
            aggregate_key_type = "IP"
          }
        }

        visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "RateLimitMetric"
          sampled_requests_enabled = true
        }
    }

    # Prevent SQL Injection
    rule {
        name = "SQLInjectionRule"
        priority = 2

        override_action {
          none {}
        }

        statement {
          sqli_match_statement {
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type = "HTML_ENTITY_DECODE"
            }
          }
        }

        visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "SQLInjectionMetric"
          sampled_requests_enabled = true
        }
    }

    # Geographic Restrictions
    rule {
        name = "GeoBlockRule"
        priority = 3

        override_action {
            none {}
        }

        statement {
            geo_match_statement {
                country_codes = ["NK", "IR", "CU"] # Random Countries to block
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name = "GeoBlockMetric"
            sampled_requests_enabled = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "GlobalInsuranceWAFMetrics"
        sampled_requests_enabled = true 
    }
}


