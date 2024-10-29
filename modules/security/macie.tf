data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# Macie Configuration
resource "aws_macie2_account" "insurance" {
    finding_publishing_frequency = "FIFTEEN_MINUTES"
    status = "ENABLED"
}

# Enable Macie for S3 Bucket classification
resource "aws_macie2_classification_job" "s3_sensitive_data" {
    name = "insurance-data-classifcation"
    job_type = "SCHEDULED"
    job_status = "RUNNING"

    s3_job_definition {
      bucket_definitions {
        account_id = data.aws_caller_identity.current.account_id
        buckets = ["insurance-bucket-talha"]
      }
    }

    schedule_frequency {
      weekly_schedule = "MONDAY"
    }

    tags = merge(var.base_tags, {
        Service = "macie"
        Type = "classification-job"
    })
}

