pipeline {
    agent any

    environment {
        AWS_REGION      = "ap-south-1"
        AWS_ACCOUNT_ID  = "687222805896"
        ECR_REPO        = "agrox"
        IMAGE           = "687222805896.dkr.ecr.ap-south-1.amazonaws.com/agrox"
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

        stage('Push Docker Image') {
            steps {
                sh '''
                docker push $IMAGE:latest
                echo "✅ Docker image pushed to ECR successfully"
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