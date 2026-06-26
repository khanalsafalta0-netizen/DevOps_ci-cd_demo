#!/bin/bash
# End-to-end pipeline run, meant to be triggered manually from a Codespace terminal.
# Mirrors the same stages as the Jenkinsfile: Build -> Test -> Package -> Release -> Deploy.
set -e

# ---- EDIT THESE THREE VALUES ----
DOCKERHUB_USERNAME="safaltakhanal"
AWS_KEY_PAIR_NAME="devops-demo-key"      # must already exist in your AWS account
SSH_KEY_PATH="/home/codespace/.ssh/devops-demo-key.pem"             # path to the matching private key file
# ----------------------------------

IMAGE_NAME="$DOCKERHUB_USERNAME/devops-cicd-demo"
IMAGE_TAG="$(date +%Y%m%d%H%M%S)"

echo "==> [Build] Compiling with Maven"
cd app
mvn clean compile

echo "==> [Test] Running unit tests"
mvn test

echo "==> [Package] Building the jar"
mvn package -DskipTests

echo "==> [Release] Building Docker image: $IMAGE_NAME:$IMAGE_TAG"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" -t "$IMAGE_NAME:latest" .

echo "==> [Release] Pushing image to Docker Hub"
docker push "$IMAGE_NAME:$IMAGE_TAG"
docker push "$IMAGE_NAME:latest"
cd ..

echo "==> [Deploy] Provisioning AWS infrastructure with Terraform"
cd terraform
terraform init -input=false
terraform apply -auto-approve -var="key_pair_name=$AWS_KEY_PAIR_NAME"

EC2_IP=$(terraform output -raw instance_public_ip)
cd ..

echo "==> [Deploy] Waiting 30s for the EC2 instance to finish booting and installing Docker"
sleep 30

echo "==> [Deploy] Deploying container to EC2 ($EC2_IP)"
chmod 400 "$PEM_PATH"
ssh -o StrictHostKeyChecking=no -i "$PEM_PATH" ubuntu@"$EC2_IP" "
  docker pull $IMAGE_NAME:latest &&
  docker stop devops-demo || true &&
  docker rm devops-demo || true &&
  docker run -d --name devops-demo -p 80:8080 $IMAGE_NAME:latest
"

echo ""
echo "==> Done. App is live at: http://$EC2_IP"
echo "==> Version check: http://$EC2_IP/version"
