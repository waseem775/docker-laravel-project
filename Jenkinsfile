pipeline {
    agent any

    environment {
        DEPLOY_USER = 'ubuntu'
        DEPLOY_HOST = '54.207.234.29'
        DEPLOY_PATH = '~/laravel-docker' // or adjust as needed
        SSH_KEY_CRED_ID = 'ec2-ssh-key'  // Jenkins Credentials ID for SSH
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'git@github.com:your-org/your-repo.git'
            }
        }

        stage('Deploy on EC2') {
            steps {
                sshagent(credentials: ["${SSH_KEY_CRED_ID}"]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} << 'EOF'
                        set -e
                        cd ${DEPLOY_PATH} || {
                            echo "Cloning repo to ${DEPLOY_PATH}...";
                            git clone https://github.com/your-org/your-repo.git ${DEPLOY_PATH};
                            cd ${DEPLOY_PATH};
                        }
                        git pull origin main
                        docker stop laravel-container || true
                        docker rm laravel-container || true
                        docker build -t laravel-app .
                        docker run -d -p 8000:80 --name laravel-container laravel-app
                    EOF
                    """
                }
            }
        }
    }
}

