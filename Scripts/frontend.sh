#!/bin/bash
# Frontend EC2 setup script for React application

# Update package lists
sudo apt update -y

# Install dependencies
sudo apt install -y git curl
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Clone the repository
git clone https://github.com/dolmagrg123/ecommerce_terraform_deployment.git

# Navigate to the frontend folder and install npm packages
cd ecommerce_terraform_deployment/frontend

# Update proxy field in package.json (replace with actual backend private IP)
sed -i "s/\"proxy\": \"http:\/\/localhost:8000\"/\"proxy\": \"http:\/\/BACKEND_PRIVATE_IP:8000\"/g" package.json

# Install frontend dependencies
npm install

# Set Node.js options for legacy provider and start the app
export NODE_OPTIONS=--openssl-legacy-provider
nohup npm start &
