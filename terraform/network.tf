resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "servers" {
  name                 = "servers"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.servers_subnet_cidr]
}

resource "azurerm_subnet" "workstations" {
  name                 = "workstations"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.workstations_subnet_cidr]
}


# Network security groups for interfaces

resource "azurerm_network_security_group" "windows" {
  name                = "windows-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-WinRM"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-WinRM-secure"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    # Note: it will still be blocked by the Windows Firewall if enabled
    name                       = "Allow-SMB"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "elasticsearch_kibana" {
  name                = "elasticsearch-kibana-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-Kibana"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5601"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }
}