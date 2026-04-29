pipeline {
    agent any

    environment {
        AWS_REGION      = "ap-south-1"
        AWS_ACCOUNT_ID  = "687222805896"
        ECR_REPO        = "agrox"
        IMAGE           = "687222805896.dkr.ecr.ap-south-1.amazonaws.com/agrox"
        
        AZURE_SUBSCRIPTION_ID = "263f7f3f-70d2-4638-a364-2275b2cfafb7"
        AZURE_TENANT_ID       = "2c5bdaf4-8ff2-4bd9-bd54-7c50ab219590"
        AZURE_REGISTRY        = "agrodecmacrdev.azurecr.io"
        ACR_REPO_NAME         = "agrox"
        ACR_IMAGE             = "${AZURE_REGISTRY}/${ACR_REPO_NAME}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Jayapramod/Mlops_CiCD.git'
            }
        }

        stage('Setup Python') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Train Model + Send Email') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'email-creds',
                    usernameVariable: 'EMAIL',
                    passwordVariable: 'EMAIL_PASSWORD'
                )]) {
                    sh '''
                    . venv/bin/activate

                    export EMAIL=$EMAIL
                    export EMAIL_PASSWORD=$EMAIL_PASSWORD

                    echo "🚀 Starting Model Retraining..."
                    python3 retrain_pipeline.py
                    '''
                }
            }
        }

        stage('Create ECR Repository') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    echo "✅ Checking if ECR repository exists..."
                    
                    if aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION 2>/dev/null; then
                        echo "✅ ECR repository '$ECR_REPO' already exists"
                    else
                        echo "📦 Creating ECR repository '$ECR_REPO'..."
                        aws ecr create-repository \
                            --repository-name $ECR_REPO \
                            --region $AWS_REGION \
                            --image-scanning-configuration scanOnPush=true \
                            --no-cli-pager
                        echo "✅ ECR repository '$ECR_REPO' created successfully"
                    fi
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                        | docker login --username AWS --password-stdin \
                        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE:latest .
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                docker push $IMAGE:latest
                echo "✅ Docker image pushed to ECR successfully"
                '''
            }
        }

        stage('Login to ACR via Service Principal') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'azure-sp-creds',
                    usernameVariable: 'AZURE_CLIENT_ID',
                    passwordVariable: 'AZURE_CLIENT_SECRET'
                )]) {
                    sh '''
                    echo "🔐 Authenticating with Azure Service Principal..."
                    
                    az login --service-principal \
                        -u $AZURE_CLIENT_ID \
                        -p $AZURE_CLIENT_SECRET \
                        --tenant $AZURE_TENANT_ID
                    
                    az account set --subscription $AZURE_SUBSCRIPTION_ID
                    
                    az acr login --name agrodecmacrdev
                    
                    echo "✅ Successfully logged in to ACR via Service Principal"
                    '''
                }
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                sh '''
                docker tag $IMAGE:latest $ACR_IMAGE:latest
                docker tag $IMAGE:latest $ACR_IMAGE:${BUILD_NUMBER}
                docker push $ACR_IMAGE:latest
                docker push $ACR_IMAGE:${BUILD_NUMBER}
                echo "✅ Docker image pushed to ACR successfully"
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
        always {
            sh 'rm -rf venv'
        }
    }
}