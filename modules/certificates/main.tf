module "iot_thing_name" {
  source = "./modules/thing"  # Path to the folder containing module_a
}
# Generate a private key locally
resource "tls_private_key" "esp32_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a Certificate Signing Request (CSR)
resource "tls_cert_request" "esp32_csr" {
  private_key_pem = tls_private_key.esp32_key.private_key_pem

  subject {
    common_name  = "thing_esp32"
    organization = "My SmartLab"
  }
}

# Create IoT Certificate using the CSR
resource "aws_iot_certificate" "esp32_certificate" {
  active = true
  csr    = tls_cert_request.esp32_csr.cert_request_pem
}

# Attach the certificate to the IoT Thing
resource "aws_iot_thing_principal_attachment" "thing_cert_attachment" {
  thing     = aws_iot_thing.esp32.name
  principal = aws_iot_certificate.esp32_certificate.arn
}

# Create a Secret in AWS Secrets Manager for the private key
resource "aws_secretsmanager_secret" "private_key_secret" {
  name        = "${module.iot_module.iot_thing_name}-key"
  description = "Private key for IoT Thing"
}

resource "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id     = aws_secretsmanager_secret.private_key_secret.id
  secret_string = tls_private_key.esp32_key.private_key_pem
}

# Create a Secret in AWS Secrets Manager for the certificate
resource "aws_secretsmanager_secret" "certificate_secret" {
  name        = "${module.iot_module.iot_thing_name}-cert"
  description = "Certificate for IoT Thing"
}

resource "aws_secretsmanager_secret_version" "certificate_version" {
  secret_id     = aws_secretsmanager_secret.certificate_secret.id
  secret_string = aws_iot_certificate.esp32_certificate.certificate_pem
}
