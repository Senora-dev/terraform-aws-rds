provider "aws" {
  region = "us-west-2"
}

locals {
  name = "complete-postgres"
}

data "aws_availability_zones" "available" {
  state = "available"
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

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}

# Create private subnets for the RDS instance
resource "aws_subnet" "database" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${local.name}-subnet-${count.index + 1}"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "database" {
  name        = "${local.name}-sg"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
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

# Create a KMS key for encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for RDS database encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${local.name}-key"
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
  engine               = "postgres"
  engine_version       = "14.17"
  family              = "postgres14"
  major_engine_version = "14"
  instance_class      = "db.t3.small"

  # Storage
  allocated_storage     = 50
  max_allocated_storage = 100
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id          = aws_kms_key.database.arn

  # Credentials
  database_name = "completedb"
  username      = "postgresadmin"
  password      = "YourPwdShouldBeLongAndSecure!"
  port          = 5432

  # Network
  vpc_security_group_ids = [aws_security_group.database.id]
  subnet_ids            = aws_subnet.database[*].id
  multi_az             = true
  publicly_accessible  = false

  # DB Parameter group
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  # Option group
  create_option_group = false
  option_group_name   = "default:postgres-14"

  # Backup
  backup_retention_period = 14
  backup_window          = "03:00-04:00"
  copy_tags_to_snapshot  = true
  skip_final_snapshot    = true

  # Maintenance
  maintenance_window          = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = true

  # Monitoring
  monitoring_interval = 30
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id      = aws_kms_key.database.arn

  # Deletion protection
  deletion_protection = false

  # CloudWatch logs
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Timeouts
  timeouts = {
    create = "40m"
    update = "80m"
    delete = "40m"
  }

  tags = {
    Environment = "prod"
    Project     = "complete"
    Terraform   = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.rds_enhanced_monitoring
  ]
}