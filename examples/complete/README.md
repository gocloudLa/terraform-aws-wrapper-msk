# Complete Example 🚀

Common MSK use cases in a single msk_parameters map.

## 🔧 What's Included

### Analysis of Terraform Configuration

#### Main Purpose
Copy Ex-Simple or Ex-Cluster and adjust only what your environment needs.

#### Key Features Demonstrated
- **Ex-Simple**: Dev/staging — 3 brokers, SCRAM auth, one topic. Uses wrapper defaults for instance type, subnets, and security group.
- **Ex-Cluster**: Production-like — 6 brokers, SCRAM auth, monitoring, CloudWatch Logs, higher partition counts, and schema registry.

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