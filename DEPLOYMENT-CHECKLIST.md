# ✅ AgroX AWS Setup - Complete Checklist

## 📦 What Was Created For You

### ✅ Terraform Infrastructure (AWS + EKS + ALB + ECR)
```
terraform/
├── main.tf                      # Complete AWS infrastructure (600+ lines)
├── variables.tf                 # Customizable variables
├── outputs.tf                   # Output values (endpoints, URLs, etc.)
├── terraform.tfvars.example     # Configuration template
└── README.md                    # 300+ line detailed documentation
```

### ✅ Jenkins Pipeline (ECR-Ready)
```
Jenkinsfile-ECR                 # New pipeline for ECR + EKS
                                # (replaces DockerHub approach)
```

### ✅ Documentation
```
AWS-SETUP.md                    # Quick start guide (Step-by-step)
AWS-ARCHITECTURE.md             # Visual diagrams & architecture
TERRAFORM-SUMMARY.md            # Summary of all created resources
```

## 🎯 Architecture Overview

```
GitHub → Jenkins → ECR (AWS) → EKS Cluster
                                ├─ ALB (Load Balancer)
                                ├─ 2-5 Worker Nodes
                                ├─ 2-6 Pods (auto-scaling)
                                └─ Public HTTP Endpoint
```

## 🚀 Getting Started (5 Steps)

### Step 1: AWS Setup (5 minutes)
```bash
# 1. Create AWS Account
#    Sign up at https://aws.amazon.com/

# 2. Create IAM User
#    Go to IAM → Users → Create user "jenkins-user"
#    Attach: AmazonEKSFullAccess, AmazonEC2FullAccess, AmazonECRFullAccess

# 3. Create Access Keys
#    Go to IAM → Users → jenkins-user → Security credentials → Access keys
#    👉 Save: Access Key ID & Secret Access Key

# 4. Configure AWS CLI
aws configure
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region: us-east-1
# Default output format: json

# 5. Verify
aws sts get-caller-identity
```

### Step 2: Terraform Deploy (15 minutes)
```bash
cd terraform

# Copy configuration
cp terraform.tfvars.example terraform.tfvars

# Review & edit (optional - defaults are fine)
# nano terraform.tfvars

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# ⏱️ Takes 10-15 minutes to create all resources
```

### Step 3: Configure kubectl (2 minutes)
```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --region us-east-1 --name agrox-eks

# Verify
kubectl cluster-info
kubectl get nodes
```

### Step 4: Setup Jenkins (10 minutes)
```bash
# Your Jenkins must have:
# 1. Docker Pipeline plugin installed
# 2. AWS Credentials plugin installed
# 3. Kubernetes CLI plugin installed

# Add AWS credentials to Jenkins:
# - Go to Manage Jenkins → Credentials
# - Add "aws-credentials" with your Access Key/Secret
# - Add "aws-account-id" with your 12-digit AWS Account ID
# - Add "email-creds" for SMTP (optional)

# Create Pipeline Job:
# - New Item → Pipeline
# - Build trigger: GitHub webhook (optional)
# - Pipeline script from SCM
#   - Git repo: https://github.com/Jayapramod/Mlops_CiCD.git
#   - Script path: Jenkinsfile-ECR
```

### Step 5: Test Deployment (5 minutes)
```bash
# Trigger Jenkins build manually
# Or: git push to main branch (if webhook enabled)

# Monitor:
kubectl get pods -n agrox -w

# Get application URL:
kubectl get svc -n agrox

# Access: http://[LoadBalancer-DNS]
```

**Total Setup Time: ~40 minutes** ⏱️

## 📋 Verification Checklist

- [ ] AWS credentials configured
- [ ] `terraform init` successful
- [ ] `terraform apply` completed
- [ ] `kubectl cluster-info` shows connection to agrox-eks
- [ ] `kubectl get nodes` shows 2 worker nodes
- [ ] Jenkins credentials added (aws-credentials, aws-account-id)
- [ ] Jenkins job created with Jenkinsfile-ECR
- [ ] First Jenkins build successful
- [ ] `kubectl get pods -n agrox` shows 2+ pods running
- [ ] `kubectl get svc -n agrox` shows LoadBalancer with external IP
- [ ] Application accessible via browser
- [ ] Auto-scaling working (check metrics)

## 🔄 Typical Workflow After Setup

```
1. Make code changes in GitHub
   │
2. Commit & push to main branch
   │
3. GitHub webhook triggers Jenkins
   │
4. Jenkins pipeline runs:
   - Trains models
   - Builds Docker image
   - Pushes to ECR
   - Updates EKS deployment
   │
5. EKS automatically:
   - Pulls new image
   - Replaces old pods
   - Maintains availability
   │
6. Application updated at http://ALB-URL
```

**Each update: ~5-10 minutes** ⏱️

## 📊 Resource Naming

All AWS resources follow this pattern:

```
ECR:              agrox/app
EKS Cluster:      agrox-eks
Node Group:       agrox-node-group
ALB:              agrox-alb
VPC:              agrox-vpc
Subnets:          agrox-public-subnet-1/2, agrox-private-subnet-1/2
NAT Gateways:     agrox-nat-1/2
Security Groups:  agrox-alb-sg, agrox-eks-cluster-sg, agrox-eks-nodes-sg
K8s Namespace:    agrox
K8s Deployment:   agrox-app
K8s Service:      agrox-service
HPA:              agrox-hpa
```

## 💰 Cost Breakdown

```
AWS EKS Pricing:
├─ Control plane:  $0.10/hour
├─ 2 EC2 nodes:    $0.08/hour (t3.medium)
├─ ALB:            $0.0225/hour
└─ ECR:            ~$10-20/month

Monthly: ~$150-170 for production setup
```

