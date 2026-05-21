# ECS Deployment using Terraform

Terraform project to deploy a containerised Flask app on AWS ECS Fargate.

## Architecture
- VPC with public, private, and RDS subnets across 2 AZs
- ECS Fargate cluster with ALB
- RDS Postgres database
- Remote state on S3 (coming soon)

## Usage
cp terraform.tfvars.example terraform.tfvars
# fill in your values
terraform init
terraform plan
terraform apply