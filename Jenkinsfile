pipeline {
  agent any
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
    SSH_CREDENTIALS = credentials('sshkey-docker-ec2')
    DOCKER_SERVER_IP = '47.128.70.240'
  }
  stages {
    stage('Clone Repository') {
      steps {
        script {
          git branch: 'main', url: 'https://github.com/Nguyen1611/CICD-pipeline.git'
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          dockerImage = docker.build("${DOCKERHUB_CREDENTIALS_USR}/myapp:latest", "app")
        }
      }
    }
    stage('Push Docker Image to DockerHub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
            dockerImage.push("latest")
          }
        }
      }
    }
    stage('Deploy with Ansible') {
      steps {
        sshagent(['sshkey-docker-ec2']) {
          script {
            sh 'ansible-playbook -i ansible/hosts.ini ansible/playbook.yml'
          }
        }
      }
    }
  }
}
