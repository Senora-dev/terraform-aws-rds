# Basic RDS Instance Example

This example demonstrates the basic usage of the RDS module to create a MySQL database instance.

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
* Two private subnets in different availability zones
* A security group for the RDS instance
* An RDS instance running MySQL 8.0
* Associated parameter groups and subnet groups

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