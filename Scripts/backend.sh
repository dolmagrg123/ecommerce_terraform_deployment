#!/bin/bash
# Update and install required packages
sudo apt update
sudo apt install -y git software-properties-common

# Clone the repository
git clone https://github.com/dolmagrg123/ecommerce_terraform_deployment.git

# Set up Python 3.9 and virtual environment
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.9 python3.9-venv python3.9-dev

# Navigate to backend directory
cd ecommerce_terraform_deployment/backend

# Create and activate virtual environment, install dependencies
python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# pip install psycopg2-binary

sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\"${backend_ip}\"\]/" settings.py
# Start Django server
mkdir /home/ubuntu/logs && touch /home/ubuntu/logs/backend.log
python3 manage.py runserver 0.0.0.0:8000 > /home/ubuntu/logs/backend.log 2>&1 &
