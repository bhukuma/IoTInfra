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

# Create a Secret in AWS Secrets Manager for the private key
resource "aws_secretsmanager_secret" "private_key_secret" {
  name        = "iot-private-key"
  description = "Private key for IoT Thing"
}

resource "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id     = aws_secretsmanager_secret.private_key_secret.id
  secret_string = tls_private_key.example_key.private_key_pem
}

# Create a Secret in AWS Secrets Manager for the certificate
resource "aws_secretsmanager_secret" "certificate_secret" {
  name        = "iot-certificate"
  description = "Certificate for IoT Thing"
}

resource "aws_secretsmanager_secret_version" "certificate_version" {
  secret_id     = aws_secretsmanager_secret.certificate_secret.id
  secret_string = aws_iot_certificate.example_certificate.certificate_pem
}

# Output the ARN of the secrets for reference
output "private_key_secret_arn" {
  value = aws_secretsmanager_secret.private_key_secret.arn
}

output "certificate_secret_arn" {
  value = aws_secretsmanager_secret.certificate_secret.arn
}
