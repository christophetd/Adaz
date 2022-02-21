data "azurerm_public_ip" "main" {
  name                = azurerm_public_ip.main.name
  resource_group_name = var.resource_group
  depends_on          = [azurerm_public_ip.main]
}

data "azurerm_public_ip" "workstation" {
  count = length(local.domain.workstations)

  name                = azurerm_public_ip.workstation[count.index].name
  resource_group_name = var.resource_group
  depends_on          = [azurerm_public_ip.workstation]
}

data "azurerm_public_ip" "elasticsearch" {
  name                = azurerm_public_ip.elasticsearch.name
  resource_group_name = var.resource_group
  depends_on          = [azurerm_public_ip.elasticsearch]
}

data "http" "public_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Needed for packer
#data "azurerm_image" "dc" {
#  name                = "ws2019-dc-base"
#  resource_group_name = "packer"
#}

#data "azurerm_image" "workstation" {
#  name                = "workstation-base2"
#  resource_group_name = "packer"
#}