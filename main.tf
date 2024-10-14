terraform {
  backend "s3" {
    bucket         = "esp32datatos3"        # Change this to your S3 bucket
    key            = "terraform/thing/terraform.tfstate"  # Path within the bucket to store the state file
    region         = "us-east-1"                  # Change this to your AWS region
    encrypt        = true                         # Enable server-side encryption of the state file
  }
}

provider "aws" {
  region = "us-east-1"
}

module "thing" {
  source = "./modules/thing"
}

module "certificates" {
  source = "./modules"
}
