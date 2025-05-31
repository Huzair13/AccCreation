#!/bin/bash

# Initialize Terraform
terraform init -reconfigure -backend-config=backend.tfbackend

# Function to get OU ID
get_ou_id() {
    local ou_name=$1
    aws organizations list-organizational-units-for-parent --parent-id $(aws organizations list-roots --query 'Roots[0].Id' --output text) --query "OrganizationalUnits[?Name=='$ou_name'].Id" --output text
}

# Import OUs
import_ous() {
    local root_id=$(aws organizations list-roots --query 'Roots[0].Id' --output text)
    aws organizations list-organizational-units-for-parent --parent-id $root_id --query 'OrganizationalUnits[].[Name, Id]' --output text | while read -r ou_name ou_id; do
        echo "Importing $ou_name OU..."
        terraform import "module.org.aws_organizations_organizational_unit.ou[\"$ou_name\"]" $ou_id
    done
}

# Import all OUs
import_ous

echo "OU import completed."
