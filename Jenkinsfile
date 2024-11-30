pipeline {
    agent any

    environment {
        DB_PASSWORD = credentials('qshe-db-password-id')
        MAIL_PASSWORD = credentials('qhse-email-password-id')
    }

    stages {
        stage('Pull from Git') {
            steps {
                script {
                    git url: 'git@github.com:GTS-MEGHNI/laravel-jenkins-docker-mssql.git',
                        branch: 'main',
                        credentialsId: 'qhse-api-git-key'
                }
            }
        }

        stage('Generate .env File') {
            steps {
                script {
                    sh 'echo APP_NAME=SARPI >> .env'
                    sh 'echo APP_ENV=production >> .env'
                    sh 'echo APP_KEY=base64:m1qJna2tF3xE8j38CrMTayMZSr2JnVXDSvpe0+YEdqo= >> .env'
                    sh 'echo APP_DEBUG=true >> .env'
                    sh 'echo APP_TIMEZONE=Africa/Algiers >> .env'
                    sh "echo APP_URL=${APP_URL} >> .env"
                    sh 'echo APP_LOCALE=fr >> .env'
                    sh 'echo APP_FALLBACK_LOCALE=fr >> .env'
                    sh 'echo APP_FAKER_LOCALE=en_US >> .env'
                    sh 'echo APP_MAINTENANCE_DRIVER=file >> .env'
                    sh 'echo BCRYPT_ROUNDS=12 >> .env'
                    sh 'echo LOG_CHANNEL=daily >> .env'
                    sh 'echo LOG_STACK=single >> .env'
                    sh 'echo LOG_DEPRECATIONS_CHANNEL=null >> .env'
                    sh 'echo LOG_LEVEL=debug >> .env'
                    sh 'echo DB_CONNECTION=sqlsrv >> .env'
                    sh 'echo DB_HOST=mssql >> .env'
                    sh 'echo DB_DATABASE=sarpi >> .env'
                    sh 'echo DB_USERNAME=sa >> .env'
                    sh "echo DB_PASSWORD=${DB_PASSWORD} >> .env"
                    sh 'echo SESSION_DRIVER=database >> .env'
                    sh 'echo SESSION_LIFETIME=120 >> .env'
                    sh 'echo SESSION_ENCRYPT=false >> .env'
                    sh 'echo SESSION_PATH=/ >> .env'
                    sh 'echo SESSION_DOMAIN=null >> .env'
                    sh 'echo FILESYSTEM_DISK=local >> .env'
                    sh 'echo QUEUE_CONNECTION=database >> .env'
                    sh 'echo CACHE_STORE=database >> .env'
                    sh 'echo CACHE_PREFIX= >> .env'
                    sh 'echo MAIL_MAILER=smtp >> .env'
                    sh "echo MAIL_HOST=${MAIL_HOST} >> .env"
                    sh "echo MAIL_PORT=${MAIL_PORT} >> .env"
                    sh "echo MAIL_USERNAME=${MAIL_USERNAME} >> .env"
                    sh "echo MAIL_PASSWORD=${MAIL_PASSWORD} >> .env"
                    sh 'echo MAIL_ENCRYPTION=tls >> .env'
                    sh "echo MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS} >> .env"
                    sh 'echo MAIL_FROM_NAME="SARPI" >> .env'
                    sh 'echo FIREBASE_CREDENTIALS=storage/app/firebase.json >> .env'
                    echo 'Successfully generated .env file.'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t sarpi-qhse-api .'
                    echo 'Successfully built Docker image.'
                }
            }
        }

        stage('Run Docker Compose') {
            steps {
                script {
                    sh '''
                    docker compose down laravel cron supervisor
                    docker compose up -d --build laravel cron supervisor
                    '''
                    echo 'Successfully started Docker containers.'
                }
            }
        }
        stage('Run Migrations') {
            steps {
                script {
                    sh '''
                    docker compose exec laravel php artisan migrate --force
                    '''
                    echo 'Migrations successfully executed with --force.'
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs!'
        }
    }
}
