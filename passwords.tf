/*----------------------------------------------------------------------*/
/* MSK Passwords                                                        */
/*----------------------------------------------------------------------*/
resource "random_password" "this" {
  for_each = local.scram_secrets

  length           = try(each.value.random_password.length, var.msk_defaults.random_password.length, 30)
  min_lower        = try(each.value.random_password.min_lower, var.msk_defaults.random_password.min_lower, 0)
  min_numeric      = try(each.value.random_password.min_numeric, var.msk_defaults.random_password.min_numeric, 0)
  min_special      = try(each.value.random_password.min_special, var.msk_defaults.random_password.min_special, 0)
  min_upper        = try(each.value.random_password.min_upper, var.msk_defaults.random_password.min_upper, 0)
  numeric          = try(each.value.random_password.use_numeric, var.msk_defaults.random_password.use_numeric, true)
  lower            = try(each.value.random_password.use_lower, var.msk_defaults.random_password.use_lower, true)
  upper            = try(each.value.random_password.upper, var.msk_defaults.random_password.upper, true)
  override_special = try(each.value.random_password.override_special, var.msk_defaults.random_password.override_special, null)
  special          = try(each.value.random_password.special, var.msk_defaults.random_password.special, false)

  keepers = {
    pass_version = try(each.value.random_password.pass_version, var.msk_defaults.random_password.pass_version, 1)
  }
}
