pipeline {
    agent { label 'jenkins-slave' }
    environment {
        DOCKER_CREDENTIALS = credentials('dockerhub-cred')
        GITHUB_CREDENTIALS = credentials('github-creds')
    }
    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/moranelb/FollowSpot.git'
            }
        }
        stage('Build and Run with Docker Compose') {
            steps {
                sh 'docker-compose up --build -d'
            }
        }
        stage('Check PostgreSQL Status') {
            steps {
                echo 'Checking if PostgreSQL is listening on the expected socket...'
                sh 'docker exec followspot-pipeline-db-1 ls /var/run/postgresql/.s.PGSQL.5432'
                sh 'docker-compose ps'
            }
        }
        stage('Run Tests') {
            steps {
                script {
                    try {
                        sh 'docker-compose exec app coverage run -m unittest discover'
                    } catch (Exception e) {
                        echo 'Tests failed, fetching database logs...'
                        sh 'docker logs followspot-pipeline-db-1'
                        error 'Test execution failed!'
                    }
                }
            }
        }
        stage('Push to Docker Hub') {
            when {
                not {
                    expression { currentBuild.result == 'FAILURE' }
                }
            }
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-cred') {
                        sh 'docker-compose exec app docker login -u ${DOCKER_CREDENTIALS_USR} -p ${DOCKER_CREDENTIALS_PSW}'
                        sh 'docker-compose exec app docker push docker.io/library/followspot-pipeline-app:latest'
                    }
                }
            }
        }
        stage('Teardown') {
            when {
                not {
                    expression { currentBuild.result == 'FAILURE' }
                }
            }
            steps {
                echo 'Cleaning up...'
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
