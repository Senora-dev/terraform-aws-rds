locals {
  is_multi_az = var.multi_az
  port        = coalesce(var.port, lookup(local.default_ports, var.engine, null))
  
  default_ports = {
    mysql        = 3306
    postgres     = 5432
    oracle-ee    = 1521
    oracle-se2   = 1521
    oracle-se1   = 1521
    oracle-se    = 1521
    sqlserver-ee = 1433
    sqlserver-se = 1433
    sqlserver-ex = 1433
    sqlserver-web = 1433
  }
}

resource "aws_db_subnet_group" "this" {
  count = var.create_subnet_group ? 1 : 0

  name        = coalesce(var.subnet_group_name, var.identifier)
  description = "Database subnet group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(
    {
      Name = coalesce(var.subnet_group_name, var.identifier)
    },
    var.tags
  )
}

resource "aws_db_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = coalesce(var.parameter_group_name, var.identifier)
  description = "Database parameter group for ${var.identifier}"
  family      = var.family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    {
      Name = coalesce(var.parameter_group_name, var.identifier)
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "this" {
  count = var.create_option_group ? 1 : 0

  name                     = coalesce(var.option_group_name, var.identifier)
  option_group_description = "Database option group for ${var.identifier}"
  engine_name             = var.engine
  major_engine_version    = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(
    {
      Name = coalesce(var.option_group_name, var.identifier)
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id       = var.kms_key_id

  db_name                              = var.database_name
  username                            = var.username
  password                            = var.password
  port                               = local.port
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.create_subnet_group ? aws_db_subnet_group.this[0].name : var.subnet_group_name

  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name
  option_group_name    = var.create_option_group ? aws_db_option_group.this[0].name : var.option_group_name

  multi_az               = local.is_multi_az
  publicly_accessible    = var.publicly_accessible
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = var.skip_final_snapshot
  copy_tags_to_snapshot  = var.copy_tags_to_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id      = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately          = var.apply_immediately

  tags = merge(
    {
      Name = var.identifier
    },
    var.tags
  )

  timeouts {
    create = lookup(var.timeouts, "create", "40m")
    delete = lookup(var.timeouts, "delete", "40m")
    update = lookup(var.timeouts, "update", "80m")
  }
} 