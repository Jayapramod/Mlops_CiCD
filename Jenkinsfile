pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'your-dockerhub-username/agrox'
        DOCKER_TAG = 'latest'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        SMTP_SERVER = credentials('smtp-server')
        SMTP_PORT = credentials('smtp-port')
        SENDER_EMAIL = credentials('sender-email')
        SENDER_PASSWORD = credentials('sender-password')
        RECIPIENT_EMAIL = credentials('recipient-email')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Retrain Models') {
            steps {
                sh '''
                    python3 -m venv venv
                    source venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    
                    export SMTP_SERVER=$SMTP_SERVER
                    export SMTP_PORT=$SMTP_PORT
                    export SENDER_EMAIL=$SENDER_EMAIL
                    export SENDER_PASSWORD=$SENDER_PASSWORD
                    export RECIPIENT_EMAIL=$RECIPIENT_EMAIL
                    
                    echo "🚀 Starting Model Retraining..."
                    python3 retrain_pipeline.py
                    
                    if [ $? -ne 0 ]; then
                        echo "❌ Model retraining failed!"
                        exit 1
                    fi
                    
                    echo "✅ Model retraining completed successfully!"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker logout
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl set image deployment/agrox-app agrox-app=${DOCKER_IMAGE}:${DOCKER_TAG}'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        always {
            sh 'rm -rf venv'
        }
    }
}