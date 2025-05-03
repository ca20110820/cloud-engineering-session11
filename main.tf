resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "FWvnet"
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.1.0/26"]
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.1.64/26"]
}

resource "azurerm_public_ip" "fw_pip" {
  name                = "fwip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw" {
  name                = "azurefirewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "fwvm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_a.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_firewall_nat_rule_collection" "rdp" {
  name                = "rdp-nat"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "allow-rdp"

    source_addresses      = ["*"]
    destination_addresses = [azurerm_public_ip.fw_pip.ip_address]
    destination_ports     = ["3389"]
    translated_address    = azurerm_network_interface.vm_nic.private_ip_address
    translated_port       = 3389
    protocols             = ["TCP"]
  }
}


resource "azurerm_monitor_action_group" "alert" {
  name                = "vnet-delete-alerts"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "vnetalert"

  email_receiver {
    name          = "emailalert"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_activity_log_alert" "vnet_delete" {
  name                = "vnet-delete-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_resource_group.rg.id]
  location            = "global"

  criteria {
    operation_name = "Microsoft.Network/virtualNetworks/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alert.id
  }
}
