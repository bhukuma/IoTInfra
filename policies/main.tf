resource "aws_iot_policy" "my_iot_policy" {
  name = "IoTThingAndManagementPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow the creation, listing, updating, and deletion of IoT Things
      {
        Effect = "Allow"
        Action = [
          "iot:CreateThing",        # Create IoT Things
          "iot:DescribeThing",      # Describe IoT Things
          "iot:ListThings",         # List all IoT Things
          "iot:DeleteThing",        # Delete IoT Things
          "iot:UpdateThing"         # Update IoT Things
        ]
        Resource = "*"
      },
      # Shadow management for specific IoT Things
      {
        Effect = "Allow"
        Action = [
          "iot:GetThingShadow",     # Get IoT Thing shadow
          "iot:UpdateThingShadow",  # Update IoT Thing shadow
          "iot:DeleteThingShadow"   # Delete IoT Thing shadow
        ]
        Resource = "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:thing/${aws_iot_thing.my_iot_thing.name}"
      },
      # Allow the created IoT Thing to connect, publish, subscribe, and receive messages
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",           # Connect to IoT
          "iot:Publish",           # Publish to topics
          "iot:Subscribe",         # Subscribe to topics
          "iot:Receive"            # Receive messages
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.my_iot_thing.name}",   # Allow thing to connect as a client
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/*"    # Allow the thing to publish/subscribe to any topic
        ]
      }
    ]
  })
}
