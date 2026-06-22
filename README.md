# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform MSK Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-msk/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-msk.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-msk.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-msk/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for MSK simplifies the provisioning of Amazon Managed Streaming for Apache Kafka clusters, including broker configuration, encryption, authentication, monitoring, logging, storage autoscaling, topic management, schema registry integration, and SecurityGroup association. When SCRAM authentication is enabled without external secrets, the wrapper auto-creates an ephemeral Secrets Manager credential that never persists in Terraform state.


### ✨ Features

- 🔐 [Authentication](#authentication) - Support for IAM, SCRAM, TLS, and unauthenticated client access

- 📊 [Monitoring & Logging](#monitoring-&-logging) - CloudWatch logs, S3 logs, Firehose delivery, JMX and Node exporters for Prometheus

- 📈 [Storage Autoscaling](#storage-autoscaling) - Automatic EBS volume scaling based on broker storage utilization

- ⚙️ [Configuration Management](#configuration-management) - Custom server.properties for Kafka broker configuration

- 🛡️ [Security Group](#security-group) - Automatic security group creation with configurable ingress rules

- 📋 [Topic Management](#topic-management) - Native MSK topic creation and management via aws_msk_topic

- 📝 [Schema Registry](#schema-registry) - AWS Glue Schema Registry integration for Avro schemas



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster" target="_blank">terraform-aws-modules/msk-kafka-cluster/aws</a> | 3.3.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.0 |



## 🚀 Quick Start
```hcl
msk_parameters = {
  "main" = {
    name                   = "my-msk-cluster"
    kafka_version          = "3.9.x"
    number_of_broker_nodes = 3

    broker_node_client_subnets = data.aws_subnets.private.ids
    broker_node_instance_type  = "kafka.m7g.large"
    broker_node_storage_info = {
      ebs_storage_info = { volume_size = 50 }
    }

    # Encryption (defaults to TLS)
    # encryption_in_transit_client_broker = "TLS"
    # encryption_in_transit_in_cluster    = true

    # SCRAM Authentication
    client_authentication = {
      sasl = { scram = true }
    }
    create_scram_secret_association = true

    # Monitoring
    enhanced_monitoring   = "PER_TOPIC_PER_PARTITION"
    jmx_exporter_enabled  = true
    node_exporter_enabled = true

    # Storage Autoscaling
    scaling_max_capacity = 512
    scaling_target_value = 80

    # Configuration
    configuration_server_properties = {
      "auto.create.topics.enable" = true
      "delete.topic.enable"       = true
    }
  }
}
```


## 🔧 Additional Features Usage

### Authentication
Configure client authentication for the MSK cluster using one or more methods. IAM authentication integrates with AWS IAM policies, SCRAM uses Secrets Manager for username/password credentials, and TLS uses ACM Private CA certificates. When SCRAM is enabled with `create_scram_secret_association = true` and no external secret ARN list is provided, the wrapper auto-creates an `AmazonMSK_` prefixed secret using an ephemeral `random_password` so the credential value never appears in Terraform state.


<details><summary>SCRAM Authentication (auto-created secret)</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    client_authentication = {
      sasl = { scram = true }
    }

    create_scram_secret_association = true
    # No scram_secret_association_secret_arn_list — secret is auto-created
  }
}
```


</details>

<details><summary>SCRAM Authentication (external secrets)</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    client_authentication = {
      sasl = { scram = true }
    }

    create_scram_secret_association = true
    scram_secret_association_secret_arn_list = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:AmazonMSK_credentials"
    ]
  }
}
```


</details>

<details><summary>IAM Authentication</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    client_authentication = {
      sasl = { iam = true }
    }
  }
}
```


</details>


### Monitoring & Logging
Configure enhanced MSK CloudWatch monitoring at various granularity levels (DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, PER_TOPIC_PER_PARTITION), enable Prometheus-compatible JMX and Node exporters, and deliver broker logs to CloudWatch Logs, S3, or Kinesis Data Firehose.


<details><summary>Prometheus Monitoring with S3 Logging</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    enhanced_monitoring   = "PER_TOPIC_PER_PARTITION"
    jmx_exporter_enabled  = true
    node_exporter_enabled = true

    s3_logs_enabled = true
    s3_logs_bucket  = "my-msk-logs-bucket"
    s3_logs_prefix  = "msk/logs"
  }
}
```


</details>

<details><summary>CloudWatch Logging</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    cloudwatch_logs_enabled                = true
    cloudwatch_log_group_retention_in_days = 30
  }
}
```


</details>


### Storage Autoscaling
Automatically scale EBS storage volumes attached to MSK broker nodes when utilization exceeds the configured threshold. Uses AWS Application Auto Scaling with a target tracking policy on `KafkaBrokerStorageUtilization`. Storage autoscaling is enabled by default. Once storage is scaled up, it cannot be scaled back down.


<details><summary>Storage Autoscaling Configuration</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    broker_node_storage_info = {
      ebs_storage_info = { volume_size = 100 }
    }

    # enable_storage_autoscaling = true  # Default: true
    scaling_max_capacity = 1000
    scaling_target_value = 70
  }
}
```


</details>


### Configuration Management
Customize Kafka broker behavior using `configuration_server_properties`. The wrapper creates an `aws_msk_configuration` resource with a derived name (`${common_name}-${key}-configuration`) and description by default. A random suffix is appended by the upstream module to support `create_before_destroy` lifecycle.


<details><summary>Custom Kafka Configuration</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    configuration_server_properties = {
      "auto.create.topics.enable"  = "false"
      "default.replication.factor" = "3"
      "min.insync.replicas"        = "2"
      "num.partitions"             = "6"
      "log.retention.hours"        = "168"
    }
  }
}
```


</details>


### Security Group
The wrapper automatically creates a security group per cluster. By default it opens Kafka broker ports (9092-9098) and ZooKeeper (2181) from the VPC CIDR. Override with `ingress_with_cidr_blocks` for fine-grained port control or set `security_group_create = false` to bring your own.


<details><summary>Custom Ingress Rules</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    ingress_with_cidr_blocks = [
      {
        from_port   = 9096
        to_port     = 9096
        protocol    = "tcp"
        description = "Kafka SASL/SCRAM"
        cidr_blocks = "10.0.0.0/8"
      },
      {
        from_port   = 2181
        to_port     = 2182
        protocol    = "tcp"
        description = "ZooKeeper"
        cidr_blocks = "10.0.0.0/8"
      },
      {
        from_port   = 11001
        to_port     = 11002
        protocol    = "tcp"
        description = "Prometheus exporters"
        cidr_blocks = "10.0.0.0/8"
      }
    ]
  }
}
```


