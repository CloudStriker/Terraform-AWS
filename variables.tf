variable "instance_name" {
 description = "Value of the Name tag for the EC2 instance"
 type = string
 default = "WP-Terraform"
}

variable username {
  description = "DB username"
  default = "admin"
}

variable password {
  description = "DB password"
  default = "A11111111"
}

variable dbname {
  description = "db name"
  default = "wordpress"
}