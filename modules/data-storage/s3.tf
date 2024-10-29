# S3 Bucket for Fargate Raw Data to be used by SageMaker
resource "aws_s3_bucket" "insurance_bucket" {
    bucket = "insurance-bucket-talha"

    tags = local.s3_insurance_tags
}




# Bucket Key for Cost Optimisation
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_key" {
  bucket = aws_s3_bucket.insurance_bucket.id

  rule {
    bucket_key_enabled = true
  }  
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "insurance" {
  bucket = aws_s3_bucket.insurance_bucket.id

  block_public_acls = true
  block_public_policy = true 
  ignore_public_acls = true 
  restrict_public_buckets = true 
}

# Lifecycle Rule for Insurance Bucket
resource "aws_s3_bucket_lifecycle_configuration" "insurance_config" {
    bucket = aws_s3_bucket.insurance_bucket.id

    rule {
        id = "insurance-archiving"

        filter {
            and {
                prefix = "raw-insurance-data/"
                tags = {
                    archive = "true"
                    datalife = "long"
                }
            }
        }
        status = "Enabled"

        transition {
          days = 30
          storage_class = "INTELLIGENT_TIERING"
        }

        transition {
            days = 180
            storage_class = "GLACIER"
        }
    }
}

# Enable S3 Versioning for Insurance Raw Data Bucket
resource "aws_s3_bucket_versioning" "insurance_bucket_versioning" {
  bucket = aws_s3_bucket.insurance_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket for SageMaker Training Data and Model Artifacts
resource "aws_s3_bucket" "sagemaker_model_artifacts" {
  bucket = "sagemaker-model-artifacts-talha"

  tags = local.s3_sagemaker_tags
}

resource "aws_s3_object" "training_data" {
  bucket = aws_s3_bucket.sagemaker_model_artifacts.bucket
  key = "training-data/mock_insurance_metrics.csv"
  source = "path/to/mock_insurance_metrics.csv"
  acl = "private"
}

resource "aws_s3_object" "trained_model_output" {
  bucket = aws_s3_bucket.sagemaker_model_artifacts.bucket
  key = "trained-models/"
  acl = "private"  
}


# Bucket Key for Cost Optimisation
resource "aws_s3_bucket_server_side_encryption_configuration" "sagemaker_bucket_key" {
  bucket = aws_s3_bucket.sagemaker_model_artifacts.id

  rule {
    bucket_key_enabled = true
  }  
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "sagemaker" {
  bucket = aws_s3_bucket.sagemaker_model_artifacts.id

  block_public_acls = true
  block_public_policy = true 
  ignore_public_acls = true 
  restrict_public_buckets = true 
}


# Lifecycle Rule for Training Data and Model Artifacts
resource "aws_s3_bucket_lifecycle_configuration" "sagemaker_model_artifacts_config" {
  bucket = aws_s3_bucket.sagemaker_model_artifacts.id

  rule {
    id = "sagemaker-model-artifacts-archiving"

    filter {
      and {
        prefix = "training-data-and-artifacts/"
        tags = {
          archive  = "true"
          datalife = "long"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
}


# Enable S3 Training Data and Model Artifacts Bucket Versioning
resource "aws_s3_bucket_versioning" "historical_sagemaker_versioning" {
  bucket = aws_s3_bucket.sagemaker_model_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket to store CodePipeline Artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "codepipeline-artifacts-talha"

  tags = local.s3_pipeline_tags
}


# Bucket Key for Cost Optimisation
resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_bucket_key" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  rule {
    bucket_key_enabled = true
  }  
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  block_public_acls = true
  block_public_policy = true 
  ignore_public_acls = true 
  restrict_public_buckets = true 
}


# Lifecycle Rule for CodePipeline
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_config" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  rule {
    id = "codepipeline-archiving"

    filter {
      and {
        prefix = "codepipeline-artifacts/"
        tags = {
          archive  = "true"
          datalife = "long"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
}


# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "codepipeline_artifacts_versioning" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket for Athena Query Results
resource "aws_s3_bucket" "athena_results" {
  bucket = "insurance-athena-results"

  tags = merge(var.base_tags, {
    Service = "athena"
    Type = "query-results"
  })
}

# Bucket Key for Cost Optimisation
resource "aws_s3_bucket_server_side_encryption_configuration" "athena_bucket_key" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    bucket_key_enabled = true
  }  
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "athena" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls = true
  block_public_policy = true 
  ignore_public_acls = true 
  restrict_public_buckets = true 
}


# Lifecycle Rule for Athena
resource "aws_s3_bucket_lifecycle_configuration" "athena_config" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id = "athena-archiving"

    filter {
      and {
        prefix = "athena-results/"
        tags = {
          archive  = "true"
          datalife = "long"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
}

# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "athena_results_versioning" {
  bucket = aws_s3_bucket.athena_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

# VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_rt_id
}

