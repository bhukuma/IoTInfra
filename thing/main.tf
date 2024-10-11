provider "aws" {
  region = "us-east-1"  # Specify your preferred AWS region
}

# Create an IoT Thing
resource "aws_iot_thing" "my_iot_thing" {
  name = "esp32"  # Specify the name of your IoT Thing
}

# Create an IoT Certificate
resource "aws_iot_certificate" "my_iot_certificate" {
  active = true
}

# Attach a policy to the certificate
resource "aws_iot_policy" "my_iot_policy" {
  name = "IoTThingAndManagementPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the certificate
resource "aws_iot_policy_attachment" "my_policy_attachment" {
  policy = aws_iot_policy.my_iot_policy.name
  target = aws_iot_certificate.my_iot_certificate.arn
}

# Attach the certificate to the IoT Thing
resource "aws_iot_thing_principal_attachment" "my_attachment" {
  thing     = aws_iot_thing.my_iot_thing.name   # Corrected argument here
  principal = aws_iot_certificate.my_iot_certificate.arn
}

# Output values
output "thing_arn" {
  value = aws_iot_thing.my_iot_thing.arn
}

output "certificate_arn" {
  value = aws_iot_certificate.my_iot_certificate.arn
}

output "policy_arn" {
  value = aws_iot_policy.my_iot_policy.arn
}
