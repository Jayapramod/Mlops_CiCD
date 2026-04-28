# ---------------------------------------------------------------------------
# ECR Repository
# ---------------------------------------------------------------------------
# NOTE: ECR repository is created and managed by Jenkins pipeline.
# This file is kept for reference. Terraform only references the existing ECR
# via the ecr_repo_url variable to avoid tfstate pollution and conflicts.
#
# Jenkins handles:
#   - ECR repository creation (if not exists)
#   - Docker image building and pushing
#   - Image lifecycle policies
#
# To create ECR manually (if needed before Jenkins creates it):
#   aws ecr create-repository --repository-name agrox --region ap-south-1
