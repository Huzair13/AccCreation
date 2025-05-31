#!/bin/bash

# Set the AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Set the root OU ID
ROOT_OU_ID=$(aws organizations list-roots --query 'Roots[0].Id' --output text)

# Function to get OU ID
get_ou_id() {
    local ou_name=$1
    aws organizations list-organizational-units-for-parent --parent-id $ROOT_OU_ID --query "OrganizationalUnits[?Name=='$ou_name'].Id" --output text
}

# Import OUs
import_ou() {
    local ou_name=$1
    local ou_id=$(get_ou_id $ou_name)
    if [ -n "$ou_id" ]; then
        echo "Importing $ou_name OU..."
        terraform import "module.org.aws_organizations_organizational_unit.ou[\"$ou_name\"]" $ou_id
    else
        echo "Error: Could not find OU with name $ou_name"
    fi
}

# Run terraform init
terraform init

# Import each OU
import_ou "Security"
import_ou "SharedServices"
import_ou "Sandbox"
import_ou "TestAccount"
import_ou "Production"
import_ou "Dev"

echo "OU import completed."
