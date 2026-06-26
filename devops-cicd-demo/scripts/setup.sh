#!/bin/bash
# Run once when the Codespace starts. Installs Java, Maven, Terraform, AWS CLI.
# Docker is already preinstalled in GitHub Codespaces (Docker-in-Docker).
set -e

echo "==> Installing Java 17 and Maven"
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk maven unzip

echo "==> Installing Terraform"
wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip -o terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.7.5_linux_amd64.zip

echo "==> Installing AWS CLI v2"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -oq awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws/

echo "==> Versions installed:"
java -version
mvn -version
terraform -version
aws --version
docker --version

echo ""
echo "Setup complete. Next steps:"
echo "1. Run: aws configure        (enter your AWS Access Key, Secret Key, region)"
echo "2. Run: docker login         (enter your Docker Hub username/password)"
echo "3. Run: ./scripts/deploy.sh"
