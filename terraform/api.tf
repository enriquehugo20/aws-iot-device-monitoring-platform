module "api" {
  source = "./modules/api"

  project_name = var.project_name
  table_name   = aws_dynamodb_table.devices.name
  table_arn    = aws_dynamodb_table.devices.arn
}

output "api_endpoint" {
  description = "HTTPS endpoint of the devices API."
  value       = module.api.api_endpoint
}