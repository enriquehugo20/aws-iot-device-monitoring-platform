output "api_endpoint" {
  description = "HTTPS endpoint of the devices API."
  value       = aws_apigatewayv2_api.http.api_endpoint
}