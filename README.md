# Agricultural Assistant

An integrated system for crop recommendation, fertilizer recommendation, and crop price prediction.

**Version:** 2.0 (MLOps Edition)  
**Status:** Production Ready with CI/CD Pipeline

## What's New in v2.0

✅ **Automated Model Retraining** - `retrain_pipeline.py`  
✅ **Email Notifications** - Success/failure reports with metrics  
✅ **Docker Containerization** - Complete package with models & frontend  
✅ **Kubernetes Deployment** - Auto-scaling, rolling updates  
✅ **Jenkins CI/CD** - Automated pipeline on dataset changes  
✅ **Health Check Tool** - Verify system readiness  

## Project Overview

This project combines three key agricultural assistance tools:

1. **Crop Recommendation System**: Suggests suitable crops based on soil parameters and environmental conditions.
2. **Fertilizer Recommendation System**: Recommends appropriate fertilizers based on soil nutrients and crop type.
3. **Crop Price Prediction System**: Forecasts crop prices for the next 5 days based on historical price data.

## System Architecture

### 1. Crop Recommendation System
- Uses a Random Forest Classifier to recommend crops based on soil composition and environmental factors.
- Input features: N (Nitrogen), P (Phosphorus), K (Potassium), temperature, humidity, pH, and rainfall.
- Output: Recommended crop type.

### 2. Fertilizer Recommendation System
- Recommends fertilizers based on soil nutrient levels and crop requirements.
- Input features: Temperature, humidity, moisture, soil type, crop type, nitrogen, potassium, and phosphorous values.
- Output: Recommended fertilizer and nutrient improvement suggestions.

### 3. Crop Price Prediction System
- Uses a LSTM (Long Short-Term Memory) neural network to predict future crop prices.
- Input: Historical price data for specific crops.
- Output: Predicted prices for the next 5 days and a visualization graph.

## Project Structure & Files

### Core Application Files
```
├── app.py                              # Flask web application
├── main.py                             # Agricultural Assistant class
├── crop_price_predictor.py             # Price prediction model & training
├── crop_and_fertilizer_reccomend.py    # Crop & fertilizer training
```

### MLOps & Pipeline Files
```
├── retrain_pipeline.py                 # Automated retraining orchestrator
├── health_check.py                     # Pre-flight diagnostics
├── Jenkinsfile                         # Jenkins CI/CD pipeline definition
├── k8s-deployment.yaml                 # Kubernetes deployment config
├── dockerfile                          # Docker image build config
```

### Model Directories
```
├── crop_recommendation/
│   ├── best_rf_model.joblib           # Trained Random Forest model
│   ├── scaler.joblib                  # Feature scaler
│   ├── label_encoder.joblib           # Label encoder
│   └── crop_recommendation.csv        # Training data
├── fertilizer_recommendation/
│   ├── fertilizer_model.pkl           # Trained model
│   ├── label_encoders.pkl             # Categorical encoders
│   └── fertilizer.csv                 # Training data
├── crop_price_prediction/
│   ├── lstm_model.h5                  # LSTM neural network
│   ├── price_scaler.pkl               # Price scaler
│   └── historical_prices.csv          # Training data
```

### Frontend Files
```
├── templates/
│   ├── index.html                     # Home page
│   ├── crop_recommend.html            # Crop recommendation form
│   ├── fertilizer_recommend.html      # Fertilizer recommendation form
│   ├── price_predict.html             # Price prediction form
│   ├── results/                       # Result pages
│   │   ├── crop_result.html
│   │   ├── fertilizer_result.html
│   │   └── price_result.html
│   └── base.html                      # Base template
└── static/
    └── styles.css                     # Styling
```

### Configuration & Documentation
```
├── requirements.txt                    # Python dependencies
├── README.md                          # This file
└── setup.txt                          # Setup notes
```

## Data Requirements

### Crop Recommendation Data
Format:
```
N,P,K,temperature,humidity,ph,rainfall,label
90,42,43,20.87,82.00,6.50,202.93,rice
85,58,41,21.77,80.31,7.03,226.65,rice
...
```

### Fertilizer Recommendation Data
Format:
```
Temperature,Humidity,Moisture,Soil Type,Crop Type,Nitrogen,Potassium,Phosphorous,Fertilizer Name
26,52,38,Sandy,Maize,37,0,0,Urea
29,52,45,Loamy,Sugarcane,12,0,36,DAP
...
```

### Crop Price Historical Data
Format:
```
date,crop_name,price,market_location
2023-01-01,rice,24.50,Mumbai
2023-01-02,rice,24.75,Mumbai
...
```

## How to Use

### Setup
1. Install required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Place your CSV data files in their respective directories.

### Running the Application

#### Option 1: Local Development
```bash
# Train models (one-time or for retraining)
python3 crop_and_fertilizer_reccomend.py
python3 crop_price_predictor.py --train

# Run Flask app
python3 app.py
# Visit: http://localhost:5000
```

#### Option 2: Automated MLOps Pipeline
```bash
# Retrains all models, calculates accuracy, sends email
python3 retrain_pipeline.py
```

#### Option 3: Docker
```bash
# Build image
docker build -t agrox:latest .

# Run container
docker run -p 5000:5000 agrox:latest
# Visit: http://localhost:5000
```

#### Option 4: Kubernetes
```bash
# Deploy to cluster
kubectl apply -f k8s-deployment.yaml

# Check status
kubectl get pods
kubectl get svc agrox-service

# Access via LoadBalancer IP
```

### Web Interface Features
- **Crop Recommendation**: Input soil parameters, get crop suggestions
- **Fertilizer Recommendation**: Get fertilizer recommendations
- **Price Prediction**: Forecast prices for next 5 days
- **Report Generation**: Download analysis reports

