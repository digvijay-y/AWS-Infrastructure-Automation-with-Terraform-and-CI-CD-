# AWS VPC Infrastructure using Terraform

This project uses Terraform to provision a simple AWS infrastructure consisting of a VPC, subnet, route table, security group, and an EC2 instance running Apache2 on Ubuntu. It also demonstrates use of remote state storage in an S3 bucket (with optional DynamoDB locking).

## 📦 Components Created

- **VPC** – A custom VPC with CIDR `10.0.0.0/16`
- **Internet Gateway** – To enable internet access
- **Route Table** – With routes for IPv4 and IPv6 internet traffic
- **Subnet** – Public subnet in `ap-south-1a`
- **Security Group** – Allowing inbound traffic on ports 22, 80, 443
- **Network Interface** – Bound to subnet and security group
- **Elastic IP** – Assigned to the network interface
- **EC2 Instance** – Ubuntu EC2 with Apache2 installed and web server running
- **S3 Backend** – Remote state management (optional, configurable)

## 🚀 Getting Started

### 1. Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- AWS CLI configured with appropriate permissions
- Existing AWS key pair (e.g., `main-key`)
- Optional: an S3 bucket and DynamoDB table for remote state

### 2. Environment Setup

**Recommended:** Export your AWS credentials as environment variables:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

```
### 3. Initialize Terraform
```bash
terraform init
```

### 4. Review Plan
```bash
terraform plan
```

### 5. Apply the Configuration
```bash
terraform apply
```

Type yes when prompted.
### 🧹 Clean Up

To destroy all resources:

terraform destroy

### 📄 Notes

    The terraform.tfstate file should be excluded from version control using .gitignore.

    Ensure your S3 bucket and DynamoDB table (if used) are already created for the remote backend.

    The EC2 instance will be accessible via the assigned Elastic IP on port 80 with a default web page.

### 📬 Outputs

    server_private_ip – The internal IP of the EC2 instance

    server_id – The EC2 instance ID

### 🤝 Author

Digvijay @ 2025
Project: DevOps + Terraform Hands-on


---
