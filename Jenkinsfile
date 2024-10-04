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
                        sh 'docker-compose up --build -d'
                    } catch (Exception e) {
                        error('Error while building or running Docker Compose.')
                    }
                }
            }
        }

        stage('Check PostgreSQL Status') {
            steps {
                echo 'Checking if PostgreSQL is running...'
                script {
                    try {
                        sh 'docker-compose exec db pg_isready -U postgres'  // Updated to use postgres
                    } catch (Exception e) {
                        error('PostgreSQL is not healthy.')
                    }
                }
            }
        }

        stage('Verify PostgreSQL Users') {
            steps {
                script {
                    echo 'Verifying PostgreSQL users...'
                    sh 'docker-compose exec db psql -U postgres -d appdb -c "\\du"'  // Updated to use postgres
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    try {
                        sh 'sleep 5' // Give the app time to start
                        sh 'docker-compose exec app coverage run -m unittest discover'
                    } catch (Exception e) {
                        echo 'Tests failed, fetching application logs...'
                        sh 'docker logs followspot-pipeline-app-1' // Fetching application logs
                        echo 'Fetching database logs...'
                        sh 'docker logs followspot-pipeline-db-1' // Fetching database logs
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
