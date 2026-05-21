# Traffic flow within security groups:
# Internet traffic -> ALB sg (443/80) -> ECS task sg (5000 - application port) -> RDS sg (5432)


# Create security group for ALB
resource "aws_security_group" "alb_sg" {
    name = "${var.project_name}-alb-sg"
    description = "Allow incoming on port 80/443 on ALB"
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.project_name}-alb-sg"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create inbound rule in ALB sg
resource "aws_vpc_security_group_ingress_rule" "alb_sg_443" {
    security_group_id = aws_security_group.alb_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    ip_protocol = "tcp"
    to_port = 443
}

# Create inbound rule in ALB sg
resource "aws_vpc_security_group_ingress_rule" "alb_sg_80" {
    security_group_id = aws_security_group.alb_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
}

# Create egress rule for ALB sg
resource "aws_vpc_security_group_egress_rule" "alb_sg_egress" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create security group for ECS tasks
resource "aws_security_group" "ecs_sg" {
    name = "${var.project_name}-ecs-sg"
    description = "Allow incoming traffic on application port on ECS tasks"
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.project_name}-ecs-sg"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create security group rule in ECS sg
resource "aws_vpc_security_group_ingress_rule" "ecs_sg_app_port" {
    security_group_id = aws_security_group.ecs_sg.id
    referenced_security_group_id = aws_security_group.alb_sg.id     # Allow incoming traffic only from alb-sg
    ip_protocol = "tcp"
    to_port = 5000
    from_port = 5000
}

# allow all outbound — standard for ALB, ECS, RDS
resource "aws_vpc_security_group_egress_rule" "ecs_sg_egress" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create RDS security group
resource "aws_security_group" "rds_sg" {
    name = "${var.project_name}-rds-sg"
    description = "Allow incoming traffic from ecs-sg"
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.project_name}-rds-sg"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create inbound security group rule in rds-sg
resource "aws_vpc_security_group_ingress_rule" "rds_sg_inbound" {
    security_group_id = aws_security_group.rds_sg.id
    referenced_security_group_id = aws_security_group.ecs_sg.id
    ip_protocol = "tcp"
    to_port = 5432
    from_port = 5432
}

# allow all outbound — standard for ALB, ECS, RDS
resource "aws_vpc_security_group_egress_rule" "rds_sg_egress" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}