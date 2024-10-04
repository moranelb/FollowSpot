pipeline {
    agent any

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
