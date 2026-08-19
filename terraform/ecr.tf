resource "aws_ecr_repository" "user_repo" {
  name = "user-service-repo"
}

resource "aws_ecr_repository" "product_repo" {
  name = "product-service-repo"
}

resource "aws_ecr_repository" "order_repo" {
  name = "order-service-repo"
}
