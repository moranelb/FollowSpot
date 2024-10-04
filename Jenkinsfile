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
                        echo 'Build or startup failed. Fetching PostgreSQL logs...'
                        sh 'docker logs followspot-pipeline-db-1 || true'
                        throw e
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    try {
                        // Ensure DB setup and tests are run correctly
                        sh 'docker-compose exec app flask db upgrade'  // Adjust for migrations
                        sh 'docker-compose exec app coverage run -m unittest discover'
                    } catch (e) {
                        echo 'Test execution failed. Fetching app and db logs...'
                        sh 'docker logs followspot-pipeline-app-1 || true'
                        sh 'docker logs followspot-pipeline-db-1 || true'
                        throw e
                    }
                }
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
                    // Clean up Docker containers and volumes after build
                    sh 'docker-compose down -v'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
