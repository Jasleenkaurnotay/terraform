variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_cidr" {
  type = list(string)
}

variable "rds_cidr" {
  type = list(string)
}

variable "public_cidr" {
  type = list(string)
}

variable "environment" {
  type    = string
  default = "dev"
}