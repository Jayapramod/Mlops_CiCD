# ---------------------------------------------------------------------------
# CloudWatch Log Group
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "agrox" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name      = "${var.cluster_name}-logs"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# IAM Role for ECS Task Execution (for pulling image from ECR, CloudWatch logs)
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.cluster_name}-ecs-task-execution-role"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy to pull from ECR
resource "aws_iam_role_policy" "ecs_task_execution_ecr_policy" {
  name = "${var.cluster_name}-ecs-task-execution-ecr-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# ECS Cluster
# ---------------------------------------------------------------------------
resource "aws_ecs_cluster" "agrox" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name      = "${var.cluster_name}-cluster"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# ECS Task Definition
# ---------------------------------------------------------------------------
resource "aws_ecs_task_definition" "agrox" {
  family             = var.cluster_name
  network_mode       = "awsvpc"
  cpu                = var.task_cpu
  memory             = var.task_memory
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${var.ecr_repository_uri}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.agrox.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = [
        {
          name  = "FLASK_ENV"
          value = "production"
        },
        {
          name  = "FLASK_APP"
          value = "app.py"
        }
      ]
    }
  ])

  tags = {
    Name      = "${var.cluster_name}-task-def"
    Project   = "agrox"
    ManagedBy = "terraform"
  }

  depends_on = [
    aws_iam_role_policy.ecs_task_execution_ecr_policy,
    aws_cloudwatch_log_group.agrox
  ]
}

# ---------------------------------------------------------------------------
# ECS Service
# ---------------------------------------------------------------------------
resource "aws_ecs_service" "agrox" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.agrox.id
  task_definition = aws_ecs_task_definition.agrox.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = [aws_subnet.private.id]

    # Assign public IP only if needed (not required for ECS Fargate with NAT)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.agrox.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # Ensure ALB is ready before creating service
  depends_on = [
    aws_lb_listener.agrox,
    aws_iam_role_policy.ecs_task_execution_ecr_policy
  ]

  tags = {
    Name      = "${var.cluster_name}-service"
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Auto Scaling Target
# ---------------------------------------------------------------------------
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_tasks
  min_capacity       = var.desired_task_count
  resource_id        = "service/${aws_ecs_cluster.agrox.name}/${aws_ecs_service.agrox.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Optional: CPU-based scaling policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.cluster_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Optional: Memory-based scaling policy
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.cluster_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0
  }
}
