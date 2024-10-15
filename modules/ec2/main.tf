provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "example" {
  ami           = "ami-06b21ccaeff8cd686"  # Replace with your preferred AMI
  instance_type = "t2.micro"
  tags = {
    Name = "Nodejs"
  }
}
