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
                git branch: 'master', credentialsId: 'github-creds', url: 'https://github.com/moranelb/FollowSpot.git'
            }
        }

        stage('Build and Run with Docker Compose') {
            steps {
                script {
                    try {
                        // Build and run Docker containers
                        sh 'docker-compose up --build -d'
                    } catch (e) {
                        // Capture and print logs from the DB container if there is a failure
                        echo 'Build or startup failed. Fetching PostgreSQL logs...'
                        sh 'docker logs followspot-pipeline-db-1 || true'
                        throw e  // Rethrow the error to mark the build as failed
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                // Run tests inside the app container
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
                script {
                    // Stop and remove containers and associated volumes for clean slate
                    sh 'docker-compose down -v'
                }
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
