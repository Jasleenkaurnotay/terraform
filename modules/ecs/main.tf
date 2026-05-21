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
    name = "/ecs/task-mgr"

    tags = {
        Name = "${var.project_name}-ecs-task-mgr"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create IAM role for use by ECS task definition to contact cloudwatch and ECR
resource "aws_iam_role" "ecs_iam_role" {
    name = "${var.project_name}-ecs-role"

    assume_role_policy = jsonecode({
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
    cpu = 1
    memory = 1024
    execution_role_arn = aws_iam_role.ecs_iam_role.arn

    runtime_platform {
      operating_system_family = "LINUX"
      cpu_architecture = "X86_64"
    }
    container_definitions = jsonencode([
        {
            name = "${var.project_name}-app-container"
            image = ""
            cpu = 1
            memory = 1024
            essential = true
            portMappings = [
                {
                    containerPort = 8000
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
} ## Still pending: execution_role_arn 