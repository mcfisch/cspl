# AWS options (creds stored in local AWS config)
variable "region" {
  default = "us-west-1"
}

provider "aws" {
    region  = var.region
    profile = "default"
    shared_credentials_file = "~/.aws/credentials"
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6rTTH+gGK9j4efn83dmnCdqi/m/p/UsHsw1gJwGoPAqtwj5jsvosGgNZigF6dnAK1FF+s+a3RKfUzpWIIv669Sg/hcIDqnIkYr6/gfFaRkDx8KFN2d8DZqSkKKjZlP/8cGvbcYNdRXUouVPiHHtk72tz1qSgGWZWlFMs3FGm62pfNh9Cz+lXn9CUPmzRx578/JUK2IpBhuY08bvh3AxCKoMwbhSseFvPHjKFsPaTQ4BGNyh9pviRTCm50BZHGe/9wS7fe3LMtqYMT1MGEf4yQ+zzPagShZAsLLrcVD0tVpzRQ5BH/t8PL2nILjqNBqoRyobS+q0IEDMbok0BuXYM+/dP/rza6veh5bAP6FD1V6Zht15Rr3ZInVDmTWCwzCdtO8Cto1rwcV/CK//wTxPVkuv7ctnl1Yb79zhtXAFR7pENb4DPZlsRG4rrRZjdX8ANPMnt9hchNeLbLaUN1DDUMzjSHXt0Ob3UL7V5/nhREkpb9CVMrE95UZ4b+A4P/QAs= mcfisch@all"
}

# Security groups network access
resource "aws_security_group" "elb" {
    name = "elb-security-group"
    description = "ELB access rules"

    tags = {
      "Name" = "ELB Security Group"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "default" {
    name = "default-security-group"
    description = "Accept SSH and HTTP requests"

    tags = {
      "Name" = "Default Security Group"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# EC2 config
# (AMI ID for latest Ubuntu 20.04 from https://cloud-images.ubuntu.com/locator/ec2/)
resource "aws_instance" "cspl_web" {
  	ami 		    = "ami-00831fc7c1e3ddc60"
  	instance_type	= "t2.nano"

    tags = {
        Name = "CSPL_Web"
    }

    key_name = "ssh-key"
    security_groups = [aws_security_group.default.name]

    # Install NGINX
    provisioner "remote-exec" {
        inline = [
            "sudo apt -y update",
            "sudo apt -y install nginx",
            "sudo service nginx start",
            # "sudo echo '<html><body><div><h1>Cisco SPL</h1></div></body></html>' > /var/www/html/index.html",
        ]
    }
    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
    }
}

resource "aws_eip" "ip" {
    instance = aws_instance.cspl_web.id
}

# Configure ELB
resource "aws_elb" "cspl_elb" {
    name = "cspl-elb"
    security_groups = [aws_security_group.elb.id]
    instances = [aws_instance.cspl_web.id]
    availability_zones = ["us-west-1b", "us-west-1c"]
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
}

# Return public IP and DNS
output "ip" {
    value = aws_eip.ip.public_ip
}
output "address" {
  value = aws_elb.cspl_elb.dns_name
}
