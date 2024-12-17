pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = credentials('aws-region')
        AWS_S3_BUCKET = credentials('aws-s3-bucket')
        DJANGO_ALLOWED_HOSTS = credentials('django-allowed-hosts')
        DJANGO_SETTINGS_MODULE = 'kolector.settings.prod'
        DOCKER_IMAGE = 'somke01/kolector-backend:latest'
        EC2_HOST = credentials('ec2-host')
        SSH_CREDENTIALS_ID = 'ec2-ssh-creds'

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

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    echo "Building Docker image..."
                    docker build --build-arg DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE -t $DOCKER_IMAGE .
                    '''
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                    echo "Logging into DockerHub..."
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    echo "Pushing Docker image..."
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
                    echo "Copying environment variables..."
                    cat << 'ENV' > /home/ec2-user/kolector/.env
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_HOST=${POSTGRES_HOST}
DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS}
ENV

                    cd /home/ec2-user/kolector
                    docker-compose down
                    docker-compose pull
                    docker-compose up -d --remove-orphans --env-file .env
                    EOF
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up unused Docker resources...'
            sh 'docker system prune -f'
        }
        success {
            echo 'Deployment succeeded!'
        }
        failure {
            echo 'Deployment failed. Check the logs for details.'
        }
    }
}
