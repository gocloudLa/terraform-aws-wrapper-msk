module "security_group_msk" {
  for_each = {
    for k, v in var.msk_parameters : k => v
    if try(v.security_group_create, var.msk_defaults.security_group_create, true)
  }

  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = try(each.value.security_group_name, var.msk_defaults.security_group_name, "${local.common_name}-msk-${each.key}")
  description     = try(each.value.security_group_description, var.msk_defaults.security_group_description, "Security Group for MSK cluster managed by Terraform")
  vpc_id          = data.aws_vpc.this[each.key].id
  use_name_prefix = false

  ingress_with_cidr_blocks = try(each.value.ingress_with_cidr_blocks, var.msk_defaults.ingress_with_cidr_blocks, [
    {
      from_port   = 9092
      to_port     = 9098
      protocol    = "tcp"
      description = "MSK Kafka brokers"
      cidr_blocks = data.aws_vpc.this[each.key].cidr_block
    },
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      description = "MSK ZooKeeper"
      cidr_blocks = data.aws_vpc.this[each.key].cidr_block
    }
  ])

  egress_with_cidr_blocks = try(each.value.egress_with_cidr_blocks, var.msk_defaults.egress_with_cidr_blocks, [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All outbound"
      cidr_blocks = "0.0.0.0/0"
    }
  ])

  tags = merge(local.common_tags, try(each.value.tags, var.msk_defaults.tags, null))
}

locals {
  msk_security_groups = {
    for k, v in var.msk_parameters : k => concat(
      try(v.security_group_create, var.msk_defaults.security_group_create, true) ? [module.security_group_msk[k].security_group_id] : [],
      try(v.broker_node_security_groups, var.msk_defaults.broker_node_security_groups, [])
    )
  }
}
