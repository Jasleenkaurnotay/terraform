aws_region   = "us-east-1"
project_name = "ecs-lab"
vpc_cidr     = "172.16.0.0/16"
private_cidr = ["172.16.16.0/20", "172.16.32.0/20"]
rds_cidr     = ["172.16.48.0/20", "172.16.192.0/20"]
public_cidr  = ["172.16.64.0/20", "172.16.128.0/20"]
environment  = "dev"