pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
    DOCKER_IMAGE = "vakada007/nodejs-app"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Node Install & Build') {
      steps {
        bat '''
          node -v
          npm -v
          npm install
        '''
      }
    }

    stage('Compute Tags') {
      steps {
        script {
          def gitSha = bat(returnStdout: true, script: '@echo off && git rev-parse --short HEAD').trim()
          env.IMAGE_TAG = "${BUILD_NUMBER}-${gitSha}"
          echo "✅ Image tag: ${env.IMAGE_TAG}"
        }
      }
    }

    stage('Docker Build') {
      steps {
        bat "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
      }
    }

    stage('Docker Push') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-cred') {
            bat "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
            bat "docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:${IMAGE_TAG}"
            bat "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
          }
        }
      }
    }

    stage('Trigger Deploy-Job') {
      steps {
        build job: 'Deploy-job',
              parameters: [
                  string(name: 'IMAGE_NAME', value: "vakada007/nodejs-app:${IMAGE_TAG}")
              ]
      }
    }
  }   // ✅ closes stages block

  post {
    success {
      echo "✅ Build complete. Pushed ${DOCKER_IMAGE}:${IMAGE_TAG}"
    }
    failure {
      echo "❌ Pipeline failed."
    }
  }
}
