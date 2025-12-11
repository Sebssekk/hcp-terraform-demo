# HCP Terraform Exploration - Demo Project

## Overview

This repository contains example Terraform configuration files for demonstration purposes as part of an **HCP Terraform exploration** project.

## Purpose

This project demonstrates how to use Terraform to provision and manage AWS infrastructure, including:
- Virtual Private Cloud (VPC) with public subnets
- Internet Gateway for public internet access
- EC2 instances with SSH access
- Security groups for inbound/outbound traffic management
- Key pair management for SSH authentication

## Project Structure

- **`provider.tf`** - Terraform provider configuration for AWS
- **`variables.tf`** - Input variables for configurable infrastructure parameters
- **`network.tf`** - VPC, subnets, internet gateway, and routing configuration
- **`compute.tf`** - EC2 instance, security groups, and SSH key pair setup
- **`output.tf`** - Output values (e.g., instance public IP)
- **`terraform.tfvars`** - Local variable values (not committed to version control)

![infrastructure Draw](./infrastructure-schema.png)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- An AWS account with appropriate permissions

## Usage

1. Clone or download this repository
2. Update `terraform.tfvars` with your desired configuration:
   ```hcl
   prefix_name         = "your-prefix"
   public_key_material = file("~/.ssh/id_rsa.pub")
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan your infrastructure:
   ```bash
   terraform plan 
   ```
5. Apply the configuration:
   ```bash
   terraform apply 
   ```

## Notes

- This is a **demo project** for learning purposes only
- Ensure sensitive data (SSH keys, credentials) are never committed to version control (see `.gitignore`)

## Cleanup

To destroy all provisioned resources:
```bash
terraform destroy 
```

### Course by [Klabs](https://www.klabs.it)