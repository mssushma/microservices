output "instance_public_ip" {

  value = aws_instance.microservices.public_ip
}

output "instance_id" {

  value = aws_instance.microservices.id
}

output "user_ecr_uri" {
  value = aws_ecr_repository.user_repo.repository_url
}

output "product_ecr_uri" {
  value = aws_ecr_repository.product_repo.repository_url
}

output "order_ecr_uri" {
  value = aws_ecr_repository.order_repo.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.microservices.public_ip
}
