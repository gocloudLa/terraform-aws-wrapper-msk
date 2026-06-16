# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform MSK Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-msk/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-msk.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-msk.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-msk/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for MSK simplifies the creation of Amazon's Managed Streaming for Apache Kafka (MSK) service, creates clusters, configures logging, schema registries, and authentication.

### ✨ Features

- 📦 [Log Delivery Configuration](#log-delivery-configuration) - Configure CloudWatch, S3, or Kinesis Data Firehose logs for MSK

- 👥 [Authentication & Secrets](#authentication-&-secrets) - Manage SASL/SCRAM authentication and secret associations

- 🌐 [Schema Registries](#schema-registries) - Integration with AWS Glue Schema Registry



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster" target="_blank">terraform-aws-modules/msk-kafka-cluster/aws</a> | 3.3.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.0 |



## 🚀 Quick Start
```hcl
msk_parameters = {
  "Ex-Simple" = {
    name                   = "example-msk-cluster"
    kafka_version          = "4.1.x.kraft"
    number_of_broker_nodes = 3

    broker_node_client_subnets = data.aws_subnets.database.ids
    broker_node_instance_type  = "kafka.m5.large"
    
    broker_node_storage_info = {
      ebs_storage_info = { volume_size = 100 }
    }

    encryption_in_transit_client_broker = "TLS"
    encryption_in_transit_in_cluster    = true
  }
}
msk_defaults = var.msk_defaults
```


## 🔧 Additional Features Usage

### Log Delivery Configuration
Configure CloudWatch, S3, or Kinesis Data Firehose logs for MSK


<details><summary>Configuration Code</summary>

```hcl
cloudwatch_logs_enabled = false
s3_logs_enabled         = true
s3_logs_bucket          = "dmc-lab-msk-bucket"
s3_logs_prefix          = "s3-bucket-test"
```


</details>


### Authentication & Secrets
Manage SASL/SCRAM authentication and secret associations


<details><summary>Configuration Code</summary>

```hcl
client_authentication = {
  sasl = { scram = true }
}
create_scram_secret_association = false
scram_secret_association_secret_arn_list = [
  aws_secretsmanager_secret.example.arn,
]
```


</details>


### Schema Registries
Integration with AWS Glue Schema Registry for schema management


<details><summary>Configuration Code</summary>

```hcl
schema_registries = {
  team_a = {
    name        = "team_a"
    description = "Schema registry for Team A"
  }
}
schemas = {
  team_a_tweets = {
    schema_registry_name = "team_a"
    schema_name          = "tweets"
    description          = "Schema that contains all the tweets"
    compatibility        = "FORWARD"
    schema_definition    = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"} ]}"
  }
}
```


</details>




## 📑 Inputs
| Name                                          | Description                                                                                                                                                                                                                                | Type     | Default | Required |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- | -------- |
| Name                                          | Description                                                                                                                                                                                                                                | Type     | Default | Required |
| broker_node_az_distribution                   | The distribution of broker nodes across availability zones.                                                                                                                                                                                | `string` | `null`  | no       |
| broker_node_client_subnets                    | A list of subnets to connect to in client VPC.                                                                                                                                                                                             | `list`   | `[]`    | no       |
| broker_node_instance_type                     | Specify the instance type to use for the kafka brokers.                                                                                                                                                                                    | `string` | `null`  | no       |
| broker_node_security_groups                   | A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster.                                                                                                            | `list`   | `[]`    | no       |
| cloudwatch_log_group_class                    | Specifies the log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS.                                                                                                                                              | `string` | `null`  | no       |
| cloudwatch_log_group_kms_key_id               | The ARN of the KMS Key to use when encrypting log data.                                                                                                                                                                                    | `string` | `null`  | no       |
| cloudwatch_log_group_name                     | Name of the Cloudwatch Log Group to deliver logs to.                                                                                                                                                                                       | `string` | `null`  | no       |
| cloudwatch_log_group_retention_in_days        | Specifies the number of days you want to retain log events in the log group.                                                                                                                                                               | `number` | `0`     | no       |
| cloudwatch_logs_enabled                       | Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs.                                                                                                                                                  | `bool`   | `false` | no       |
| cluster_override_policy_documents             | Override policy documents for cluster policy.                                                                                                                                                                                              | `list`   | `null`  | no       |
| cluster_source_policy_documents               | Source policy documents for cluster policy.                                                                                                                                                                                                | `list`   | `null`  | no       |
| configuration_arn                             | ARN of an externally created configuration to use.                                                                                                                                                                                         | `string` | `null`  | no       |
| configuration_description                     | Description of the configuration.                                                                                                                                                                                                          | `string` | `null`  | no       |
| configuration_name                            | Name of the configuration.                                                                                                                                                                                                                 | `string` | `null`  | no       |
| configuration_revision                        | Revision of the externally created configuration to use.                                                                                                                                                                                   | `number` | `null`  | no       |
| configuration_server_properties               | Contents of the server.properties file.                                                                                                                                                                                                    | `map`    | `{}`    | no       |
| connect_worker_config_description             | A summary description of the worker configuration.                                                                                                                                                                                         | `string` | `null`  | no       |
| connect_worker_config_name                    | The name of the worker configuration.                                                                                                                                                                                                      | `string` | `null`  | no       |
| connect_worker_config_properties_file_content | Contents of connect-distributed.properties file. The value can be either base64 encoded or in raw format.                                                                                                                                  | `string` | `null`  | no       |
| create                                        | Determines whether cluster resources will be created.                                                                                                                                                                                      | `bool`   | `true`  | no       |
| create_cloudwatch_log_group                   | Determines whether to create a CloudWatch log group.                                                                                                                                                                                       | `bool`   | `false` | no       |
| create_cluster_policy                         | Determines whether to create an MSK cluster policy.                                                                                                                                                                                        | `bool`   | `false` | no       |
| create_configuration                          | Determines whether to create a configuration.                                                                                                                                                                                              | `bool`   | `true`  | no       |
| create_connect_worker_configuration           | Determines whether to create connect worker configuration.                                                                                                                                                                                 | `bool`   | `false` | no       |
| create_schema_registry                        | Determines whether to create a Glue schema registry for managing Avro schemas for the cluster.                                                                                                                                             | `bool`   | `false` | no       |
| create_scram_secret_association               | Determines whether to create SASL/SCRAM secret association.                                                                                                                                                                                | `bool`   | `false` | no       |
| enable_storage_autoscaling                    | Determines whether autoscaling is enabled for storage.                                                                                                                                                                                     | `bool`   | `false` | no       |
| encryption_at_rest_kms_key_arn                | You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest. | `string` | `null`  | no       |
| encryption_in_transit_client_broker           | Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`.                                                                                                                 | `string` | `null`  | no       |
| encryption_in_transit_in_cluster              | Whether data communication among broker nodes is encrypted.                                                                                                                                                                                | `bool`   | `null`  | no       |
| enhanced_monitoring                           | Specify the desired enhanced MSK CloudWatch monitoring level.                                                                                                                                                                              | `string` | `null`  | no       |
| firehose_delivery_stream                      | Name of the Kinesis Data Firehose delivery stream to deliver logs to.                                                                                                                                                                      | `string` | `null`  | no       |
| firehose_logs_enabled                         | Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose.                                                                                                                                            | `bool`   | `false` | no       |
| jmx_exporter_enabled                          | Indicates whether you want to enable or disable the JMX Exporter.                                                                                                                                                                          | `bool`   | `false` | no       |
| kafka_version                                 | Specify the desired Kafka software version.                                                                                                                                                                                                | `string` | `null`  | no       |
| name                                          | Name of the MSK cluster.                                                                                                                                                                                                                   | `string` | `null`  | no       |
| node_exporter_enabled                         | Indicates whether you want to enable or disable the Node Exporter.                                                                                                                                                                         | `bool`   | `false` | no       |
| number_of_broker_nodes                        | The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets.                                                                                                            | `number` | `null`  | no       |
| region                                        | Region where this resource will be managed. Defaults to the Region set in the provider configuration.                                                                                                                                      | `string` | `null`  | no       |
| s3_logs_bucket                                | Name of the S3 bucket to deliver logs to.                                                                                                                                                                                                  | `string` | `null`  | no       |
| s3_logs_enabled                               | Indicates whether you want to enable or disable streaming broker logs to S3.                                                                                                                                                               | `bool`   | `false` | no       |
| s3_logs_prefix                                | Prefix to append to the folder name.                                                                                                                                                                                                       | `string` | `null`  | no       |
| scaling_max_capacity                          | Max storage capacity for Kafka broker autoscaling.                                                                                                                                                                                         | `number` | `250`   | no       |
| scaling_role_arn                              | The ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf. This defaults to an IAM Service-Linked Role.                                                                                    | `string` | `null`  | no       |
| scaling_target_value                          | The Kafka broker storage utilization at which scaling is initiated.                                                                                                                                                                        | `number` | `70`    | no       |
| scram_secret_association_secret_arn_list      | List of AWS Secrets Manager secret ARNs to associate with SCRAM.                                                                                                                                                                           | `list`   | `[]`    | no       |
| storage_mode                                  | Controls storage mode for supported storage tiers. Valid values are: `LOCAL` or `TIERED`.                                                                                                                                                  | `string` | `null`  | no       |
| tags                                          | A map of tags to assign to the resources created.                                                                                                                                                                                          | `map`    | `{}`    | no       |








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