module "wrapper_msk" {
  source = "../../"

  metadata = local.metadata

  msk_parameters = {

    # Cluster with auto-created security group and custom ingress rules
    "Ex-Simple" = {
      name                   = "${local.common_name_prefix}-msk-cluster"
      kafka_version          = "3.9.x"
      number_of_broker_nodes = 3
      enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

      broker_node_client_subnets = data.aws_subnets.database.ids
      broker_node_instance_type  = "kafka.m7g.large"
      broker_node_storage_info = {
        ebs_storage_info = { volume_size = 50 }
      }

      # Encryption
      encryption_in_transit_client_broker = "TLS"
      encryption_in_transit_in_cluster    = true

      # Configuration
      configuration_server_properties = {
        "auto.create.topics.enable" = true
        "delete.topic.enable"       = true
      }

      # Monitoring
      jmx_exporter_enabled  = true
      node_exporter_enabled = true

      # Storage Autoscaling
      scaling_max_capacity = 512
      scaling_target_value = 80

      # SCRAM Authentication
      client_authentication = {
        sasl = { scram = true }
      }
      create_scram_secret_association = true

      # Security Group — auto-created with custom ingress rules
      # security_group_create = true  # Default: true
      ingress_with_cidr_blocks = [
        {
          from_port   = 9092
          to_port     = 9092
          protocol    = "tcp"
          description = "Kafka plaintext"
          cidr_blocks = data.aws_vpc.this.cidr_block
        },
        {
          from_port   = 9094
          to_port     = 9094
          protocol    = "tcp"
          description = "Kafka TLS"
          cidr_blocks = data.aws_vpc.this.cidr_block
        },
        {
          from_port   = 9096
          to_port     = 9096
          protocol    = "tcp"
          description = "Kafka SASL/SCRAM"
          cidr_blocks = data.aws_vpc.this.cidr_block
        },
        {
          from_port   = 9098
          to_port     = 9098
          protocol    = "tcp"
          description = "Kafka SASL/IAM"
          cidr_blocks = data.aws_vpc.this.cidr_block
        },
        {
          from_port   = 2181
          to_port     = 2181
          protocol    = "tcp"
          description = "ZooKeeper plaintext"
          cidr_blocks = data.aws_vpc.this.cidr_block
        },
        {
          from_port   = 2182
          to_port     = 2182
          protocol    = "tcp"
          description = "ZooKeeper TLS"
          cidr_blocks = data.aws_vpc.this.cidr_block
        },
        {
          from_port   = 11001
          to_port     = 11002
          protocol    = "tcp"
          description = "Prometheus monitoring (JMX/Node exporter)"
          cidr_blocks = data.aws_vpc.this.cidr_block
        }
      ]

      tags = {
        Terraform   = "true"
        Environment = "lab"
      }
    }

    # Cluster with externally managed security group (no auto-creation)
    "Ex-BringYourOwnSG" = {
      name                   = "${local.common_name_prefix}-msk-external-sg"
      kafka_version          = "3.9.x"
      number_of_broker_nodes = 3

      broker_node_client_subnets = data.aws_subnets.database.ids
      broker_node_instance_type  = "kafka.m7g.large"
      broker_node_storage_info = {
        ebs_storage_info = { volume_size = 50 }
      }

      # Authentication
      client_authentication = {
        sasl = { iam = true }
      }

      # Security Group — skip creation, use pre-existing SG(s)
      security_group_create       = false
      broker_node_security_groups = ["sg-01xxxxxxxxxxxxx"]

      tags = {
        Terraform   = "true"
        Environment = "lab"
      }
    }

    # Cluster with auto-created SG + additional external SGs merged
    "Ex-MergedSGs" = {
      name                   = "${local.common_name_prefix}-msk-merged-sg"
      kafka_version          = "3.9.x"
      number_of_broker_nodes = 3

      broker_node_client_subnets = data.aws_subnets.database.ids
      broker_node_instance_type  = "kafka.m7g.large"
      broker_node_storage_info = {
        ebs_storage_info = { volume_size = 50 }
      }

      # Authentication
      client_authentication = {
        sasl = { iam = true }
      }

      # Security Group — auto-created (default rules) + additional external SGs
      # security_group_create = true  # Default: true
      broker_node_security_groups = ["sg-01xxxxxxxxxxxxx", "sg-02xxxxxxxxxxxxx"]

      tags = {
        Terraform   = "true"
        Environment = "lab"
      }
    }

  }
}
