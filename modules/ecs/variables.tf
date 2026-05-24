variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "container_image" {
  type = string
  description = "Full ECR image URI"
}

variable "private_subnet" {
  type = list(string)
}

variable "task_cpu" {
  type = string
  default = "256"
}

variable "task_memory" {
  type = string
  default = "512"
}

variable "container_port" {
  type = number
  default = 8000
}

variable "alb_tg_lb_arn" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true # Value is sensitive
}