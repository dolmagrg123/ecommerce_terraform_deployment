pipeline {
  agent any
    environment {
        BASTION_HOST = '34.207.103.19'
        PRIVATE_HOST = '10.0.3.144'
        SSH_KEY = credentials('my_ssh_key') // ID of the SSH key stored in Jenkins
        SSH_USER = 'ubuntu' // Replace with your instance's user, like ubuntu or ec2-user
    }

  stages {
    stage('Build') {
      steps {
        sh '''#!/bin/bash
        echo "Building"
        git clone https://github.com/dolmagrg123/ecommerce_terraform_deployment.git
        python3.9 -m venv venv
        source venv/bin/activate
        cd ./backend
        pip install -r requirements.txt

        '''
      }
    }
    
    stage('Test') {
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
                         string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                        //  , string(credentialsId: 'db_password', variable: 'db_password')
                         ]) {
          dir('Terraform') {
            sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"' 
            // -var="db_password=${db_password}"
          }
        }
      }     
    }
    
    stage('Apply') {
      steps {
        dir('Terraform') {
          script {
            // sh 'terraform destroy -auto-approve plan.tfplan'
            sh 'terraform apply -auto-approve plan.tfplan'
            
            // // Capture outputs and store them in environment variables
            // def privateIp = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
            // def dbHost = sh(script: 'terraform output -raw rds_endpoint', returnStdout: true).trim()
            // def dbName = sh(script: 'terraform output -raw rds_db_name', returnStdout: true).trim()
            // def dbUser = sh(script: 'terraform output -raw rds_username', returnStdout: true).trim()
            // def dbPassword = sh(script: 'terraform output -raw rds_password', returnStdout: true).trim()
            
            // echo "Backend Private IP: ${privateIp}"
            // echo "RDS Endpoint: ${dbHost}"
            
            // // Update settings.py and package.json
            // dir('backend') {
            //   sh """
            //     sed -i 's/ALLOWED_HOSTS = \\[\\]/ALLOWED_HOSTS = [\"${privateIp}\"]/' my_project/settings.py
            //     sed -i 's|http://private_ec2_ip:8000|http://${privateIp}:8000|' ../frontend/package.json
            //     sed -i '/DATABASES = {/,/sqlite3/s/^ *#//' my_project/settings.py
            //     sed -i \"s/'NAME': 'your_db_name'/'NAME': '${dbName}'/\" my_project/settings.py
            //     sed -i \"s/'USER': 'your_username'/'USER': '${dbUser}'/\" my_project/settings.py
            //     sed -i \"s/'PASSWORD': 'your_password'/'PASSWORD': '${dbPassword}'/\" my_project/settings.py
            //     sed -i \"s/'HOST': 'your-rds-endpoint.amazonaws.com'/'HOST': '${dbHost}'/\" my_project/settings.py
            //   """
            }
          }
        }
      }
    // }

    stage('Database Load') {
            steps {
                script {
                    // SSH command to reach the private EC2 through the bastion host
                    sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no -J ${SSH_USER}@${BASTION_HOST} ${SSH_USER}@${PRIVATE_HOST} << EOF
                    echo "Connected to private EC2!"
                    # Run your commands here, e.g., check a service or deploy files
                    # Activate virtual environment
                    source venv/bin/activate

                    # Step 1: Create tables in RDS
                    python manage.py makemigrations account
                    python manage.py makemigrations payments
                    python manage.py makemigrations product
                    python manage.py migrate

                    # Step 2: Migrate data from SQLite to RDS
                    python manage.py dumpdata --database=sqlite --natural-foreign --natural-primary -e contenttypes -e auth.Permission --indent 4 > datadump.json
                    python manage.py loaddata datadump.json   
                    hostname
                    exit
                    EOF
                    """
    
        }
      }
    }
  }
}
