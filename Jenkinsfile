pipeline {
    agent {
        label 'jenkins-slave'
    }

    environment {
        GITHUB_CREDENTIALS = credentials('github-creds')
        DOCKER_CREDENTIALS = credentials('dockerhub-cred')
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/moranelb/FollowSpot.git', git branch: 'master'
            }
        }

        stage('Build and Run with Docker Compose') {
            steps {
                sh 'docker-compose up --build -d'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'docker-compose exec app coverage run -m unittest discover'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-cred') {
                        def appImage = docker.build("moranelb/followspot:${env.BUILD_NUMBER}")
                        appImage.push()
                    }
                }
            }
        }

        stage('Teardown') {
            steps {
                sh 'docker-compose down'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
