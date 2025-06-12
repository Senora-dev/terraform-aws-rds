# Complete RDS Instance Example

This example demonstrates the advanced usage of the RDS module to create a production-ready PostgreSQL database instance with enhanced features.

## Features Demonstrated

* Multi-AZ deployment for high availability
* Enhanced monitoring with CloudWatch
* Performance Insights enabled
* KMS encryption for data at rest
* Custom parameter group settings
* Automated backups with extended retention
* CloudWatch Logs export
* VPC networking with private subnets
* Security group configuration
* IAM role for monitoring

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Resources Created

This example will create:

* A VPC with DNS support
* Three private subnets across different availability zones
* A security group for the RDS instance
* A KMS key for encryption
* An IAM role for enhanced monitoring
* A Multi-AZ PostgreSQL RDS instance with:
  * GP3 storage with encryption
  * Performance Insights enabled
  * Enhanced monitoring
  * Automated backups with 14-day retention
  * Custom parameter group settings
  * CloudWatch Logs export

## Security Features

* Database encryption using KMS
* Network isolation using private subnets
* Security group with minimal required access
* Enhanced monitoring for better visibility
* Deletion protection enabled
* Automated backups enabled
* CloudWatch Logs integration

## Inputs

No inputs are required for this example. All values are pre-configured in the main.tf file.

## Outputs

| Name | Description |
|------|-------------|
| db_instance_address | The address of the RDS instance |
| db_instance_endpoint | The connection endpoint |
| db_instance_name | The database name |
| db_instance_username | The master username for the database |
| db_instance_port | The database port |
| db_subnet_group_id | The db subnet group name |
| db_parameter_group_id | The db parameter group id |
| db_instance_status | The RDS instance status |
| db_instance_multi_az | If the RDS instance is multi AZ enabled |
| db_instance_availability_zone | The availability zone of the RDS instance |
| db_instance_cloudwatch_log_groups | The CloudWatch log groups for the RDS instance |
| enhanced_monitoring_iam_role_name | The name of the monitoring role |
| enhanced_monitoring_iam_role_arn | The ARN of the monitoring role |
| db_kms_key_id | The ARN of the KMS key used for encryption |
| db_instance_performance_insights_enabled | Whether Performance Insights is enabled |

## Notes

1. The password in this example is for demonstration only. In a production environment, you should use a more secure way to manage database passwords, such as AWS Secrets Manager.
2. The example enables deletion protection. You'll need to disable it before you can destroy the database.
3. The example uses GP3 storage which provides better performance than GP2.
4. Multi-AZ deployment increases costs but provides better availability.
5. Enhanced monitoring and Performance Insights will incur additional costs. 