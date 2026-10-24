
# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"
}


# Create an EC2 instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c7632fb77f35db43"
  instance_type = "t2.micro"

  tags = {
    Name        = "Terraform-EC2-prod"
    Environment = "Production"
  }
}

# Display the public IP address
output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
