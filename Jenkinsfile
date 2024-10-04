pipeline {
    agent any

    environment {
        DOCKER_CREDS = credentials('dockerhub-cred')
        GITHUB_CREDS = credentials('github-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                // Check out the code from the repository
                git branch: 'master', url: 'https://github.com/moranelb/FollowSpot.git', credentialsId: 'github-creds'
            }
        }

        stage('Check PATH') {
            steps {
                script {
                    // Verify the PATH to see if Docker is included
                    sh 'echo $PATH'
                }
            }
        }

        stage('Check Docker') {
            steps {
                script {
                    // Ensure Docker is installed and accessible
                    try {
                        sh 'docker --version'
                    } catch (Exception e) {
                        error('Docker is not installed or not accessible in the Jenkins environment.')
                    }
                }
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

        stage('Check PostgreSQL Status') {
            steps {
                echo 'Checking if PostgreSQL is listening on the expected socket...'
                script {
                    try {
                        // Ensure PostgreSQL is running and healthy
                        sh 'docker exec followspot-pipeline-db-1 ls /var/run/postgresql/.s.PGSQL.5432'
                        sh 'docker-compose ps'
                    } catch (Exception e) {
                        error('PostgreSQL is not healthy or not listening as expected.')
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    try {
                        // Run the test suite using coverage
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
                not {
                    equals expected: 'FAILURE', actual: currentBuild.result
                }
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
