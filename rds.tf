variable "username_db" {
  type = string
}

variable "password_db" {
  type = string
}

# Configuração do Provider
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Database Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

# Security Group
resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "rds-sg"
  description = "Allow PostgreSQL access"

  ingress {
    description = "Allow PostgreSQL access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso de qualquer lugar (não recomendado em produção)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.username_db
  password               = var.password_db
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  identifier             = "challenge"
}


# Outputs (opcional, para exibir informações)
output "rds_endpoint" {
  value = aws_db_instance.fiap_techchallenge_db.endpoint
}

output "rds_username" {
  value = aws_db_instance.fiap_techchallenge_db.username
}

