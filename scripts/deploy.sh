#!/bin/bash
set -e
cd "$1"
terraform plan -out=tfplan
terraform apply tfplan
