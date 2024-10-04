pipeline {
    agent { label 'jenkins-slave' }

    environment {
        GITHUB_CREDENTIALS = credentials('github-creds')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
    }

    stages {
        stage('Checkout SCM') {
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
                script {
                    sh 'docker exec followspot-pipeline-db-1 ls /var/run/postgresql/.s.PGSQL.5432'
                    sh 'docker-compose ps'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'docker-compose exec app coverage run -m unittest discover || docker logs followspot-pipeline-app-1'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up the workspace and containers...'
            sh 'docker-compose down'
            cleanWs()
        }
        failure {
            echo 'Tests failed, fetching logs...'
            sh 'docker logs followspot-pipeline-db-1'
            sh 'docker logs followspot-pipeline-app-1'
        }
    }
}
