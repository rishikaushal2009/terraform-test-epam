#!/bin/bash

# Update the package list
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Start the Docker service and enable it on boot
sudo systemctl start docker
sudo systemctl enable docker

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Clone the GitHub repository with the Helm chart
git clone https://github.com/codefresh-contrib/helm-sample-app.git

# Deploy the Helm chart
cd helm-sample-app
helm install sample-app ./charts/helm-example/Chart.yaml

# Clean up the cloned repository
rm -rf helm-sample-app