## 🎯 Next Steps After Deployment

### 1️⃣ Enable GitHub Webhook (Auto-deploy)
```bash
# In GitHub Repo Settings → Webhooks
# Add: https://[your-jenkins]/github-webhook/
# Now every push auto-triggers deployment
```

### 2️⃣ Setup Custom Domain (Optional)
```bash
# Get ALB DNS name
terraform output alb_dns_name

# In Route53, create A record pointing to ALB
# Then update k8s-deployment.yaml with your domain
```

### 3️⃣ Enable HTTPS (Optional)
```bash
# Create ACM certificate for your domain
# Add to ALB listener (port 443)
# Update Flask to use https
```

### 4️⃣ Setup Monitoring (Optional)
```bash
# CloudWatch Dashboards
# Prometheus + Grafana
# Application Performance Monitoring
```

### 5️⃣ Backup & Recovery (Recommended)
```bash
# ECR Image Retention: Already configured
# Terraform State: Backup to S3
# Database: Setup snapshots (if DB added)
```

## 🛠️ Common Commands After Setup

### Monitor Application
```bash
# Watch pods
kubectl get pods -n agrox -w

# View logs
kubectl logs -n agrox deployment/agrox-app -f

# Check service
kubectl get svc -n agrox

# Describe deployment
kubectl describe deployment agrox-app -n agrox
```

### Scale Application
```bash
# Increase replicas
terraform apply -var='replicas=4'

# Increase node count
terraform apply -var='node_group_desired_size=4'

# Larger instance types
terraform apply -var='node_instance_types=["t3.large"]'
```

### Update Application
```bash
# Update Docker image tag
terraform apply -var='docker_image_tag=v1.2.0'

# OR push new image, Jenkins auto-updates
git push  # Triggers Jenkins → ECR → EKS
```

### Destroy Everything
```bash
cd terraform
terraform destroy
# Type 'yes' to confirm
# ⚠️ This deletes all AWS resources
```

## 📚 Documentation Reference

| Document | Purpose | Read Time |
|----------|---------|-----------|
| AWS-SETUP.md | Quick start guide | 10 min |
| AWS-ARCHITECTURE.md | Visual diagrams | 5 min |
| TERRAFORM-SUMMARY.md | What was created | 5 min |
| terraform/README.md | Detailed reference | 30 min |
| Jenkinsfile-ECR | Pipeline stages | 5 min |

## 🔒 Security Notes

1. **Never commit credentials to git**
   - Use Jenkins Credentials Manager
   - Use AWS Secrets Manager
   - Use Kubernetes Secrets

2. **Rotate credentials regularly**
   ```bash
   # In AWS IAM, rotate access keys
   # Update Jenkins credentials
   # Restart Jenkins
   ```

3. **ECR Images**
   - Default: Only your AWS account can pull
   - Uses IAM authentication (no secrets needed)
   - Auto-cleanup old images (keeps last 10)

4. **Kubernetes Secrets**
   - FLASK_SECRET_KEY in Secrets (not ConfigMaps)
   - Update terraform/main.tf and re-apply

5. **ALB Security**
   - Public by default
   - Add WAF (Web Application Firewall) for production
   - Enable HTTPS for sensitive data

## 💡 Pro Tips

1. **Use AWS CLI for quick checks**
   ```bash
   aws eks list-clusters
   aws ecr describe-images --repository-name agrox/app
   aws elbv2 describe-load-balancers
   ```

2. **Get any output value**
   ```bash
   cd terraform
   terraform output ecr_repository_url
   terraform output alb_dns_name
   terraform output eks_cluster_endpoint
   ```

3. **Debug pod issues**
   ```bash
   # Get exact error
   kubectl describe pod <pod-name> -n agrox
   
   # Check logs
   kubectl logs <pod-name> -n agrox --previous
   
   # Execute in container
   kubectl exec -it <pod-name> -n agrox -- bash
   ```

4. **Cost optimization**
   ```bash
   # For dev/demo (save ~50%)
   terraform apply -var='node_group_min_size=1' \
                     -var='replicas=1' \
                     -var='node_instance_types=["t3.small"]'
   ```

## ❓ FAQ

**Q: Will this cost me money?**
A: Yes, ~$150-200/month for production. Stop with `terraform destroy` to avoid charges.

**Q: How long does deployment take?**
A: First deploy: 10-15 min. Updates: 2-5 min.

**Q: Can I use my own domain?**
A: Yes! Update Route53 records to point to ALB.

**Q: How do I backup my images?**
A: ECR keeps last 10 versions. For more, manually tag: `docker tag image:latest image:backup-date`

**Q: Can I scale horizontally?**
A: Yes! Pods auto-scale 2-6, nodes scale 2-5.

**Q: What if a pod crashes?**
A: Kubernetes replaces it automatically (see liveness probes).

**Q: How do I update the app?**
A: Push code → Jenkins builds → ECR updates → K8s deploys.

**Q: Can I access the cluster from my laptop?**
A: Yes! `aws eks update-kubeconfig` gives kubectl access.

**Q: Is my data secure?**
A: EKS nodes in private subnets (no internet access).
   Only through NAT gateway (one-way out).

## 🎓 Learning Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS EKS Docs](https://docs.aws.amazon.com/eks/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Docker Docs](https://docs.docker.com/)
- [Jenkins Docs](https://www.jenkins.io/doc/)

---

## ✅ You're Ready!

All files are created and ready to use. Start with:

1. **AWS Setup** - Follow AWS-SETUP.md
2. **Run Terraform** - `cd terraform && terraform apply`
3. **Setup Jenkins** - Add credentials & create job
4. **Test** - Trigger Jenkins pipeline

**Questions?** Check the detailed README files or AWS documentation.

**Good luck! 🚀**
