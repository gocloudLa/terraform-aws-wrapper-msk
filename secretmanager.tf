locals {
  scram_secrets = {
    for k, v in var.msk_parameters : k => v
    if try(v.create_scram_secret_association, var.msk_defaults.create_scram_secret_association, false) && length(try(v.scram_secret_association_secret_arn_list, var.msk_defaults.scram_secret_association_secret_arn_list, [])) == 0
  }
}

resource "aws_kms_key" "scram" {
  for_each = {
    for k, v in local.scram_secrets : k => v
    if try(v.scram_secret_kms_key_id, var.msk_defaults.scram_secret_kms_key_id, null) == null
  }

  description = "KMS key for MSK SCRAM secret - ${local.common_name}-${each.key}"
  tags        = merge(local.common_tags, try(each.value.tags, var.msk_defaults.tags, null))
}

resource "aws_kms_alias" "scram" {
  for_each = aws_kms_key.scram

  name          = "alias/${local.common_name}-msk-scram-${each.key}"
  target_key_id = each.value.key_id
}

resource "aws_secretsmanager_secret" "scram" {
  for_each = local.scram_secrets

  name                    = try(each.value.scram_secret_name, "AmazonMSK_${local.common_name}-${each.key}")
  description             = try(each.value.scram_secret_description, var.msk_defaults.scram_secret_description, "SCRAM credentials for MSK cluster ${each.key}")
  kms_key_id              = try(each.value.scram_secret_kms_key_id, var.msk_defaults.scram_secret_kms_key_id, aws_kms_key.scram[each.key].arn)
  recovery_window_in_days = try(each.value.scram_secret_recovery_window_in_days, var.msk_defaults.scram_secret_recovery_window_in_days, 30)

  tags = merge(local.common_tags, try(each.value.tags, var.msk_defaults.tags, null))
}

resource "aws_secretsmanager_secret_version" "scram" {
  for_each = aws_secretsmanager_secret.scram

  secret_id = each.value.id
  secret_string_wo = jsonencode({
    username = try(var.msk_parameters[each.key].scram_username, "kafka-${each.key}")
    password = random_password.this[each.key].result
  })
  secret_string_wo_version = try(var.msk_parameters[each.key].scram_secret_version, var.msk_defaults.scram_secret_version, 1)
}
