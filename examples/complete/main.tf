module "wrapper_msk" {
  source = "../../"

  metadata = local.metadata

  msk_parameters = {

    "Ex-Simple" = {

      # kafka_version          = "3.9.x"
      # number_of_broker_nodes = 3

      # ## AUTHENTICATION
      # client_authentication = {
      #   sasl = { scram = true }
      # }
      # create_scram_secret_association = true

      ## CONFIGURATION
      configuration_server_properties = {
        "auto.create.topics.enable" = true
        "delete.topic.enable"       = true
      }

      ## TOPICS
      topics = {
        "events" = {
          partition_count    = 3
          replication_factor = 3
        }
      }
    }

    "Ex-Cluster" = {

      # kafka_version          = "3.9.x"
      number_of_broker_nodes = 6

      broker_node_storage_info = {
        ebs_storage_info = { volume_size = 50 }
      }

      # subnet_name = "${local.common_name_prefix}-private*" # Default: "${local.common_name_prefix}-private*"
      # vpc_name = "${local.common_name_prefix}" # Default: common_name_prefix
      # broker_node_client_subnets = ["subnet-01xxxxxxxxxxxxx"] # Default: auto-discovered via subnet_name
      # security_group_name = "${local.common_name_prefix}-shared-msk" # Default: "${local.common_name}-msk-${each.key}"

      # ## AUTHENTICATION
      # client_authentication = {
      #   sasl = { scram = true }
      # }
      # create_scram_secret_association = true

      ## MONITORING
      enhanced_monitoring                    = "PER_TOPIC_PER_PARTITION"
      jmx_exporter_enabled                   = true
      node_exporter_enabled                  = true
      cloudwatch_logs_enabled                = true
      cloudwatch_log_group_retention_in_days = 30

      ## STORAGE
      scaling_max_capacity = 512

      ## CONFIGURATION
      configuration_server_properties = {
        "auto.create.topics.enable" = true
        "delete.topic.enable"       = true
      }

      ## TOPICS
      topics = {
        "orders" = {
          partition_count    = 12
          replication_factor = 3
        }
        "events" = {
          partition_count    = 6
          replication_factor = 3
        }
      }

      ## SCHEMA REGISTRY
      create_schema_registry = true
      schema_registries = {
        "main" = {
          name        = "${local.common_name}-schema-registry"
          description = "Schema registry for MSK cluster"
        }
      }
      schemas = {
        "order-event" = {
          schema_registry_name = "main"
          schema_name          = "order-event"
          compatibility        = "BACKWARD"
          schema_definition    = "{\"type\":\"record\",\"name\":\"OrderEvent\",\"fields\":[{\"name\":\"order_id\",\"type\":\"string\"}]}"
        }
      }
    }

  }

  msk_defaults = var.msk_defaults
}
