# AgroX AWS Architecture - Visual Guide

## 🏗️ Complete Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                            AWS REGION (us-east-1)                          │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         VPC (10.0.0.0/16)                           │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │  PUBLIC SUBNETS (NAT GW, ALB)                              │    │   │
│  │  │  ┌──────────────────────────────────────────────────────┐  │    │   │
│  │  │  │ Subnet 1 (10.0.1.0/24)                              │  │    │   │
│  │  │  │ NAT Gateway 1 + EIP                                 │  │    │   │
│  │  │  └──────────────────────────────────────────────────────┘  │    │   │
│  │  │  ┌──────────────────────────────────────────────────────┐  │    │   │
│  │  │  │ Subnet 2 (10.0.2.0/24)                              │  │    │   │
│  │  │  │ NAT Gateway 2 + EIP                                 │  │    │   │
│  │  │  └──────────────────────────────────────────────────────┘  │    │   │
│  │  │  ┌──────────────────────────────────────────────────────┐  │    │   │
│  │  │  │          ALB (agrox-alb)                            │  │    │   │
│  │  │  │  Port 80 → Target Group (agrox-tg)                │  │    │   │
│  │  │  │  DNS: agrox-alb-123456789.us-east-1.elb.amazonaws │  │    │   │
│  │  │  └──────────────────────────────────────────────────────┘  │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │  PRIVATE SUBNETS (EKS Nodes)                              │    │   │
│  │  │  ┌──────────────────────────────────────────────────────┐  │    │   │
│  │  │  │ Subnet 3 (10.0.10.0/24)                             │  │    │   │
│  │  │  │ ┌────────────────────────────────────────────────┐  │  │    │   │
│  │  │  │ │   EC2 Node 1 (t3.medium)                      │  │  │    │   │
│  │  │  │ │   ┌──────────────────────────────────────┐   │  │  │    │   │
│  │  │  │ │   │ Pod: agrox-app-xxx                │   │  │  │    │   │
│  │  │  │ │   │ Container Port: 8000              │   │  │  │    │   │
│  │  │  │ │   │ Image: ECR/agrox/app:latest      │   │  │  │    │   │
│  │  │  │ │   │ Liveness: HTTP GET /              │   │  │  │    │   │
│  │  │  │ │   │ Readiness: HTTP GET /             │   │  │  │    │   │
│  │  │  │ │   └──────────────────────────────────────┘   │  │  │    │   │
│  │  │  │ │   ┌──────────────────────────────────────┐   │  │  │    │   │
│  │  │  │ │   │ Pod: agrox-app-yyy                │   │  │  │    │   │
│  │  │  │ │   │ Container Port: 8000              │   │  │  │    │   │
│  │  │  │ │   └──────────────────────────────────────┘   │  │  │    │   │
│  │  │  │ └────────────────────────────────────────────────┘  │  │    │   │
│  │  │  │ (Managed by Kubernetes, created by Terraform)      │  │    │   │
│  │  │  └──────────────────────────────────────────────────┘  │    │   │
│  │  │  ┌──────────────────────────────────────────────────┐  │    │   │
│  │  │  │ Subnet 4 (10.0.11.0/24)                         │  │    │   │
│  │  │  │ EC2 Node 2 (t3.medium)                          │  │    │   │
│  │  │  │ ┌──────────────────────────────────────────┐   │  │    │   │
│  │  │  │ │ Pod: agrox-app-zzz                    │   │  │    │   │
│  │  │  │ │ + auto-scaled pods (2-6 total)       │   │  │    │   │
│  │  │  │ └──────────────────────────────────────────┘   │  │    │   │
│  │  │  └──────────────────────────────────────────────┘  │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │   │
│  │                         Internet Gateway                        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        ECR REPOSITORY                               │   │
│  │                 agrox/app (Private Docker Registry)                │   │
│  │                                                                    │   │
│  │  Images:                                                          │   │
│  │    - agrox/app:latest                                            │   │
│  │    - agrox/app:123 (build number)                                │   │
│  │    - + up to 10 versioned images (auto-cleanup)                 │   │
│  │                                                                    │   │
│  │  Lifecycle: Keep last 10 images, oldest auto-deleted            │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                      KUBERNETES RESOURCES                           │   │
│  │                                                                    │   │
│  │  EKS Cluster: agrox-eks (1.28)                                  │   │
│  │  Namespace: agrox                                              │   │
│  │  ├─ Deployment: agrox-app (2+ replicas)                       │   │
│  │  ├─ Service: agrox-service (LoadBalancer)                     │   │
│  │  ├─ HPA: agrox-hpa (scale 2-6 pods on CPU usage)            │   │
│  │  ├─ ConfigMap: agrox-config (env vars)                       │   │
│  │  ├─ Secret: agrox-secret (FLASK_SECRET_KEY)                │   │
│  │  └─ PDB: agrox-pdb (availability guarantee)                 │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 CI/CD Pipeline Flow

