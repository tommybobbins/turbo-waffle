data "aws_caller_identity" "current" {}

variable "project_name" {
  description = "Project Name"
  default     = "turbo-waffle"
}

variable "host_name" {
  description = "Host Name"
  default     = "spaceman-0"
}

locals {
  region = "eu-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "key_name" {
  description = "SSH Key name"
  type        = string
  default     = "spaceman-0"
}

variable "rules" {
  type = list(object({
    port             = number
    proto            = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = [
    {
      port             = 2020
      proto            = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
  ]


}


locals {
  userdata = {
    project_name = var.project_name,
    account_id   = data.aws_caller_identity.current.account_id
    bucket_name  = aws_s3_bucket.turbo-waffle.bucket
  }
}
