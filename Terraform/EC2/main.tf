# - An EC2 in each subnet (EC2s in the public subnets are for the frontend, the EC2s in the private subnets are for the backend) 
# Name the EC2's: "ecommerce_frontend_az1", "ecommerce_backend_az1", "ecommerce_frontend_az2", "ecommerce_backend_az2"


# Create an EC2 instance
resource "aws_instance" "ecommerce_frontend_az1" {
  ami               = "ami-0866a3c8686eaeeba" 
  instance_type     = var.instance_type  
  vpc_security_group_ids =[aws_security_group.frontend_sg.id]
  key_name          = "WL5" 
user_data = templatefile("${path.module}/../../Scripts/frontend_setup.sh", {
  backend_ip = aws_instance.ecommerce_backend_az1.private_ip
  })
  subnet_id = var.public_subnet_1a_id
  tags = {
    "Name" : "ecommerce_frontend_az1"
  }
}

resource "aws_instance" "ecommerce_frontend_az2" {
  ami               = "ami-0866a3c8686eaeeba" 
  instance_type     = var.instance_type  
  vpc_security_group_ids =[aws_security_group.frontend_sg.id]
  key_name          = "WL5" 
  user_data = templatefile("${path.module}/../../Scripts/frontend_setup.sh", {
  backend_ip = aws_instance.ecommerce_backend_az2.private_ip
  })
  subnet_id = var.public_subnet_1b_id
  tags = {
    "Name" : "ecommerce_frontend_az2"
  }
}

# EC2 in private Subnet
resource "aws_instance" "ecommerce_backend_az2" {
  ami               = "ami-0866a3c8686eaeeba" 
  instance_type     = var.instance_type     
  vpc_security_group_ids =[aws_security_group.backend_sg.id]
  key_name          = "WL5"
  user_data         = templatefile("${path.module}/../../Scripts/backend.sh")
  subnet_id = var.private_subnet_1b_id
  tags = {
    "Name" : "ecommerce_backend_az2"    
  }
}

# EC2 in private Subnet
resource "aws_instance" "ecommerce_backend_az1" {
  ami               = "ami-0866a3c8686eaeeba" 
  instance_type     = var.instance_type     
  vpc_security_group_ids =[aws_security_group.backend_sg.id]
  key_name          = "WL5"
  user_data         = templatefile("${path.module}/../../Scripts/backend.sh")
  subnet_id = var.private_subnet_1a_id
  tags = {
    "Name" : "ecommerce_backend_az1"    
  }
}

resource "aws_security_group" "frontend_sg" {#name that terraform recognizes
  name        = "tf_made_frontend_sg"
  vpc_id      = var.vpc_id
  description = "open ssh traffic"
  # Ingress rules: Define inbound traffic that is allowed.Allow SSH traffic and HTTP traffic on port 8080 from any IP address (use with caution)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress rules: Define outbound traffic that is allowed. The below configuration allows all outbound traffic from the instance.

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Tags for the security group
  tags = {
    "Name"      : "tf_frontend_sg"                          # Name tag for the security group
    "Terraform" : "true"                                # Custom tag to indicate this SG was created with Terraform
  }
}

resource "aws_security_group" "backend_sg" {#name that terraform recognizes
  name        = "tf_made_backend_sg"
  vpc_id      = var.vpc_id
  description = "open ssh traffic"
  # Ingress rules: Define inbound traffic that is allowed.Allow SSH traffic and HTTP traffic on port 8080 from any IP address (use with caution)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress rules: Define outbound traffic that is allowed. The below configuration allows all outbound traffic from the instance.

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Tags for the security group
  tags = {
    "Name"      : "tf_backend_sg"                          # Name tag for the security group
    "Terraform" : "true"                                # Custom tag to indicate this SG was created with Terraform
  }
}

