terraform {
  backend "s3" {
    bucket         = "esp32datatos3"        # Change this to your S3 bucket
    key            = "terraform/ec2/terraform.tfstate"  # Path within the bucket to store the state file
    region         = "us-east-1"                  # Change this to your AWS region
    encrypt        = true                         # Enable server-side encryption of the state file
  }
}

provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0fff1b9a61dec8a5f"  # Replace with your preferred AMI
  instance_type = "t2.micro"
  tags = {
    Name = "ExampleInstance"
  }
}
