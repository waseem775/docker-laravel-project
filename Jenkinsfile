pipeline {
    agent any

    environment {
        DEPLOY_USER = 'ubuntu'
        DEPLOY_HOST = '54.207.234.29' // Your EC2 instance public IP
        DEPLOY_DIR = '~/laravel-docker' // Adjust if needed
        IMAGE_NAME = 'laravel-app'
        CONTAINER_NAME = 'laravel-container'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/waseem775/docker-laravel-project.git'
            }
        }

        stage('Deploy to EC2 via SSH') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) { // Replace with your Jenkins SSH Credential ID
                    sh """
                    ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} << EOF
                        set -e
                        cd ${DEPLOY_DIR} || {
                            echo "Cloning repo into ${DEPLOY_DIR}..."
                            git clone https://github.com/waseem775/docker-laravel-project.git ${DEPLOY_DIR}
                            cd ${DEPLOY_DIR}
                        }

                        echo "Pulling latest changes..."
                        cd ${DEPLOY_DIR}
                        git pull origin main

                        echo "Stopping existing container if running..."
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true

                        echo "Building Docker image..."
                        docker build -t ${IMAGE_NAME} .

                        echo "Running new container..."
                        docker run -d --name ${CONTAINER_NAME} -p 8000:80 ${IMAGE_NAME}
                    EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Deployment Failed!'
        }
    }
}

