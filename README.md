# AWS Assignment

This repository contains Terraform-based AWS infrastructure examples and exercises for creating and managing AWS resources such as VPCs, subnets, route tables, internet gateways, NAT gateways, and EC2 instances.

The project demonstrates multiple Terraform patterns, including:

- Terraform modules
- Terraform workspaces
- Multi-environment configuration
- Infrastructure setup without workspaces
- Practice examples for learning AWS resource provisioning

## Repository structure

```text
aws-assignment/
├── practice-module/
│   └── ec2/
│       ├── dev/
│       └── ec2-module/
├── practice-workspace/
│   ├── ec2/
│   └── vpc/
├── setup-with-modules/
│   ├── dev/
│   └── modules/
├── setup-without-workspace/
│   ├── dev/
│   └── prod/
├── .gitignore
├── Readme.md
└── README.md
```

## What is covered

### 1. Practice workspace examples
- A VPC configured with public/private subnets across multiple availability zones
- EC2 instance creation using Terraform
- Workspace-based environment handling (`dev`, `qa`, `uat`, `prod`)

### 2. Module-based setup
- Reusable Terraform modules for VPC and EC2 resources
- Environment-specific configuration using module calls

### 3. Setup without workspaces
- Independent environment folders such as `dev` and `prod`
- Standalone Terraform resource definitions for VPC and EC2 resources

## Prerequisites

Before running the Terraform code, make sure you have:

- AWS account with valid credentials
- AWS CLI installed and configured
- Terraform installed (recommended version 1.x)
- Appropriate IAM permissions to create VPC, subnet, EC2, and networking resources

## AWS configuration

The Terraform code uses the AWS provider with the `ap-south-1` region, for example:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

## Typical Terraform workflow

From any Terraform project directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

To destroy infrastructure:

```bash
tterraform destroy
```

## Workspace example

For workspace-based deployments:

```bash
terraform workspace new dev
terraform workspace select dev
terraform plan
terraform apply
```

## Example resources deployed

The infrastructure in this repository includes:

- Amazon VPC
- Public and private subnets
- Internet gateway
- Route tables and associations
- NAT gateway
- EC2 instance
- Terraform outputs such as public IP

## Notes

- This repository is intended for learning and practice with AWS + Terraform.
- Always review the Terraform plan before applying to AWS.
- Use separate AWS accounts or isolated credentials for experimentation where possible.
- Ensure you understand the cost implications before provisioning EC2 and networking resources.

## License

This project is intended for educational and practice purposes.

## Author

Rashmi Sharma
