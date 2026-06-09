data "aws_vpc" "this" {
  for_each = var.msk_parameters
  filter {
    name = "tag:Name"
    values = [
      try(each.value.vpc_name, local.default_vpc_name)
    ]
  }
}
