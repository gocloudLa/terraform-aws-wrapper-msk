module "security_group_msk" {
  for_each = var.msk_parameters

  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  name            = try(each.value.security_group_name, var.msk_defaults.security_group_name, "${local.common_name}-msk-${each.key}")
  vpc_id          = data.aws_vpc.this[each.key].id
  use_name_prefix = false

  ingress_with_cidr_blocks = try(each.value.ingress_with_cidr_blocks, var.msk_defaults.ingress_with_cidr_blocks, [
    { from_port = 9092, to_port = 9092, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "Kafka plaintext" },
    { from_port = 9094, to_port = 9094, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "Kafka TLS" },
    { from_port = 9096, to_port = 9096, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "Kafka SASL/SCRAM" },
    { from_port = 9098, to_port = 9098, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "Kafka SASL/IAM" },
    { from_port = 2181, to_port = 2181, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "ZooKeeper plaintext" },
    { from_port = 2182, to_port = 2182, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "ZooKeeper TLS" },
    { from_port = 11001, to_port = 11002, protocol = "tcp", cidr_blocks = data.aws_vpc.this[each.key].cidr_block, description = "Prometheus monitoring (JMX/Node exporter)" }
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
