resource "azurerm_public_ip" "main" {
  name                    = "${var.prefix}-ingress"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_public_ip" "workstation" {
  count                   = length(local.domain.workstations)
  name                    = "${var.prefix}-wks-${count.index}-ingress"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

