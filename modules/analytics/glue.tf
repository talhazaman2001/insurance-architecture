# Glue Catalog Database
resource "aws_glue_catalog_database" "insurance_claims" {
    name = "insurance-claims-db"
}

# Glue Crawler
resource "aws_glue_crawler" "insurance_claims_data" {
    database_name = aws_glue_catalog_database.insurance_claims.name
    name = "insurance-claims-crawler"
    role = var.glue_role_arn

    s3_target {
      path = "s3://${var.insurance_bucket_id}/claims/"
    }

    schedule = "cron(0 */6 * * ? *)" # Run every 6 hours

    tags = merge(var.base_tags, {
        Service = "glue"
        Type = "crawler"
    })
}

