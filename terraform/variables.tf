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

