pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
    DOCKER_IMAGE = "vakada007/nodejs-app"
    IMAGE_TAG = ""
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
          node -v
          npm -v
          npm install
        '''
      }
    }

    stage('Compute Tags') {
      steps {
        script {
          // Run git command and clean output
          def gitSha = bat(
            script: "git rev-parse --short HEAD",
            returnStdout: true
          ).trim().split("\\r?\\n")[-1]   // take last line only

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
            bat "docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest"
            bat "docker push ${DOCKER_IMAGE}:latest"
          }
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