## MLOps Pipeline & Production Deployment

### Model Retraining Pipeline
The `retrain_pipeline.py` automates the complete training workflow:

**Features:**
- ✅ Trains all 3 models automatically
- ✅ Calculates accuracy metrics
- ✅ Sends email reports with results
- ✅ Handles errors gracefully

**Email Configuration (Optional):**
```bash
export SMTP_SERVER=smtp.gmail.com
export SMTP_PORT=587
export SENDER_EMAIL=your-email@gmail.com
export SENDER_PASSWORD=your-app-password
export RECIPIENT_EMAIL=recipient@example.com

python3 retrain_pipeline.py
```

### Docker Containerization

**Dockerfile Includes:**
- Python 3.9 base image
- All dependencies from requirements.txt
- Complete project code
- Trained models (pre-built)
- Frontend (templates + static files)

**Build & Run:**
```bash
# Build
docker build -t agrox:latest .

# Run
docker run -p 5000:5000 agrox:latest

# Push to DockerHub
docker login
docker tag agrox:latest your-username/agrox:latest
docker push your-username/agrox:latest
```

### Kubernetes Deployment

**Configuration:** `k8s-deployment.yaml`
- **Deployment:** 1 pod replica, auto-restart
- **Service:** LoadBalancer on port 80 → 5000
- **Resources:** 512Mi RAM request, 1Gi RAM limit

**Deploy:**
```bash
# Apply configuration
kubectl apply -f k8s-deployment.yaml

# Check status
kubectl get deployment
kubectl get pods
kubectl get svc agrox-service

# View logs
kubectl logs -f deployment/agrox-app

# Scale replicas
kubectl scale deployment agrox-app --replicas=3
```

### Jenkins CI/CD Pipeline

**Jenkinsfile Stages:**
1. **Checkout** - Clone repository
2. **Retrain Models** - Run `retrain_pipeline.py`
3. **Build Docker** - Create image with latest models
4. **Push DockerHub** - Push to registry
5. **Deploy K8s** - Update Kubernetes deployment

**Setup (One-time):**
```bash
# 1. Add Jenkins Credentials
Manage Jenkins → Manage Credentials
- dockerhub-credentials (Username/Password)
- smtp-server: smtp.gmail.com
- smtp-port: 587
- sender-email, sender-password, recipient-email

# 2. Create Pipeline Job
New Job → Pipeline
Script Path: Jenkinsfile

# 3. Add GitHub Webhook (Optional)
GitHub Repo Settings → Webhooks
Payload URL: http://jenkins-server/github-webhook/
```

**Auto-Trigger:**
- Dataset updated → Git push
- Webhook triggers Jenkins
- Pipeline retrains models, builds Docker, deploys to K8s
- Email report sent

### Health Check Utility

**Verify System Readiness:**
```bash
python3 health_check.py
```

**Checks:**
- ✅ Datasets present
- ✅ Models exist
- ✅ Python packages installed
- ✅ Pipeline files ready
- ✅ Email configuration
- ✅ Generates JSON report

## Technical Implementation

### Crop Recommendation Model
- Uses Random Forest Classifier to handle the multi-class classification task.
- Features are standardized using StandardScaler.
- Uses GridSearchCV for hyperparameter tuning.

### Fertilizer Recommendation Model
- Uses Random Forest Classifier for recommending fertilizers.
- Incorporates domain knowledge through a dictionary of nutrient-specific suggestions.

### Price Prediction Model
- Uses LSTM neural network architecture which is well-suited for time series forecasting.
- Sequence length of 30 days (uses past month's data to predict next 5 days).
- Preprocessing includes scaling the prices and creating sequential data.

## Extending the Project

### Adding More Crops/Fertilizers
- Update the respective CSV files with new data.
- Retrain the models using the original scripts.

### Improving Price Prediction
- Consider adding more features such as weather data, seasonal trends, or economic indicators.
- Experiment with different model architectures like GRU, bidirectional LSTM, or transformer models.

### Web Interface
- The system can be extended with a web interface using frameworks like Flask or Django.
- APIs can be created to expose the functionality to other applications.

## Limitations and Future Work

- The current crop recommendation doesn't account for seasonal variations.
- The fertilizer recommendation doesn't consider economic factors or availability.
- Price prediction could be improved with more robust data and additional features.
- Integration with real-time weather data and market information would enhance predictions.

## Troubleshooting

### Issue: Models not trained
```bash
python3 health_check.py
# Check which files are missing
```

### Issue: Pipeline training fails
```bash
# Check datasets exist
ls crop_recommendation/crop_recommendation.csv
ls fertilizer_recommendation/fertilizer.csv
ls crop_price_prediction/historical_prices.csv

# Run pipeline with verbose output
python3 retrain_pipeline.py
```

### Issue: Docker build fails
```bash
# Check requirements.txt
pip install -r requirements.txt --dry-run

# Build with debug
docker build --verbose -t agrox:latest .
```

### Issue: Kubernetes pod not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check image availability
docker images | grep agrox
```

### Issue: Email not sending
```bash
# Verify SMTP connection
telnet smtp.gmail.com 587

# Check Jenkins secrets are set correctly
# Manage Jenkins → Manage Credentials
```

## Conclusion

This Agricultural Assistant provides a comprehensive solution for farmers and agricultural professionals, combining soil analysis, fertilizer recommendation, and price prediction in one integrated system. With MLOps automation, Docker containerization, and Kubernetes orchestration, it's production-ready and scalable.

By utilizing machine learning and deep learning techniques with modern DevOps practices, it offers data-driven insights to optimize agricultural practices and decision-making at scale.