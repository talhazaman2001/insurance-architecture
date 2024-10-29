# DynamoDB Table for Insurance Claims
resource "aws_dynamodb_table" "insurance_claims" {
    name = "insurance-claims"
    billing_mode = "PROVISIONED"
    read_capacity = "5"
    write_capacity = "5"
    hash_key = "claim_id"
    range_key = "policy_id"
    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    attribute {
      name = "claim_id"
      type = "S"
    }

    attribute {
      name = "policy_id"
      type = "S"
    }

    point_in_time_recovery {
      enabled = true
    }

    tags = merge(var.base_tags, {
        Service = "dynamo-db"
        Type = "claims-data"
    })
}

# Auto Scaling
resource "aws_appautoscaling_target" "claims_read_target" {
    max_capacity = 100
    min_capacity = 5
    resource_id = "table/${aws_dynamodb_table.insurance_claims.name}"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace = "dynamodb"
}

resource "aws_appautoscaling_policy" "claims_read_policy" {
    name = "DynamoDBReadCapacityUtilization"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.claims_read_target.resource_id
    scalable_dimension = aws_appautoscaling_target.claims_read_target.scalable_dimension
    service_namespace = aws_appautoscaling_target.claims_read_target.service_namespace

    target_tracking_scaling_policy_configuration {
      predefined_metric_specification {
        predefined_metric_type = "DynamoDBReadCapacityUtilization"
      }
      target_value = 70
    }
}

resource "aws_appautoscaling_target" "claims_write_target" {
    max_capacity = 100
    min_capacity = 5
    resource_id = "table/${aws_dynamodb_table.insurance_claims.name}"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace = "dynamodb"
}

resource "aws_appautoscaling_policy" "claims_write_policy" {
    name = "DynamoDBWriteCapacityUtilization"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.claims_write_target.resource_id
    scalable_dimension = aws_appautoscaling_target.claims_write_target.scalable_dimension
    service_namespace = aws_appautoscaling_target.claims_write_target.service_namespace

    target_tracking_scaling_policy_configuration {
      predefined_metric_specification {
        predefined_metric_type = "DynamoDBWriteCapacityUtilization"
      }
      target_value = 70
    }
}