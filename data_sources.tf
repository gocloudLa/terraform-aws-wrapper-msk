data "aws_vpc" "this" {
  for_each = var.msk_parameters
  filter {
    name = "tag:Name"
    values = [
      try(each.value.vpc_name, var.msk_defaults.vpc_name, local.default_vpc_name)
    ]
  }
}

data "aws_subnets" "this" {
  for_each = var.msk_parameters
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this[each.key].id]
  }

  tags = {
    Name = try(each.value.subnet_name, var.msk_defaults.subnet_name, local.default_subnet_name)
  }
}