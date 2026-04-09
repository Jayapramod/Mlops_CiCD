# ---------------------------------------------------------------------------
# Kubernetes provider — authenticates using EKS cluster outputs
# ---------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

# ---------------------------------------------------------------------------
# Deployment
# ---------------------------------------------------------------------------
resource "kubernetes_deployment" "agrox" {
  metadata {
    name = "agrox-app"
    labels = {
      app = "agrox-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "agrox-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "agrox-app"
        }
      }

      spec {
        container {
          name  = "agrox-app"
          image = "${aws_ecr_repository.agrox.repository_url}:latest"

          # Always re-pull :latest — required for `kubectl rollout restart` to
          # pick up a new image pushed with the same tag by Jenkins
          image_pull_policy = "Always"

          port {
            container_port = 8000
          }

          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "500m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1000m"
            }
          }
        }
      }
    }
  }

  # Ignore image changes managed externally by Jenkins rolling restarts
  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations,
    ]
  }
}

# ---------------------------------------------------------------------------
# Service — LoadBalancer exposes port 80 externally → 8000 on the container
# ---------------------------------------------------------------------------
resource "kubernetes_service" "agrox" {
  metadata {
    name = "agrox-service"
  }

  spec {
    selector = {
      app = "agrox-app"
    }

    type = "LoadBalancer"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8000
    }
  }
}
