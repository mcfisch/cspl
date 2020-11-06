# SSH Key
variable "key_name" { 
  type    = string
  default = "ssh-key" 
}

locals {
  public_key_path = file("~/.ssh/id_rsa.pub")
}

variable "region" {
  default = "us-west-1"
}

# Text to present on the default website
variable "html_text" {
  type = string
  default = "Cisco SPL"
}