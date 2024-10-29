data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create IoT Thing 
resource "aws_iot_thing" "vehicle_telematics" {
    name = "vehicle-telematics"
}

# Create IoT Thing
resource "aws_iot_thing" "home_sensor" {
    name = "home-sensor"
}

# Set IoT Client IDs and Topics
variable "vehicle_telematics_client_id" {
    default = "vehicle-telematics"
}

variable "home_sensor_client_id" {
    default = "home-sensor"
}

variable "vehicle_telematics_topic" {
    default = "iot/device/vehicle-telematics/data"
}

variable "home_sensor_topic" {
    default = "iot/device/home-sensor/data"
}

# IoT Policy for IoT Thing to interact with IoT Core
resource "aws_iot_policy" "iot_device_policy" {
    name = "iot-device-policy-talha"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "iot:Publish",
                    "iot:Subscribe",
                    "iot:Receive",
                    "iot:Connect"
                ],
                Resource = [
                    "arn:aws:iot:eu-west-2:${data.aws_caller_identity.current.account_id}:topic/${var.vehicle_telematics_topic}",
                    "arn:aws:iot:eu-west-2:${data.aws_caller_identity.current.account_id}:topic/${var.home_sensor_topic}",
                    "arn:aws:iot:eu-west-2:${data.aws_caller_identity.current.account_id}:client/${var.vehicle_telematics_client_id}",
                    "arn:aws:iot:eu-west-2:${data.aws_caller_identity.current.account_id}:client/${var.vehicle_telematics_client_id}"
                ]
            }
        ]
    })
}

# IAM Role for IoT Core
resource "aws_iam_role" "iot_core_role" {
    name = "iot_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "iot.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# IAM Policy for IoT Core to send data to Kinesis
resource "aws_iam_policy" "iot_kinesis_policy" {
    name =  "iot_kinesis_policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            Resource = var.kinesis_stream_arn
        }]
    })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "iot_kinesis_attach" {
    role = aws_iam_role.iot_core_role.name
    policy_arn = aws_iam_policy.iot_kinesis_policy.arn
}


# Create IoT certificate to allow IoT Thing secure communication with IoT Core
resource "aws_iot_certificate" "iot_cert" {
    active = true
}

# Attach Certificate to IoT Thing and Policy
resource "aws_iot_thing_principal_attachment" "iot_thing_vehicle_telematics_attachment" {
    thing = aws_iot_thing.vehicle_telematics.name
    principal = aws_iot_certificate.iot_cert.arn
}

resource "aws_iot_thing_principal_attachment" "iot_thing_home_sensor_attachment" {
    thing = aws_iot_thing.home_sensor.name
    principal = aws_iot_certificate.iot_cert.arn
}

resource "aws_iot_policy_attachment" "iot_policy_attachment" {
    policy = aws_iot_policy.iot_device_policy.name
    target = aws_iot_certificate.iot_cert.arn
}

# IoT Topic Rule to route Vehicle Telematics data from IoT Core to Kinesis
resource "aws_iot_topic_rule" "vehicle_telematics_iot_rule" {
    name = "vehicle_telematics_iot_rule"
    description = "Rule to send Vehicle Telematics IoT data to Kinesis"
    sql = "SELECT * FROM 'iot/device/vehicle-telematics/data'"
    sql_version = "2016-03-23"
    enabled = true

    kinesis {
      stream_name = var.kinesis_stream_arn
      role_arn = aws_iam_role.iot_core_role.arn
    }
}

# IoT Topic Rule to route Home Sensor data from IoT Core to Kinesis
resource "aws_iot_topic_rule" "home_sensor_iot_rule" {
    name = "home_sensor_iot_rule"
    description = "Rule to send Home Sensor IoT data to Kinesis"
    sql = "SELECT * FROM 'iot/device/home-sensor/data'"
    sql_version = "2016-03-23"
    enabled = true

    kinesis {
      stream_name = var.kinesis_stream_arn
      role_arn = aws_iam_role.iot_core_role.arn
    }
}

