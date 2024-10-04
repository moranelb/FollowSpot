pipeline {
    agent {
        label 'docker-slave'
    }

    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-cred')
        GITHUB_CREDENTIALS = credentials('github-creds')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/moranelb/FollowSpot.git'
            }
        }

        stage('Build and Run with Docker Compose') {
            steps {
                script {
                    sh 'docker-compose down'
                    sh 'docker-compose up --build -d'
                }
            }
        }

        stage('Check PostgreSQL Status') {
            steps {
                echo 'Checking if PostgreSQL is listening on the expected socket...'
                script {
                    sh 'docker exec followspot-pipeline-db-1 ls /var/run/postgresql/.s.PGSQL.5432'
                    sh 'docker-compose ps'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'docker-compose exec app coverage run -m unittest discover'
                }
            }
            post {
                failure {
                    echo 'Tests failed, fetching database logs...'
                    sh 'docker logs followspot-pipeline-db-1'
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                not {
                    failure()
                }
            }
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    sh 'docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW'
                    sh 'docker tag followspot-pipeline-app:latest your-dockerhub-repo/followspot-pipeline-app:latest'
                    sh 'docker push your-dockerhub-repo/followspot-pipeline-app:latest'
                }
            }
        }

        stage('Teardown') {
            steps {
                echo 'Stopping and removing containers...'
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
