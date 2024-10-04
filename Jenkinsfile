pipeline {
    agent { label 'jenkins-slave' }

    environment {
        DOCKER_CREDS = credentials('dockerhub-cred')
        GITHUB_CREDS = credentials('github-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/moranelb/FollowSpot.git', credentialsId: 'github-creds'
            }
        }

        stage('Build and Run with Docker Compose') {
            steps {
                script {
                    try {
                        // Build and run the app with Docker Compose
                        sh 'docker-compose up --build -d'
                    } catch (Exception e) {
                        error('Error while building or running Docker Compose.')
                    }
                }
            }
        }

        stage('Verify Script Permissions in Container') {
            steps {
                script {
                    try {
                        // Check permissions inside the container for wait-for-postgres.sh
                        sh 'docker-compose exec app ls -l /app/wait-for-postgres.sh'
                    } catch (Exception e) {
                        error('Script permissions are incorrect in the running container.')
                    }
                }
            }
        }

        stage('Check PostgreSQL Status') {
            steps {
                echo 'Checking if PostgreSQL is running...'
                script {
                    try {
                        // Ensure PostgreSQL is healthy
                        sh 'docker-compose exec db pg_isready'
                    } catch (Exception e) {
                        error('PostgreSQL is not healthy.')
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    try {
                        // Run tests
                        sh 'docker-compose exec app coverage run -m unittest discover'
                    } catch (Exception e) {
                        echo 'Tests failed, fetching database logs...'
                        sh 'docker logs followspot-pipeline-db-1'
                        error('Tests failed during execution.')
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                not { equals expected: 'FAILURE', actual: currentBuild.result }
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-cred') {
                        def appImage = docker.image('followspot-pipeline-app')
                        appImage.push("${env.BUILD_NUMBER}")
                        appImage.push('latest')
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker-compose down'
            cleanWs()
        }
    }
}
