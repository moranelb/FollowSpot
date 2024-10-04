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
                // The 'branch' argument should be outside the 'git' function and not as 'git branch:'
                git branch: 'master', credentialsId: 'github-creds', url: 'https://github.com/moranelb/FollowSpot.git'
            }
        }

        stage('Build and Run with Docker Compose') {
            steps {
                sh 'docker-compose up --build -d'
            }
        }

        stage('Run Tests') {
            steps {
                // Run the tests using 'coverage' inside the app container
                sh 'docker-compose exec app coverage run -m unittest discover'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-cred') {
                        // Build and push the Docker image to Docker Hub
                        def appImage = docker.build("moranelb/followspot:${env.BUILD_NUMBER}")
                        appImage.push()
                    }
                }
            }
        }

        stage('Teardown') {
            steps {
                // Stop and remove the Docker containers after the build
                sh 'docker-compose down'
            }
        }
    }

    post {
        always {
            // Clean the workspace after each run
            cleanWs()
        }
    }
}
