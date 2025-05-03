variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "VM admin username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "VM admin password"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email for alert notifications"
  type        = string
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}
