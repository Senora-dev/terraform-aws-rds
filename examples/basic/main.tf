provider "aws" {
  region = "us-west-2"
}

locals {
  name = "basic-mysql"
}

# Create a VPC for the RDS instance
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name}-vpc"
  }
}

# Create subnets for the RDS instance
resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = "us-west-2${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "${local.name}-subnet-${count.index + 1}"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "database" {
  name        = "${local.name}-sg"
  description = "Security group for RDS MySQL instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg"
  }
}

# Create an IAM role for enhanced monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${local.name}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Create the RDS instance
module "db" {
  source = "../../"

  identifier = local.name

  # Database engine
  engine               = "mysql"
  engine_version       = "8.0"
  family              = "mysql8.0"
  major_engine_version = "8.0"
  instance_class      = "db.t3.micro"

  # Storage
  allocated_storage = 20
  storage_type      = "gp2"

  # Credentials
  database_name = "mydb"
  username      = "admin"
  password      = "YourPwdShouldBeLongAndSecure!"

  # Network
  vpc_security_group_ids = [aws_security_group.database.id]
  subnet_ids            = aws_subnet.database[*].id
  multi_az             = false
  publicly_accessible  = false

  # Backups and maintenance
  backup_retention_period = 7
  skip_final_snapshot    = true
  deletion_protection    = false

  # Enhanced monitoring
  performance_insights_enabled = false
  monitoring_interval         = 60
  monitoring_role_arn        = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
} 