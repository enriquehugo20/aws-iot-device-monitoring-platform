resource "aws_iam_role" "iot_rules" {
  name = "${var.project_name}-iot-rules-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "iot_dynamodb_access" {
  name = "${var.project_name}-iot-dynamodb-access"
  role = aws_iam_role.iot_rules.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.devices.arn
      }
    ]
  })
}

resource "aws_iot_policy" "sensor_policy" {
  name = "${var.project_name}-sensor-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:*:client/$${iot:Connection.Thing.ThingName}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Publish"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:*:topic/devices/$${iot:Connection.Thing.ThingName}/telemetry",
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/get",
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Subscribe"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:*:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update/delta",
          "arn:aws:iot:${var.aws_region}:*:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update/accepted",
          "arn:aws:iot:${var.aws_region}:*:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update/rejected",
          "arn:aws:iot:${var.aws_region}:*:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/get/accepted",
          "arn:aws:iot:${var.aws_region}:*:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/get/rejected"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Receive"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update/delta",
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update/accepted",
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/update/rejected",
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/get/accepted",
          "arn:aws:iot:${var.aws_region}:*:topic/$aws/things/$${iot:Connection.Thing.ThingName}/shadow/get/rejected"
        ]
      }
    ]
  })
}