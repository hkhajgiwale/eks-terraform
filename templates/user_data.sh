#!/bin/bash
# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y zip curl

#Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Download and install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

# Wait for the EKS cluster to be active
while [ "$(aws eks describe-cluster --name eks-cluster --query 'cluster.status' --output text)" != "ACTIVE" ]; do
  echo "Waiting for cluster to become active..."
  sleep 30
done

echo "Cluster is in ACTIVE State now"
