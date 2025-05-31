# AWS Landing Zone (Terraform Modular)

## Overview

This repo builds a multi-account AWS Landing Zone using pure Terraform modules (no AFT/LZA/CFCT).

- Modular OUs, account creation, VPC, IAM, SCPs, logging, shared services.
- Works for real orgs: extend with more modules for your enterprise!

## Quickstart

```sh
cd envs/global/org-setup
terraform init
terraform apply

cd ../../shared-services
terraform init
terraform apply
