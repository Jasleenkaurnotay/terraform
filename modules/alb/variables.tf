variable "project_name" {
  type = string
}

variable "alb_sg_id" {
    type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "public_subnet" {
    type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "cert_arn" {
  type = string
}