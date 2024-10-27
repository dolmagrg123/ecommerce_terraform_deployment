pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        echo 'Building Backend and Frontend Applications...'
        sudo apt-get update
        sudo apt-get install -y software-properties-common

        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update
        sudo apt-get install -y python3.9 python3.9-venv python3.9-dev

        python3.9 -m venv venv
        source venv/bin/activate

        pip install -r requirements.txt

        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs

        sed -i 's|"proxy": "http://.*:8000"|"proxy": "http://<BACKEND_PRIVATE_IP>:8000"|' package.json

        npm install
       

        '''
     }
   }
    stage ('Test') {
      steps {
        sh '''#!/bin/bash
        source venv/bin/activate
        pip install pytest-django
        python backend/manage.py makemigrations
        python backend/manage.py migrate
        pytest backend/account/tests.py --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    }
   
     stage('Init') {
       steps {
          dir('Terraform') {
            sh 'terraform init' 
            }
        }
      } 
     
      stage('Plan') {
        steps {
          withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('Terraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"' 
                            }
          }
        }     
      }
      stage('Apply') {
        steps {
            dir('Terraform') {
                sh 'terraform apply -auto-approve plan.tfplan' 
                }
        }  
      }       
    }
  }
