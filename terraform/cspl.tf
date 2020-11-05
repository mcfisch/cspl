# variable "region" {
#     default = "us-west-1"
# }

provider "aws" {
    region  = var.region
    profile = "default"
    shared_credentials_file = local.public_key_path
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
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

resource "aws_security_group" "web" {
    name = "web-security-group"
    description = "Accept SSH and HTTP requests"

    tags = {
      "Name" = "Web Server Security Group"
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
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_instance" "cspl_web" {
    ami           = data.aws_ami.ubuntu.id
  	instance_type = "t2.nano"

    tags = {
        Name = "CSPL_Web"
    }

    key_name        = "ssh-key"
    security_groups = [aws_security_group.web.name]

    # Install NGINX with copied shel script
    user_data = file("install_nginx.sh")

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
data "aws_availability_zones" "all" {}

resource "aws_elb" "cspl_elb" {
    name = "cspl-elb"
    security_groups = [aws_security_group.elb.id]
    instances = [aws_instance.cspl_web.id]
    availability_zones = data.aws_availability_zones.all.names

    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:80/index.html"
        interval            = 30
    }
}

# Return public IP and DNS Name
output "ip" {
    value = aws_eip.ip.public_ip
}
output "address" {
  value = aws_elb.cspl_elb.dns_name
}
