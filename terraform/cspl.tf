# AWS options (creds stored in local AWS config)
provider "aws" {
    region  = "us-west-1"
    profile = "default"
    shared_credentials_file = "~/.aws/credentials"
}

# EC2 config
# (AMI ID for latest Ubuntu 20.04 from https://cloud-images.ubuntu.com/locator/ec2/)
resource "aws_instance" "cspl_web" {
  	ami 		    = "ami-00831fc7c1e3ddc60"
  	instance_type	= "t2.nano"

    tags = {
        Name = "CSPL_Web"
    }
}

# Configure ELB
resource "aws_eip" "ip" {
  instance = aws_instance.cspl_web.id
}

# Return public IP
output "ip" {
    value = aws_eip.ip.public_ip
}