</details>


### Topic Management
Create and manage Kafka topics natively using the `aws_msk_topic` resource (available since module v3.3.0). Define partition count and replication factor per topic. Topic names default to the map key if not explicitly set.


<details><summary>Topic Management</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    topics = {
      "orders" = {
        partition_count    = 6
        replication_factor = 3
      }
      "events" = {
        partition_count    = 12
        replication_factor = 3
      }
    }
  }
}
```


</details>


### Schema Registry
Integrate with AWS Glue Schema Registry to manage Avro schemas associated with the MSK cluster. Define registries and schemas with compatibility modes for schema evolution. Schema registry creation is enabled by default.


<details><summary>Schema Registry Configuration</summary>

```hcl
msk_parameters = {
  "main" = {
    broker_node_client_subnets = data.aws_subnets.private.ids

    schema_registries = {
      "my-registry" = {
        name        = "my-msk-schema-registry"
        description = "Schema registry for MSK cluster"
      }
    }
    schemas = {
      "order-schema" = {
        schema_registry_name = "my-registry"
        schema_name          = "order-event"
        compatibility        = "BACKWARD"
        schema_definition    = "{\"type\":\"record\",\"name\":\"OrderEvent\",\"fields\":[{\"name\":\"order_id\",\"type\":\"string\"}]}"
      }
    }
  }
}
```


</details>




## 📑 Inputs
| Name                                          | Description                                                       | Type           | Default                                     | Required |
| --------------------------------------------- | ----------------------------------------------------------------- | -------------- | ------------------------------------------- | -------- |
| name                                          | Name of the MSK cluster.                                          | `string`       | `"${local.common_name}-${each.key}"`        | no       |
| create                                        | Determines whether cluster resources will be created.             | `bool`         | `true`                                      | no       |
| kafka_version                                 | Desired Kafka software version.                                   | `string`       | `null`                                      | yes      |
| number_of_broker_nodes                        | Total number of broker nodes in the cluster.                      | `number`       | `null`                                      | yes      |
| broker_node_instance_type                     | Instance type for the Kafka brokers.                              | `string`       | `null`                                      | yes      |
| broker_node_client_subnets                    | List of subnets to connect to in client VPC.                      | `list(string)` | `[]`                                        | yes      |
| broker_node_az_distribution                   | Distribution of broker nodes across AZs.                          | `string`       | `null`                                      | no       |
| broker_node_storage_info                      | Storage volumes configuration for broker nodes.                   | `object`       | `null`                                      | no       |
| broker_node_connectivity_info                 | Cluster access configuration (public access, VPC connectivity).   | `object`       | `null`                                      | no       |
| client_authentication                         | Client authentication configuration (sasl, tls, unauthenticated). | `object`       | `null`                                      | no       |
| create_scram_secret_association               | Whether to create SASL/SCRAM secret association.                  | `bool`         | `false`                                     | no       |
| scram_secret_association_secret_arn_list      | List of Secrets Manager ARNs for SCRAM.                           | `list(string)` | `[]`                                        | no       |
| scram_secret_name                             | Override name for the auto-created SCRAM secret.                  | `string`       | `"AmazonMSK_${common_name}-${key}"`         | no       |
| scram_username                                | Username for the auto-created SCRAM credential.                   | `string`       | `"kafka-${key}"`                            | no       |
| scram_password                                | Explicit password for SCRAM (omit to auto-generate).              | `string`       | auto-generated                              | no       |
| scram_password_length                         | Length of the auto-generated SCRAM password.                      | `number`       | `32`                                        | no       |
| scram_secret_version                          | Increment to trigger SCRAM password rotation.                     | `number`       | `1`                                         | no       |
| scram_secret_kms_key_id                       | KMS key for encrypting the SCRAM secret.                          | `string`       | `null`                                      | no       |
| scram_secret_recovery_window_in_days          | Recovery window for the SCRAM secret.                             | `number`       | `30`                                        | no       |
| encryption_at_rest_kms_key_arn                | KMS key ARN for encrypting data at rest.                          | `string`       | `null`                                      | no       |
| encryption_in_transit_client_broker           | Encryption for data in transit between clients and brokers.       | `string`       | `"TLS"`                                     | no       |
| encryption_in_transit_in_cluster              | Whether data among broker nodes is encrypted.                     | `bool`         | `true`                                      | no       |
| enhanced_monitoring                           | CloudWatch monitoring level.                                      | `string`       | `"DEFAULT"`                                 | no       |
| storage_mode                                  | Storage mode for supported tiers (LOCAL or TIERED).               | `string`       | `"LOCAL"`                                   | no       |
| rebalancing                                   | Intelligent rebalancing configuration.                            | `object`       | `null`                                      | no       |
| timeouts                                      | Create, update, and delete timeout configurations.                | `object`       | `null`                                      | no       |
| create_configuration                          | Whether to create a Kafka configuration.                          | `bool`         | `true`                                      | no       |
| configuration_name                            | Name of the MSK configuration.                                    | `string`       | `"${common_name}-${key}-configuration"`     | no       |
| configuration_description                     | Description of the MSK configuration.                             | `string`       | `"${common_name}-${key} MSK Configuration"` | no       |
| configuration_server_properties               | Map of server.properties for Kafka brokers.                       | `map(string)`  | `{}`                                        | no       |
| configuration_arn                             | ARN of an externally created configuration.                       | `string`       | `null`                                      | no       |
| configuration_revision                        | Revision of the externally created configuration.                 | `number`       | `null`                                      | no       |
| cloudwatch_logs_enabled                       | Enable streaming broker logs to CloudWatch Logs.                  | `bool`         | `false`                                     | no       |
| create_cloudwatch_log_group                   | Whether to create a CloudWatch log group.                         | `bool`         | `true`                                      | no       |
| cloudwatch_log_group_name                     | Name of the CloudWatch Log Group.                                 | `string`       | `null`                                      | no       |
| cloudwatch_log_group_class                    | Log class of the log group (STANDARD or INFREQUENT_ACCESS).       | `string`       | `null`                                      | no       |
| cloudwatch_log_group_retention_in_days        | Log retention in days.                                            | `number`       | `0`                                         | no       |
| cloudwatch_log_group_kms_key_id               | KMS Key ARN for encrypting log data.                              | `string`       | `null`                                      | no       |
| firehose_logs_enabled                         | Enable streaming broker logs to Kinesis Data Firehose.            | `bool`         | `false`                                     | no       |
| firehose_delivery_stream                      | Name of the Firehose delivery stream.                             | `string`       | `null`                                      | no       |
| s3_logs_enabled                               | Enable streaming broker logs to S3.                               | `bool`         | `false`                                     | no       |
| s3_logs_bucket                                | Name of the S3 bucket for logs.                                   | `string`       | `null`                                      | no       |
| s3_logs_prefix                                | Prefix for the S3 log folder.                                     | `string`       | `null`                                      | no       |
| jmx_exporter_enabled                          | Enable JMX Exporter for Prometheus.                               | `bool`         | `false`                                     | no       |
| node_exporter_enabled                         | Enable Node Exporter for Prometheus.                              | `bool`         | `false`                                     | no       |
| enable_storage_autoscaling                    | Enable autoscaling for broker storage.                            | `bool`         | `true`                                      | no       |
| scaling_max_capacity                          | Max storage capacity for autoscaling (GiB).                       | `number`       | `250`                                       | no       |
| scaling_role_arn                              | IAM role ARN for Application AutoScaling.                         | `string`       | `null`                                      | no       |
| scaling_target_value                          | Storage utilization threshold for scaling (%).                    | `number`       | `70`                                        | no       |
| create_schema_registry                        | Whether to create a Glue schema registry.                         | `bool`         | `true`                                      | no       |
| schema_registries                             | Map of schema registries to create.                               | `map(object)`  | `{}`                                        | no       |
| schemas                                       | Map of schemas to create within the registry.                     | `map(object)`  | `{}`                                        | no       |
| topics                                        | Map of MSK topics to create.                                      | `map(object)`  | `{}`                                        | no       |
| create_cluster_policy                         | Whether to create an MSK cluster policy.                          | `bool`         | `false`                                     | no       |
| cluster_source_policy_documents               | Source policy documents for cluster policy.                       | `list(string)` | `null`                                      | no       |
| cluster_override_policy_documents             | Override policy documents for cluster policy.                     | `list(string)` | `null`                                      | no       |
| cluster_policy_statements                     | Map of policy statements for cluster policy.                      | `map(object)`  | `null`                                      | no       |
| vpc_connections                               | Map of VPC Connections to create.                                 | `map(object)`  | `{}`                                        | no       |
| connect_custom_plugins                        | Map of custom plugin configurations.                              | `map(object)`  | `{}`                                        | no       |
| create_connect_worker_configuration           | Whether to create connect worker configuration.                   | `bool`         | `false`                                     | no       |
| connect_worker_config_name                    | Name of the worker configuration.                                 | `string`       | `null`                                      | no       |
| connect_worker_config_description             | Description of the worker configuration.                          | `string`       | `null`                                      | no       |
| connect_worker_config_properties_file_content | Contents of connect-distributed.properties file.                  | `string`       | `null`                                      | no       |
| security_group_create                         | Whether to create the automatic security group.                   | `bool`         | `true`                                      | no       |
| ingress_with_cidr_blocks                      | Custom ingress rules for the security group.                      | `list(map)`    | Kafka + ZooKeeper from VPC CIDR             | no       |
| tags                                          | Additional tags merged into all resources.                        | `map(string)`  | `null`                                      | no       |







## ⚠️ Important Notes
- ⚠️ **Cluster creation time:** MSK cluster provisioning typically takes 15-30 minutes. Plan accordingly for CI/CD pipelines.
- ⚠️ **Broker count:** The `number_of_broker_nodes` must be a multiple of the number of subnets provided in `broker_node_client_subnets`.
- 🔒 **Encryption:** TLS encryption in transit is enabled by default (`encryption_in_transit_client_broker = "TLS"`). The AWS API default is `TLS_PLAINTEXT` but this wrapper enforces `TLS` for security.
- ℹ️ **Storage autoscaling:** Enabled by default. Once storage is scaled up, it cannot be scaled back down. The `scaling_max_capacity` sets the upper bound.
- ⚠️ **Configuration updates:** Changing `kafka_version` or `configuration_server_properties` triggers a rolling update of all brokers, which can take significant time.
- 🔒 **SCRAM secrets:** When auto-created, the password uses an ephemeral resource and `secret_string_wo` so credentials never appear in Terraform state. Bump `scram_secret_version` to rotate.
- ℹ️ **Terraform version:** Requires Terraform >= 1.10 for ephemeral resource support.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 