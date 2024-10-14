provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Create IoT Thing
resource "aws_iot_thing" "example_thing" {
  name = "my-iot-thing"
  
  attributes = {
    "environment" = "development"
    "version"     = "v1"
  }
}

# Create IoT Certificate
resource "aws_iot_certificate" "example_certificate" {
  active = true
}

# Attach the certificate to the IoT Thing
resource "aws_iot_thing_principal_attachment" "thing_cert_attachment" {
  thing       = aws_iot_thing.example_thing.name
  principal   = aws_iot_certificate.example_certificate.arn
}

# Output the certificate and key for later use
output "certificate_pem" {
  value = aws_iot_certificate.example_certificate.certificate_pem
}

output "private_key_pem" {
  value = aws_iot_certificate.example_certificate.private_key_pem
}

output "certificate_arn" {
  value = aws_iot_certificate.example_certificate.arn
}
