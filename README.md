# AgroX - Agricultural ML Platform

**Version:** 2.0 (MLOps/DevOps Edition) | **Status:** Production Ready  
**Multi-cloud Deployment:** AWS (ECS/ECR) | Azure (AKS) | Kubernetes On-Premises

## Overview

AgroX delivers three ML-powered agricultural services via containerized microservices with full Infrastructure-as-Code (IaC) and CI/CD automation:

- **Crop Recommendation**: Random Forest classifier on soil NPK + environmental factors
- **Fertilizer Recommendation**: Nutrient optimization based on crop type & soil conditions  
- **Price Prediction**: LSTM time-series forecasting for 5-day crop price trends

## ML Models

| Model | Algorithm | Input | Output | Location |
|-------|-----------|-------|--------|----------|
| Crop Recommendation | Random Forest | N, P, K, temperature, humidity, pH, rainfall (7 features) | Crop type | `crop_recommendation/best_rf_model.joblib` |
| Fertilizer | Random Forest | Temperature, humidity, moisture, soil type, crop, NPK nutrients | Fertilizer name | `fertilizer_recommendation/fertilizer.csv` (training) |
| Price Prediction | LSTM (30-day window) | Historical daily prices | 5-day forecast + visualization | `crop_price_prediction/lstm_model.h5` |

**Retraining:** Automated via `retrain_pipeline.py` with accuracy metrics & email notifications.

## Multi-Cloud Infrastructure

### AWS Deployment (ECS/ECR)
Terraform modules in `/terraform/` for ECS on EC2:
```bash
cd terraform/environments/dev
terraform plan
terraform apply
```
**Architecture:** ALB → ECS Cluster → ECR (container registry) → Auto-scaling group  
**Resources:** Application Load Balancer, ECS Service, EC2 instances, CloudWatch logs

### Azure Deployment (AKS)
Terraform modules in `/azure/` for Azure Kubernetes Service:
```bash
cd azure/environments/dev
terraform plan
terraform apply
```
**Architecture:** AKS cluster with networking, ACR (container registry), KeyVault for secrets  
**Features:** Auto-scaling node pools, managed Kubernetes, built-in monitoring

## CI/CD Pipeline (Jenkins)

**Jenkinsfile** automates model retraining, containerization, and deployment on git push:

```
Trigger (webhook) → Checkout code → Retrain models (retrain_pipeline.py)
  → Docker build & push to registry (ECR/ACR/DockerHub)
  → Deploy to target platform (ECS/AKS/K8s) → Smoke tests → Email report
```

**Pipeline Configuration:**
1. **GitHub Webhook** triggers on dataset updates  
2. **Model Retraining**: Computes accuracy, validates metrics, sends email notifications
3. **Container Build**: Docker image with models → registry push
4. **Deployment**:
   - AWS: `terraform apply` + ECS service update
   - Azure: Push to ACR + update AKS deployment  
   - K8s: `kubectl apply -f k8s-deployment.yaml`
5. **Secrets Management**: Jenkins credentials for DockerHub, SMTP, cloud providers

**Setup:**
- Jenkins Credentials: docker-registry, smtp-server, aws-access-key, azure-credentials
- Enable GitHub webhook for push events
- Set build parameters: MODEL_THRESHOLD, DEPLOYMENT_ENV

## Local Development & Testing

**Setup:**
```bash
python3 -m venv myenv && source myenv/bin/activate
pip install -r requirements.txt
python3 health_check.py  # Verify all dependencies
```

**Train Models:**
```bash
python3 crop_and_fertilizer_reccomend.py
python3 crop_price_predictor.py --train
python3 retrain_pipeline.py  # Full MLOps pipeline with metrics
```

**Run Locally:**
```bash
python3 app.py  # Flask app on http://localhost:5000
```

**Docker Test:**
```bash
docker build -t agrox:dev .
docker run -p 5000:5000 agrox:dev
```

## Data Format

Place CSV files in respective directories:

**crop_recommendation.csv:**
```
N,P,K,temperature,humidity,ph,rainfall,label
90,42,43,20.87,82.00,6.50,202.93,rice
```

**fertilizer.csv:**
```
Temperature,Humidity,Moisture,Soil Type,Crop Type,Nitrogen,Potassium,Phosphorous,Fertilizer Name
26,52,38,Sandy,Maize,37,0,0,Urea
```

**historical_prices.csv:**
```
date,crop_name,price,market_location
2023-01-01,rice,24.50,Mumbai
```

## Project Structure

```
├── app.py                           # Flask web application
├── main.py                          # Agricultural Assistant class
├── retrain_pipeline.py              # MLOps retraining orchestrator
├── health_check.py                  # Pre-flight diagnostics
├── Jenkinsfile                      # CI/CD pipeline definition
├── dockerfile                       # Container build spec
├── docker-compose.yml               # Local dev stack
├── crop_recommendation/             # Crop ML model & data
├── fertilizer_recommendation/       # Fertilizer ML model & data
├── crop_price_prediction/           # Price LSTM model & data
├── templates/ & static/             # Web UI (Flask)
├── terraform/                       # AWS ECS/ECR IaC (dev/prod envs)
├── azure/                           # Azure AKS IaC (dev/prod envs)
├── requirements.txt                 # Python dependencies
└── README.md                        # This file
```

## Monitoring & Troubleshooting

**Health Check:**
```bash
python3 health_check.py  # Validates datasets, models, dependencies, pipeline readiness
```

**Docker Issues:**
```bash
docker build --verbose -t agrox:latest .
docker logs <container-id>
```

**Kubernetes Issues:**
```bash
kubectl describe pod <pod-name>
kubectl logs -f deployment/agrox-app
kubectl get events
```

**Terraform Issues:**
```bash
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy  # For cleanup
```

**Model Performance:**
- Monitor accuracy metrics in email reports from `retrain_pipeline.py`
- Check Jenkins logs for pipeline execution details
- Review CloudWatch (AWS) or Azure Monitor for infrastructure metrics