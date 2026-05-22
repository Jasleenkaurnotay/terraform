# Create ECS cluster
resource "aws_ecs_cluster" "ecs" {
    name = "${var.project_name}-ecs"

    tags = {
        Name = "${var.project_name}-ecs"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

#Create cloudwatch log group for storing ecs container logs
resource "aws_cloudwatch_log_group" "ecs_lg" {
    name = "/ecs/${var.project_name}"

    tags = {
        Name = "${var.project_name}-ecs-task-mgr"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create IAM role for use by ECS task definition to contact cloudwatch and ECR
resource "aws_iam_role" "ecs_iam_role" {
    name = "${var.project_name}-ecs-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                Service = "ecs-tasks.amazonaws.com"
                }
            },
        ]
    })
}

# Attach the managed policy to the IAM role

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS task definition
resource "aws_ecs_task_definition" "ecs_service" {
    family = "${var.project_name}-ecs-td"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = "${var.task_cpu}"
    memory = "${var.task_memory}"
    execution_role_arn = aws_iam_role.ecs_iam_role.arn

    runtime_platform {
      operating_system_family = "LINUX"
      cpu_architecture = "X86_64"
    }
    container_definitions = jsonencode([
        {
            name = "${var.project_name}-app-container"
            image = "${var.container_image}"
            essential = true
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = aws_cloudwatch_log_group.ecs_lg.name
                    "awslogs-region" = "${var.aws_region}"
                    "awslogs-stream-prefix" = "ecs"
                }

            }
            portMappings = [
                {
                    containerPort = "${var.container_port}"
                    hostPort = 8000
                }
            ]
        }
    ])

    tags = {
        Name = "${var.project_name}-ecs-td"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create an ECS service
resource "aws_ecs_service" "ecs_srv" {
    name = "${var.project_name}-ecs-srv"
    cluster = aws_ecs_cluster.ecs.id
    task_definition = aws_ecs_task_definition.ecs_service.arn
    desired_count = 1
    launch_type = "FARGATE"
    scheduling_strategy = "REPLICA"
    depends_on = [ aws_iam_role_policy_attachment.ecs_execution_policy ]
    network_configuration {
      assign_public_ip = "false"
      security_groups = [var.ecs_sg_id]
      subnets = var.private_subnet
    }

    load_balancer {
      target_group_arn = "${var.alb_tg_lb_arn}"
      container_name = "${var.project_name}-app-container"
      container_port = var.container_port
    }

    tags = {
    Name        = "${var.project_name}-ecs-service"
    Environment = var.environment
    ManagedBy   = "Terraform"
    }
}