variable "prefix" {
  # Careful: used in ansible dynamc inventory
  default = "ad-lab"
}

resource "azurerm_resource_group" "main" {
    name = var.resource_group
    location = var.region
}
