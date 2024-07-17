# CICD-pipeline

## Overview
This project demonstrates a CI/CD pipeline that automatically deploys or updates a website whenever there is a push to the GitHub repository. The pipeline utilizes Jenkins, Ansible, Docker, Prometheus, and Grafana to achieve continuous integration and deployment with monitoring capabilities.

![CICDpipeline drawio](https://github.com/user-attachments/assets/1281ca7d-c193-46b9-ba54-e8b6ee2c78e7)


## Technologies Used
- **Jenkins:** For automating the CI/CD pipeline.
- **Ansible:** For configuration management and deployment automation.
- **Docker:** For containerizing the application.


## Pipeline Workflow
1. **Clone Repository:** Jenkins clones the GitHub repository.
2. **Build Docker Image:** Jenkins builds a Docker image using the Dockerfile in the `app` directory.
3. **Push Docker Image:** Jenkins pushes the built Docker image to DockerHub.
4. **Deploy with Ansible:** Jenkins uses Ansible to deploy the Docker container on the target server.
5. **Setup Monitoring:** Jenkins ensures that Prometheus and Grafana are running for monitoring the application.

## Setup Instructions

### Prerequisites (use the terraform template in infra to create (terraform apply) )
- Jenkins installed and configured
- Ansible installed on the Jenkins server
- Docker installed on the Jenkins and target servers
- Prometheus and Grafana installed on their respective servers

### Step 1: Clone Repository
Ensure that Jenkins is configured to clone this GitHub repository whenever there is a push.

### Step 2: Build Docker Image
Jenkins will use the Dockerfile located in the `app` directory to build the Docker image
### Step 3: Push Docker Image
Jenkins will push the built Docker image to DockerHub using the credentials provided.

### Step 4: Deploy with Ansible (remember to replace the IP in hosts.ini with your docker server )
Jenkins will run the Ansible playbook to deploy the Docker container on the target server. The Ansible playbook is configured to:
- Ensure Docker is installed
- Start the Docker service
- Pull the latest Docker image from DockerHub
- Stop and remove the existing container (if any)
- Run the Docker container with the latest image

### Step 5: Setup Monitoring
Jenkins will ensure that Prometheus and Grafana are running for monitoring the application.
