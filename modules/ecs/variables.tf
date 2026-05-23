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
  default = 5000
}

variable "alb_tg_lb_arn" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}