pipeline {
    agent {
        label 'jenkins-slave'
    }
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
        DOCKER_IMAGE = "moranelb/followspot"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/moranelb/FollowSpot.git', branch: 'main'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker-compose build'
                }
            }
        }
        stage('Test Application') {
            steps {
                script {
                    sh 'docker-compose up -d'
                    sleep(10) // wait for the containers to be up
                    sh 'curl -f http://localhost:3000' // Check if app is running
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    sh """
                    docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}
                    docker tag followspot_app ${DOCKER_IMAGE}:latest
                    docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
    }
    post {
        always {
            sh 'docker-compose down'
            cleanWs() // Clean up the workspace after execution
        }
    }
}
