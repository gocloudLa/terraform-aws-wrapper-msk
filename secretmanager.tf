/*----------------------------------------------------------------------*/
/* MSK | Secrets Manager                                                */
/*----------------------------------------------------------------------*/
resource "aws_kms_key" "this" {
  for_each = {
    for k, v in var.msk_parameters : k => v
    if try(v.secret.kms_key_id, var.msk_defaults.secret.kms_key_id, null) == null
  }

  description             = try(each.value.secret.kms.description, var.msk_defaults.secret.kms.description, "KMS key for MSK SCRAM secret - ${local.common_name}-${each.key}")
  deletion_window_in_days = try(each.value.secret.kms.deletion_window_in_days, var.msk_defaults.secret.kms.deletion_window_in_days, 7)
  enable_key_rotation     = try(each.value.secret.kms.enable_key_rotation, var.msk_defaults.secret.kms.enable_key_rotation, true)
  multi_region            = try(each.value.secret.kms.multi_region, var.msk_defaults.secret.kms.multi_region, false)
  policy                  = try(each.value.secret.kms.policy, var.msk_defaults.secret.kms.policy, null)

  tags = merge(local.common_tags, try(each.value.tags, var.msk_defaults.tags, null))
}

resource "aws_kms_alias" "this" {
  for_each = aws_kms_key.this

  name          = "alias/${local.common_name}-msk-scram-${each.key}"
  target_key_id = each.value.key_id
}

resource "aws_secretsmanager_secret" "this" {
  for_each = var.msk_parameters

  name                    = try(each.value.secret.name, var.msk_defaults.secret.name, "AmazonMSK_${local.common_name}-${each.key}")
  description             = try(each.value.secret.description, var.msk_defaults.secret.description, "SCRAM credentials for MSK cluster ${each.key}")
  kms_key_id              = try(each.value.secret.kms_key_id, var.msk_defaults.secret.kms_key_id, aws_kms_key.this[each.key].arn)
  recovery_window_in_days = try(each.value.secret.recovery_window_in_days, var.msk_defaults.secret.recovery_window_in_days, 30)
  tags                    = merge(local.common_tags, try(each.value.tags, var.msk_defaults.tags, null))
}

resource "aws_secretsmanager_secret_version" "secret_val" {
  for_each = var.msk_parameters

  secret_id = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode({
    username = try(each.value.username, var.msk_defaults.username, "admin")
    password = try(each.value.password_wo, var.msk_defaults.password_wo, random_password.this[each.key].result)
  })
}

resource "aws_secretsmanager_secret_policy" "this" {
  for_each = aws_secretsmanager_secret.this

  secret_arn = each.value.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AWSKafkaResourcePolicy"
      Effect    = "Allow"
      Principal = { Service = "kafka.amazonaws.com" }
      Action    = "secretsmanager:GetSecretValue"
      Resource  = each.value.arn
    }]
  })
}
