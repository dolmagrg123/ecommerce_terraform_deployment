#!/bin/bash
# Frontend EC2 setup script for React application

# Update package lists
sudo apt update -y

# Install dependencies
sudo apt install -y git curl
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Clone the repository
cd /home/ubuntu
git clone https://github.com/dolmagrg123/ecommerce_terraform_deployment.git

# Navigate to the frontend folder and install npm packages
cd ecommerce_terraform_deployment/frontend

# Install frontend dependencies
npm install

npm i

# sed -i 's/http:\/\/localhost:8000/http:\/\/<backend_ip>:8000/' package.json

# Set Node.js options for legacy provider and start the app
export NODE_OPTIONS=--openssl-legacy-provider
nohup npm start &