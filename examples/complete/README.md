# Complete Example 🚀

This example demonstrates multiple MSK cluster configurations showcasing different security group strategies, authentication methods, and monitoring setups.

## 🔧 What's Included

### Analysis of Terraform Configuration

#### Main Purpose
Provision MSK clusters with three security group patterns: auto-created with custom rules, externally managed, and merged (auto-created + external).

#### Key Features Demonstrated
- **Auto-created SG with custom rules (Ex-Simple)**: Wrapper creates and manages the SG with per-port ingress rules for Kafka, ZooKeeper, and Prometheus.
- **Bring your own SG (Ex-BringYourOwnSG)**: Disables SG creation (`security_group_create = false`) and references pre-existing security groups.
- **Merged SGs (Ex-MergedSGs)**: Combines the auto-created SG (default rules) with additional external security groups via `broker_node_security_groups`.
- **SCRAM Authentication**: Auto-creates ephemeral Secrets Manager credentials (state-free) when no external secret ARN list is provided.
- **IAM Authentication**: Demonstrates SASL/IAM for clusters that integrate with AWS IAM policies.
- **Prometheus Monitoring**: JMX and Node exporters enabled with dedicated ingress rules for ports 11001-11002.
- **Storage Autoscaling**: Configures scaling up to 512 GiB at 80% utilization threshold.

## 🚀 Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## 🔒 Security Notes

⚠️ **Production Considerations**: 
- This example may include configurations that are not suitable for production environments
- Review and customize security settings, access controls, and resource configurations
- Ensure compliance with your organization's security policies
- Consider implementing proper monitoring, logging, and backup strategies

## 📖 Documentation

For detailed module documentation and additional examples, see the main [README.md](../../README.md) file. 