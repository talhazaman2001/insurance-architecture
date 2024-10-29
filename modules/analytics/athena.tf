
# Athena Workgroup
resource "aws_athena_workgroup" "insurance_analytics" {
    name = "insurance-analytics"

    configuration {
        enforce_workgroup_configuration = true
        publish_cloudwatch_metrics_enabled = true

        result_configuration {
          output_location = "s3://${var.athena_results_bucket}/output/"

          encryption_configuration {
            encryption_option = "SSE_S3"
          }
        }
    }

    tags = merge(var.base_tags, {
        Service = "athena"
        Type = "analytics"
    })
}

# Athena Query
resource "aws_athena_named_query" "fraud_analysis" {
    name = "high-risk-claims-fraud-analysis"
    workgroup = aws_athena_workgroup.insurance_analytics.id
    database = aws_glue_catalog_database.insurance_claims.id
    description = "Analyse claims with high fraud risk scores"

    query = <<EOF
SELECT 
    claim_id,
    policy_id,
    claim_amount,
    risk_score,
    submission_date,
FROM claims_data
WHERE risk_score > 80
ORDER BY risk_score DESC
EOF
}
