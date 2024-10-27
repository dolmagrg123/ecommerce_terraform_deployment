pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        echo "Building"

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
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key'), 
                        string(credentialsId: 'db_password', variable: 'db_password')]) {
                            dir('Terraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}" -var="db_password=${db_password}"' 
                            }
          }
        }     
      }

    stage('Apply') {
      steps {
        dir('Terraform') {
          script {
            sh 'terraform apply -auto-approve plan.tfplan'
            
            // Capture outputs and store them in environment variables
            env.BACKEND_PRIVATE_IP = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
            env.RDS_ENDPOINT = sh(script: 'terraform output -raw rds_endpoint', returnStdout: true).trim()
            env.RDS_DB_NAME = sh(script: 'terraform output -raw rds_db_name', returnStdout: true).trim()
            env.RDS_USERNAME = sh(script: 'terraform output -raw rds_username', returnStdout: true).trim()
            env.RDS_PASSWORD = sh(script: 'terraform output -raw rds_password', returnStdout: true).trim()
            
            echo "Backend Private IP: ${env.BACKEND_PRIVATE_IP}"
            echo "RDS Endpoint: ${env.RDS_ENDPOINT}"
          }
          
          // Update settings.py and package.json
          dir('backend') {
            sh """
              sed -i 's/ALLOWED_HOSTS = \\[\\]/ALLOWED_HOSTS = [\\"${env.BACKEND_PRIVATE_IP}\\"]/' my_project/settings.py
              sed -i 's|http://private_ec2_ip:8000|http://${env.BACKEND_PRIVATE_IP}:8000|' ../frontend/package.json
              sed -i '/DATABASES = {/,/sqlite3/s/^ *#//' my_project/settings.py
              sed -i 's/NAME': 'your_db_name'/NAME': '${env.RDS_DB_NAME}'/' my_project/settings.py
              sed -i 's/USER': 'your_username'/USER': '${env.RDS_USERNAME}'/' my_project/settings.py
              sed -i 's/PASSWORD': 'your_password'/PASSWORD': '${env.RDS_PASSWORD}'/' my_project/settings.py
              sed -i 's/HOST': 'your-rds-endpoint.amazonaws.com'/HOST': '${env.RDS_ENDPOINT}'/' my_project/settings.py
            """
          }
        }
      }  
    }
                }
        }  
      }
      stage('Database Load') {
        steps {
          dir('backend') {
            script {
              sh '''
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
              '''
            }
          }
        }
      }
      
    }
  }

