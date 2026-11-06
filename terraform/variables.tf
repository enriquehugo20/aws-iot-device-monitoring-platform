
variable "aws_region" {
  description = "AWS deployment region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier."
  type        = string
  default     = "aws-iot-device-monitoring"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "device_ids" {
  description = "IoT device identifiers."
  type        = list(string)

  default = [
    "sensor-001",
    "sensor-002"
  ]
}
