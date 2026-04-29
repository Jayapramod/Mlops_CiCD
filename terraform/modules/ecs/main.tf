# ---------------------------------------------------------------------------
# IAM Role for ECS Task (application permissions)
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-${var.project_name}-ecs-task-role"

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
    Name      = "${var.environment}-ecs-task-role"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# Additional policy for task role (add permissions as needed for your app)
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "${var.environment}-${var.project_name}-ecs-task-role-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.environment}-${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name      = "${var.environment}-logs"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# IAM Role for ECS Task Execution (for pulling image from ECR, CloudWatch logs)
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-${var.project_name}-ecs-task-execution-role"

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
    Name      = "${var.environment}-ecs-task-execution-role"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy to pull from ECR
resource "aws_iam_role_policy" "ecs_task_execution_ecr_policy" {
  name = "${var.environment}-${var.project_name}-ecs-task-execution-ecr-policy"
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
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name      = "${var.environment}-cluster"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------------------------------
# ECS Task Definition
# ---------------------------------------------------------------------------
resource "aws_ecs_task_definition" "main" {
  family             = "${var.environment}-${var.project_name}"
  network_mode       = "awsvpc"
  cpu                = var.task_cpu
  memory             = var.task_memory
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

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
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
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
    Name      = "${var.environment}-task-def"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }

  depends_on = [
    aws_iam_role_policy.ecs_task_execution_ecr_policy,
    aws_iam_role_policy.ecs_task_role_policy,
    aws_cloudwatch_log_group.main
  ]
}

# ---------------------------------------------------------------------------
# ECS Service
# ---------------------------------------------------------------------------
resource "aws_ecs_service" "main" {
  name            = "${var.environment}-${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.ecs_tasks_security_group_id]
    subnets         = [var.private_subnet_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  force_new_deployment = true
  enable_ecs_managed_tags = true
  propagate_tags = "TASK_DEFINITION"

  tags = {
    Name      = "${var.environment}-service"
    Project   = var.project_name
    Environment = var.environment
    ManagedBy = "terraform"
  }

  depends_on = [
    aws_iam_role_policy.ecs_task_execution_ecr_policy
  ]
}

# ---------------------------------------------------------------------------
# Auto Scaling Target
# ---------------------------------------------------------------------------
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_tasks
  min_capacity       = var.desired_task_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ---------------------------------------------------------------------------
# CPU Autoscaling Policy
# ---------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.environment}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    disable_scale_in   = false
  }
}

# ---------------------------------------------------------------------------
# Memory Autoscaling Policy
# ---------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.environment}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value     = 80
    disable_scale_in = false
  }
}
