
resource "aws_iot_topic_rule" "telemetry" {
  name        = "device_telemetry"
  description = "Update device telemetry in DynamoDB"
  enabled     = true

  sql = <<-SQL
    SELECT
      temperature,
      humidity,
      measured_at,
      timestamp() AS received_at
    FROM 'devices/+/telemetry'
  SQL

  sql_version = "2016-03-23"

  dynamodb {
    table_name     = aws_dynamodb_table.devices.name
    hash_key_field = "device_id"
    hash_key_value = "$${topic(2)}"
    hash_key_type  = "STRING"
    payload_field  = "telemetry"
    operation      = "UPDATE"
    role_arn       = aws_iam_role.iot_rules.arn
  }
}

resource "aws_iot_topic_rule" "lifecycle" {
  name        = "device_lifecycle"
  description = "Update device connection status in DynamoDB"
  enabled     = true

  sql = <<-SQL
    SELECT
      eventType AS status,
      timestamp AS event_timestamp,
      timestamp() AS received_at
    FROM '$aws/events/presence/+/+'
  SQL

  sql_version = "2016-03-23"

  dynamodb {
    table_name     = aws_dynamodb_table.devices.name
    hash_key_field = "device_id"
    hash_key_value = "$${clientId}"
    hash_key_type  = "STRING"
    payload_field  = "device_status"
    operation      = "UPDATE"
    role_arn       = aws_iam_role.iot_rules.arn
  }
}