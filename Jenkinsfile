pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = credentials('aws-region')
        AWS_S3_BUCKET = credentials('aws-s3-bucket')
        DJANGO_ALLOWED_HOSTS = credentials('django-allowed-hosts')
        DJANGO_SETTINGS_MODULE = 'kolector.settings.prod'
        DOCKER_IMAGE = 'somke01/kolector-backend:latest'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        EC2_HOST = credentials('ec2-host')
        SSH_CREDENTIALS_ID = 'ec2-ssh-creds'
        DOCKERHUB_CREDS = 'dockerhub-creds'

        POSTGRES_DB = credentials('db-name')
        POSTGRES_USER = credentials('db-user')
        POSTGRES_PASSWORD = credentials('db-password')
        POSTGRES_HOST = credentials('db-host')
        POSTGRES_PORT = credentials('db-port')
        CORS_ALLOWED_ORIGINS = credentials('cors-allowed-origins')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/SomkeneA/kolector.git'
            }
        }

        stage('Verify Environment Variables') {
            steps {
                echo "Verifying Environment Variables..."
                sh '''
                echo "DJANGO_ALLOWED_HOSTS=$DJANGO_ALLOWED_HOSTS"
                echo "POSTGRES_DB=$POSTGRES_DB"
                echo "POSTGRES_USER=$POSTGRES_USER"
                echo "POSTGRES_HOST=$POSTGRES_HOST"
                echo "POSTGRES_PORT=$POSTGRES_PORT"
                echo "CORS_ALLOWED_ORIGINS=$CORS_ALLOWED_ORIGINS"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                    docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ec2-user@${EC2_HOST} << EOF
                    echo "Starting Deployment on EC2..."
                    cd /home/ec2-user/kolector
                    export POSTGRES_DB=${POSTGRES_DB}
                    export POSTGRES_USER=${POSTGRES_USER}
                    export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
                    export POSTGRES_HOST=${POSTGRES_HOST}
                    export POSTGRES_PORT=${POSTGRES_PORT}
                    docker-compose down
                    docker-compose pull
                    docker-compose up -d
                    EOF
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker resources...'
            sh 'docker system prune -f'
            sh 'docker volume prune -f'
        }
        success {
            echo 'Deployment succeeded!'
        }
        failure {
            echo 'Deployment failed. Check the logs for details.'
        }
    }
}
