# AWS RDS Terraform Module

This Terraform module creates RDS instances on AWS with support for multiple database engines, parameter groups, option groups, and enhanced monitoring.

## Features

- Support for multiple database engines (MySQL, PostgreSQL, Oracle, SQL Server)
- Multi-AZ deployment option
- Automated backups and maintenance windows
- Enhanced monitoring and Performance Insights
- Encryption at rest using KMS
- IAM database authentication
- Parameter groups and option groups management
- CloudWatch logs exports
- Subnet groups for VPC deployment
- Comprehensive tagging support

## Usage

### Basic MySQL RDS Instance

```hcl
module "mysql" {
  source = "Senora-dev/rds/aws"

  identifier = "my-mysql-db"
  engine     = "mysql"
  engine_version = "8.0.28"
  family     = "mysql8.0"
  major_engine_version = "8.0"

  instance_class    = "db.t3.medium"
  allocated_storage = 20

  username = "admin"
  password = "YourSecurePassword123"

  subnet_ids = ["subnet-1234567890", "subnet-0987654321"]
  vpc_security_group_ids = ["sg-1234567890"]

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Complete PostgreSQL RDS Instance with Enhanced Features

```hcl
module "postgresql" {
  source = "path/to/terraform-aws-rds"

  identifier = "my-postgresql-db"
  engine     = "postgres"
  engine_version = "14.3"
  family     = "postgres14"
  major_engine_version = "14"

  instance_class    = "db.r5.large"
  allocated_storage = 100
  storage_encrypted = true

  username = "admin"
  password = "YourSecurePassword123"
  port     = 5432

  multi_az = true
  subnet_ids = ["subnet-1234567890", "subnet-0987654321"]
  vpc_security_group_ids = ["sg-1234567890"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  backup_retention_period = 30

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

  options = [
    {
      option_name = "TIMEZONE"
      option_settings = [
        {
          name  = "TIME_ZONE"
          value = "UTC"
        }
      ]
    }
  ]

  performance_insights_enabled = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = "arn:aws:iam::123456789012:role/rds-monitoring-role"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  deletion_protection = true
  skip_final_snapshot = false

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | The name of the RDS instance | `string` | n/a | yes |
| engine | The database engine to use | `string` | n/a | yes |
| engine_version | The engine version to use | `string` | n/a | yes |
| family | The family of the DB parameter group | `string` | n/a | yes |
| major_engine_version | The major version of the engine | `string` | n/a | yes |
| instance_class | The instance type of the RDS instance | `string` | n/a | yes |
| allocated_storage | The allocated storage in gigabytes | `number` | n/a | yes |
| username | Username for the master DB user | `string` | n/a | yes |
| password | Password for the master DB user | `string` | n/a | yes |
| subnet_ids | A list of VPC subnet IDs | `list(string)` | `[]` | no |
| vpc_security_group_ids | List of VPC security groups to associate | `list(string)` | `[]` | no |
| multi_az | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| storage_encrypted | Specifies whether the DB instance is encrypted | `bool` | `true` | no |
| monitoring_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected | `number` | `0` | no |
| backup_retention_period | The days to retain backups for | `number` | `7` | no |
| deletion_protection | The database can't be deleted when this value is set to true | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The RDS instance ID |
| db_instance_arn | The ARN of the RDS instance |
| db_instance_endpoint | The connection endpoint |
| db_instance_name | The database name |
| db_instance_username | The master username for the database |
| db_instance_port | The database port |
| db_instance_availability_zone | The availability zone of the RDS instance |
| db_instance_hosted_zone_id | The canonical hosted zone ID of the DB instance |

## Authors

Module is maintained by [Your Name] with help from [contributors].

## License

Apache 2 Licensed. See LICENSE for full details.

## Maintainers

This module is maintained by [Senora.dev](https://senora.dev). 