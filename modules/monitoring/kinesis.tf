# Kinesis Stream to receive data from IoT Core
resource "aws_kinesis_stream" "iot_data_stream" {
    name = "iot-data-stream"
    shard_count = 50

    retention_period = 24
    shard_level_metrics = ["IncomingBytes", "IncomingRecords", "OutgoingBytes", "OutgoingRecords"]
    stream_mode_details {
      stream_mode = "PROVISIONED"
    }

    tags = {
        Name = "IoTDataStream"
    }
}

