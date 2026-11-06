
resource "aws_dynamodb_table" "devices" {
  name         = "${var.project_name}-devices"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "device_id"

  attribute {
    name = "device_id"
    type = "S"
  }

  tags = local.common_tags
}
