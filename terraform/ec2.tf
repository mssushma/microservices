# Fetch latest Ubuntu 22.04 LTS AMI

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role

resource "aws_iam_role" "ec2_role" {

  name = "microservices-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# ECR Read Policy

resource "aws_iam_role_policy_attachment" "ecr_readonly" {

  role       = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance Profile

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "microservices-ec2-profile"

  role = aws_iam_role.ec2_role.name
}

# EC2 Instance

resource "aws_instance" "microservices" {

  ami                    = data.aws_ami.ubuntu.id

  instance_type          = var.instance_type

  key_name               = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.microservices_sg.id
  ]

  user_data = file("${path.module}/userdata.sh")

  root_block_device {

    volume_size = 20

    volume_type = "gp3"
  }

  tags = {
    Name = "microservices-k8s"
  }
}