```
┌──────────────────┐
│  GitHub Repo     │
│  (main branch)   │
└────────┬─────────┘
         │
         │ git push
         │
    ┌────▼──────────────────┐
    │  GitHub Webhook       │
    │  (triggered)          │
    └────┬──────────────────┘
         │
         │ Webhook POST
         │
    ┌────▼──────────────────────────────────────────────────────────────┐
    │                      JENKINS PIPELINE                            │
    │                  (Jenkinsfile-ECR)                              │
    │                                                                  │
    │  ┌─────────────────────────────────────────────────────────┐   │
    │  │ Stage 1: Checkout                                       │   │
    │  │ - Clone repository from GitHub                          │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 2: Setup Python                                  │   │
    │  │ - Create venv                                          │   │
    │  │ - Install requirements.txt                             │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 3: Train Models                                  │   │
    │  │ - Run retrain_pipeline.py                             │   │
    │  │ - Update crop/fertilizer/price models                │   │
    │  │ - Send email notification                             │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 4: Build Docker Image                            │   │
    │  │ - docker build -t image:$BUILD_NUMBER                │   │
    │  │ - docker tag image:latest                             │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 5: Login to ECR                                  │   │
    │  │ - aws ecr get-login-password | docker login            │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 6: Push to ECR                                   │   │
    │  │ - docker push ECR/agrox/app:$BUILD_NUMBER           │   │
    │  │ - docker push ECR/agrox/app:latest                 │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 7: Update EKS Deployment                         │   │
    │  │ - kubectl set image deployment/agrox-app \           │   │
    │  │   agrox=ECR/agrox/app:$BUILD_NUMBER                 │   │
    │  │ - kubectl rollout status ...                         │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    │  ┌──────────────────────▼──────────────────────────────────┐   │
    │  │ Stage 8: Verify Deployment                            │   │
    │  │ - Check pods are running                              │   │
    │  │ - Get latest logs                                     │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                         │                                       │
    └─────────────┬───────────┘                                       │
                  │                                                   │
      ┌───────────▼───────────┐                                       │
      │ Pipeline Summary      │                                       │
      │ ✅ Success / ❌ Failed│                                       │
      └───────────────────────┘                                       │
                  │
                  │ (on success)
         ┌────────▼────────┐
         │   ECR Updated   │
         │ agrox/app:###   │
         └────────┬────────┘
                  │
         ┌────────▼────────────────────────────┐
         │  EKS Automatically Detects Change   │
         │  - Kubelet checks image hash        │
         │  - Pulls new image from ECR         │
         │  - Terminates old pods              │
         │  - Starts new pods                  │
         │  - Health checks pass               │
         │  - Service receives traffic         │
         └────────┬────────────────────────────┘
                  │
         ┌────────▼────────┐
         │  App Updated!   │
         │  Zero downtime  │
         └─────────────────┘
```

