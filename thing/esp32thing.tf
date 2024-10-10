provider "aws" {
  region = "us-east-1"  # Specify your preferred AWS region
}

# Create an IoT Thing
resource "aws_iot_thing" "my_iot_thing" {
  name               = "MyIoTThing"  # Specify the name of your IoT Thing
  thing_type_name    = "MyThingType"  # Optional: Specify a Thing Type
  attribute_payload = {
    "attr1" = "value1"  # Optional: Add attributes to the Thing
    "attr2" = "value2"
  }
}

# Create an IoT Certificate
resource "aws_iot_certificate" "my_iot_certificate" {
  count = 1  # Create a single certificate
  active = true  # Activate the certificate

  # Note: You can specify different options for certificate creation
  allow_unverified_cert = false
}

# Attach a policy to the certificate
resource "aws_iot_policy" "my_iot_policy" {
  name   = "MyIoTPolicy"

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
  policy  = aws_iot_policy.my_iot_policy.name
  target  = aws_iot_certificate.my_iot_certificate.arn
}

# Attach the certificate to the IoT Thing
resource "aws_iot_thing_principal_attachment" "my_attachment" {
  thing_name      = aws_iot_thing.my_iot_thing.name
  principal       = aws_iot_certificate.my_iot_certificate.arn
}

output "thing_arn" {
  value = aws_iot_thing.my_iot_thing.arn
}

output "certificate_arn" {
  value = aws_iot_certificate.my_iot_certificate.arn
}

output "policy_arn" {
  value = aws_iot_policy.my_iot_policy.arn
}
