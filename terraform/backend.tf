
terraform {
  backend "s3" {
    bucket       = "aws-iot-device-monitoring-tfstate-276846898236"
    key          = "aws-iot-device-monitoring/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
