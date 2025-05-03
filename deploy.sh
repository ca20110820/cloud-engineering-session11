#!/bin/bash

set -eo pipefail

# Cleanup function for error handling
cleanup() {
  if [[ $? -ne 0 ]]; then
    echo -e "\nError detected! Destroying resources..."
    terraform destroy -auto-approve
    exit 1
  fi
}

trap cleanup EXIT

# Deployment Workflow
echo "Checking Terraform installation..."
command -v terraform >/dev/null || { echo "Terraform not found"; exit 1; }

echo "Initializing Terraform..."
terraform init

echo "Validating configuration..."
terraform validate

echo "Generating execution plan..."
terraform plan -out=tfplan -input=false

echo "Applying changes..."
terraform apply -auto-approve tfplan

# Success Cleanup
echo "Final cleanup..."
rm -f tfplan
echo "Deployment complete! Firewall IP: $(terraform output -raw firewall_public_ip)"
trap - EXIT
