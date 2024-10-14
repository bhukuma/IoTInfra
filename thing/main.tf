provider "aws" {
  region = "us-east-1"
}

# Create IoT Thing
resource "aws_iot_thing" "example_thing" {
  name = "my-iot-thing"
  
  attributes = {
    "environment" = "development"
    "version"     = "v1"
  }
}

# Generate a private key locally
resource "tls_private_key" "example_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a Certificate Signing Request (CSR)
resource "tls_cert_request" "example_csr" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.example_key.private_key_pem

  subject {
    common_name  = "my-iot-thing"
    organization = "My Organization"
  }
}

# Create IoT Certificate using the CSR
resource "aws_iot_certificate" "example_certificate" {
  active = true
  csr    = tls_cert_request.example_csr.cert_request_pem
}

# Attach the certificate to the IoT Thing
resource "aws_iot_thing_principal_attachment" "thing_cert_attachment" {
  thing     = aws_iot_thing.example_thing.name
  principal = aws_iot_certificate.example_certificate.arn
}

# Output the certificate and key for later use
output "certificate_pem" {
  value = aws_iot_certificate.example_certificate.certificate_pem
}

output "private_key_pem" {
  value = tls_private_key.example_key.private_key_pem
}

output "certificate_arn" {
  value = aws_iot_certificate.example_certificate.arn
}
