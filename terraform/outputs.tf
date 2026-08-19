output "instance_public_ip" {

  value = aws_instance.microservices.public_ip
}

output "instance_id" {

  value = aws_instance.microservices.id
}
