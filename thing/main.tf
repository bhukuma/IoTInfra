provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

resource "aws_iot_thing" "example_thing" {
  name = "my-iot-thing"
  
  attributes = {
    "environment" = "development"
    "version"     = "v1"
  }
}
