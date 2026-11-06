resource "aws_iot_thing" "sensors" {
  for_each = toset(var.device_ids)

  name = each.value

  attributes = {
    project     = var.project_name
    environment = var.environment
    device_type = "temperature-humidity-sensor"
  }
}