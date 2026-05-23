variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "rds_subnet" {
    type = list(string)
}

variable "rds_sg_id" {
    type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}