

 output "frontend_sg_id"{
   value = aws_security_group.frontend_sg.id
 }

 output "backend_sg_id"{
   value = aws_security_group.backend_sg.id
 }

 output "ecommerce_frontend_az1_id"{
   value = aws_instance.ecommerce_frontend_az1.id
 }
 output "ecommerce_frontend_az2_id"{
   value = aws_instance.ecommerce_frontend_az2.id
 }
 