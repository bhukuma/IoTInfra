terraform {
  backend "s3" {
    bucket         = "esp32datatos3"        # Change this to your S3 bucket
    key            = "terraform/policies/terraform.tfstate"  # Path within the bucket to store the state file
    region         = "us-east-1"                  # Change this to your AWS region
    encrypt        = true                         # Enable server-side encryption of the state file
  }
}

resource "aws_iot_policy" "create_iot_thing" {
  name = "CreateIoTThingPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iot:CreateThing",
          "iot:CreateThingGroup"
        ],
        "Resource": "*"
      }
    ]
  })
}
