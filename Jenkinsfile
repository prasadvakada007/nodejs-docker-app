pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
    DOCKER_IMAGE = "vakada007/nodejs-app"  // change to your DockerHub repo
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
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
          set -e
          node -v
          npm -v
          npm install
        '''
      }
    }

    stage('Compute Tags') {
      steps {
        script {
          def gitSha = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
          env.IMAGE_TAG = "${env.BUILD_NUMBER}-${gitSha}"
          echo "Image tag: ${env.IMAGE_TAG}"
        }
      }
    }

    stage('Docker Build') {
      steps {
        bat '''
          set -e
          docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
        '''
      }
    }

    stage('Docker Push') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-cred') {
            sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
            sh "docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest"
            sh "docker push ${DOCKER_IMAGE}:latest"
          }
          writeFile file: 'image-info.txt', text: "${DOCKER_IMAGE}:${IMAGE_TAG}"
          archiveArtifacts artifacts: 'image-info.txt'
        }
      }
    }

    stage('Trigger Deploy-Job') {
      steps {
        build job: 'Deploy-Job', parameters: [
          string(name: 'DOCKER_IMAGE', value: "${DOCKER_IMAGE}:${IMAGE_TAG}"),
          string(name: 'PORT', value: "3000")
        ], wait: false
      }
    }
  }

  post {
    success {
      echo "✅ Build complete. Pushed ${DOCKER_IMAGE}:${IMAGE_TAG}"
    }
    failure {
      echo "❌ Pipeline failed."
    }
  }
}
