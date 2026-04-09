# ---------------------------------------------------------------------------
# ECR Repository
# ---------------------------------------------------------------------------
resource "aws_ecr_repository" "agrox" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE" # Required to overwrite :latest on each push

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project   = "agrox"
    ManagedBy = "terraform"
  }
}

# Keep only the 10 most recent images to control storage costs
resource "aws_ecr_lifecycle_policy" "agrox" {
  repository = aws_ecr_repository.agrox.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
