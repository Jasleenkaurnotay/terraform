# Request public IP for ALB not needed because ALB works on DNS name

#Create ALB
resource "aws_lb" "alb" {
    name = "${var.project_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.alb_sg_id]
    subnets = var.public_subnet

    tags = {
        Name = "${var.project_name}-alb"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create ALB HTTP listener
resource "aws_lb_listener" "http_list" {
    load_balancer_arn = aws_lb.alb.arn
    port = "80"
    protocol = "HTTP"
    
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.alb_tg.arn
    }
}

# Create ALB HTTPS listener
#resource "aws_lb_listener" "https_list" {
#    load_balancer_arn = aws_lb.alb.arn
#    port = "443"
#    protocol = "HTTPS"
#    
#    default_action {
#      type = "forward"
#      target_group_arn = aws_lb_target_group.alb_tg.arn
#    }
#}

# Create target group where ALB forwards traffic to
# Type: IP target group because Fargate tasks dont have instance IDs
resource "aws_lb_target_group" "alb_tg" {
    name = "${var.project_name}-alb-tg"
    port = 8000
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id

    health_check {
      enabled = "true"
      unhealthy_threshold = 3
      interval = 30
      path = "/login"
      port = "traffic-port"
      protocol = "HTTP"
    }

    tags = {
        Name = "${var.project_name}-alb-tg"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}