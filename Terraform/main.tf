
# Configure the AWS provider block. This tells Terraform which cloud provider to use and 
# how to authenticate (access key, secret key, and region) when provisioning resources.
# Note: Hardcoding credentials is not recommended for production use. Instead, use environment variables
# or IAM roles to manage credentials securely.

# - 1x Custom VPC named "wl5vpc" in us-east-1 :done
# - 2x Availability zones in us-east-1a and us-east-1b :done
# - A private and public subnet in EACH AZ :done
# - An EC2 in each subnet (EC2s in the public subnets are for the frontend, the EC2s in the private subnets are for the backend) 
# Name the EC2's: "ecommerce_frontend_az1", "ecommerce_backend_az1", "ecommerce_frontend_az2", "ecommerce_backend_az2"
# - A load balancer that will direct the inbound traffic to either of the public subnets.
# - An RDS databse (See next step for more details)


provider "aws" {
  access_key = var.access_key       # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  secret_key = var.secret_key       # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region     = var.region           # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

module "VPC" {
  source = "./VPC"
}

module "EC2"{
  source = "./EC2"
  vpc_id = module.VPC.vpc_id
  private_subnet_1a_id = module.VPC.private_subnet_1a_id
  private_subnet_1b_id = module.VPC.private_subnet_1b_id
  public_subnet_1a_id  = module.VPC.public_subnet_1a_id
  public_subnet_1b_id  = module.VPC.public_subnet_1b_id
 
}

module "LB" {
  source = "./LB"
  vpc_id = module.VPC.vpc_id
  public_subnet_1a_id = module.VPC.public_subnet_1a_id
  public_subnet_1b_id = module.VPC.public_subnet_1b_id
  frontend_sg_id = module.EC2.frontend_sg_id
  ecommerce_frontend_az1_id = module.EC2.ecommerce_frontend_az1_id
  ecommerce_frontend_az2_id = module.EC2.ecommerce_frontend_az2_id
}

module "RDS"{
  source = "./RDS"
}



