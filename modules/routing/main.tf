module "iot_module" {
  source = "../thing"  # Path to the folder containing module_a
}
provider "aws" {
  region = "us-east-1"  # Specify your AWS region
}

# S3 Bucket where IoT messages will be stored (assuming it already exists)
resource "aws_s3_bucket" "iot_data_bucket" {
  bucket = "iot-data"  # Change this to your existing bucket name
}

# Reference the existing IAM role (replace with your role ARN)
data "aws_iam_role" "iot_role" {
  name = "iottos3"  # Use your existing role name here
}

# IoT Topic Rule that routes messages to S3
resource "aws_iot_topic_rule" "iot_s3_rule" {
  name = "tos3"

  sql = "SELECT *, timestamp() as timestamp FROM 'esp32-pub'"  # Modify the topic filter as needed
  sql_version = "2016-03-23"

  # Enable the rule
  enabled = true

  # S3 Action to store the message in S3
  s3 {
    role_arn    = data.aws_iam_role.iot_role.arn  # Use the existing role ARN
    bucket_name = aws_s3_bucket.iot_data_bucket.bucket
    key         = "iot_data/${timestamp()}.json"  # S3 object key, with timestamp
  }
}
