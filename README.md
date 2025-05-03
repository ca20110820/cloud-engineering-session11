# Azure Firewall Deployment & VNet Monitoring

## Overview
This Terraform repository deploys a secure Azure infrastructure including:
- A resource group
- A virtual network (VNet) with two subnets (`SubnetA` and `AzureFirewallSubnet`)
- A Windows VM in `SubnetA`
- An Azure Firewall in `AzureFirewallSubnet` with NAT rules for RDP access
- Monitoring alerts for VNet deletion (email notifications)

---

## Prerequisites
1. **Terraform** (version >= 1.5.0)
2. **Azure CLI** installed and authenticated (`az login`)
3. **Variables** configured in `terraform.tfvars`:
   - `subscription_id`
   - `resource_group_name`
   - `admin_username`, `admin_password`
   - `alert_email` (for deletion alerts)
   
   Be sure to create the `terraform.tfvars` file:
   ```bash
   cp terraform.tfvars.sample terraform.tfvars
   ```

---

## Deployment  

### 1. Initialize and Deploy
Run the deployment script:
```bash
./deploy.sh
```
- **Automatically initializes Terraform**, validates the config, and applies the plan.
- Outputs the **Firewall Public IP** upon success.

### 2. Access the VM
Use the Firewall's public IP (from `terraform output firewall_public_ip`) to connect via RDP.

---

## Destruction

### 1. Destroy Resources
To manually destroy the infrastructure:
```bash
terraform destroy -auto-approve
```

---

## Notes
- The script automatically cleans up resources on failure.
- The VM's public IP is disabled, access is routed through the Firewall.
- Monitoring alerts are configured to trigger on VNet deletion.