## 📊 Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│ User Request: http://ALB-DNS-NAME                             │
│                          │                                     │
│                    ┌─────▼──────┐                             │
│                    │ Internet   │                             │
│                    │ Gateway    │                             │
│                    └─────┬──────┘                             │
│                          │                                     │
│                    ┌─────▼──────────────┐                     │
│                    │  ALB               │                     │
│                    │ Port 80            │                     │
│                    │ agrox-alb          │                     │
│                    └─────┬──────────────┘                     │
│                          │                                     │
│         ┌────────────────┼────────────────┐                  │
│         │                │                │                  │
│    ┌────▼──────┐    ┌────▼──────┐   ┌────▼──────┐           │
│    │  Node 1   │    │  Node 2   │   │ Node N    │           │
│    │ Pod: xxx  │    │ Pod: yyy  │   │ Pod: zzz  │           │
│    │ :8000     │    │ :8000     │   │ :8000     │           │
│    │ (scale... │    │ (scale... │   │ (scale... │           │
│    │  2-6)     │    │  2-6)     │   │  2-6)     │           │
│    │           │    │           │   │           │           │
│    │ agrox-app │    │ agrox-app │   │ agrox-app │           │
│    │ Container │    │ Container │   │ Container │           │
│    │           │    │           │   │           │           │
│    │ ┌─────┐   │    │ ┌─────┐   │   │ ┌─────┐   │           │
│    │ │Flask│   │    │ │Flask│   │   │ │Flask│   │           │
│    │ │App  │   │    │ │App  │   │   │ │App  │   │           │
│    │ │:8000│   │    │ │:8000│   │   │ │:8000│   │           │
│    │ └─────┘   │    │ └─────┘   │   │ └─────┘   │           │
│    └────┬──────┘    └────┬──────┘   └────┬──────┘           │
│         │                │                │                  │
│         └────────────────┼────────────────┘                  │
│                          │                                     │
│                   Response sent                              │
│                   HTML content                               │
│                          │                                     │
│                   Browser displays                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔐 Networking & Security

```
                    ┌─────────────────────────────┐
                    │     Internet (0.0.0.0/0)    │
                    └─────────────────┬───────────┘
                                      │
                                      │ HTTPS/HTTP
                              ┌───────▼────────┐
                              │ Security Group │
                              │  agrox-alb-sg  │
                              │  Allow: 80/443 │
                              └───────┬────────┘
                                      │
                      ┌───────────────▼───────────────┐
                      │  PUBLIC SUBNETS              │
                      │  10.0.1.0/24, 10.0.2.0/24   │
                      │  ┌──────────────────────┐   │
                      │  │ NAT Gateways (2)    │   │
                      │  │ (for private subnet │   │
                      │  │  internet access)   │   │
                      │  └──────────────────────┘   │
                      │  ┌──────────────────────┐   │
                      │  │  ALB                │   │
                      │  │  agrox-alb          │   │
                      │  └────────┬─────────────┘   │
                      └───────────┼─────────────────┘
                                  │
                      ┌───────────▼────────────────┐
                      │ Security Group            │
                      │  agrox-eks-nodes-sg       │
                      │  Allow: from ALB/nodes    │
                      └───────────┬────────────────┘
                                  │
                      ┌───────────▼───────────────┐
                      │  PRIVATE SUBNETS          │
                      │  10.0.10.0/24             │
                      │  10.0.11.0/24             │
                      │  ┌───────────────────┐   │
                      │  │ EC2 Nodes         │   │
                      │  │ (t3.medium)       │   │
                      │  │                   │   │
                      │  │ EKS Pods          │   │
                      │  │ (agrox-app)       │   │
                      │  └───────────────────┘   │
                      └───────────────────────────┘
                                  │
                      ┌───────────▼───────────────┐
                      │  NAT Gateway (Private    │
                      │  subnet → Internet)      │
                      └───────────────────────────┘
```

## 📦 Container Architecture

```
Docker Image: 123456789.dkr.ecr.us-east-1.amazonaws.com/agrox/app:latest

┌──────────────────────────────────────────────────┐
│         Docker Container (Port 8000)             │
│                                                   │
│  ┌────────────────────────────────────────────┐ │
│  │  Flask Application (app.py)                │ │
│  │                                            │ │
│  │  ✓ Crop Recommendation System             │ │
│  │  ✓ Fertilizer Recommendation System       │ │
│  │  ✓ Price Prediction System                │ │
│  │                                            │ │
│  │  Environment:                             │ │
│  │  - FLASK_ENV: production                 │ │
│  │  - FLASK_SECRET_KEY: [from Secret]       │ │
│  │  - LOG_LEVEL: INFO                       │ │
│  └────────────────────────────────────────────┘ │
│                          │                      │
│              ┌───────────▼──────────┐          │
│              │ Models (Pre-trained) │          │
│              │ ✓ Crop RF Model      │          │
│              │ ✓ Fertilizer Model   │          │
│              │ ✓ Price LSTM Model   │          │
│              └──────────────────────┘          │
│                                                   │
└──────────────────────────────────────────────────┘
```

---

**This diagram represents your complete AgroX AWS infrastructure!**
