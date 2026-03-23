pipeline {
    agent any

    environment {
        IMAGE = "yourdockerhubusername/agrox"
        VERSION = "${BUILD_NUMBER}"
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
                    python3 mlops/retrain_pipeline.py
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE:$VERSION .
                docker tag $IMAGE:$VERSION $IMAGE:latest
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                docker push $IMAGE:$VERSION
                docker push $IMAGE:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/agrox-app agrox-app=$IMAGE:$VERSION
                '''
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