resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "static"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.servers_subnet_cidr, 10)
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_interface_security_group_association" "dc" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.windows.id
}


resource "azurerm_virtual_machine" "dc" {
  name                  = "domain-controller"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.dc_vm_size

# Enable boot diagnostics with auto managed storage
boot_diagnostics {
  enabled     = "true"
  storage_uri = ""
}
  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Delete data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "dc-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = local.domain.dc_name
    admin_username = local.domain.initial_domain_admin.username
    admin_password = local.domain.initial_domain_admin.password
  }
  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = false
    timezone                  = "Central European Standard Time"
    winrm {
      protocol = "HTTP"
    }
  }

  # Provision base domain and DC
  provisioner "local-exec" {
    working_dir = "${path.root}/../ansible"
    command     = "/bin/bash -c 'source venv/bin/activate && ansible-playbook domain-controllers.yml --tags=common,base -v'"
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/../ansible"
    command     = "/bin/bash -c 'source venv/bin/activate && ansible-playbook domain-controllers.yml --tags=common,init -v'"
  }

  tags = {
    kind = "domain-controller"
  }
}

# Provision rest of DC outside of the VM resource block to allow provisioning workstations concurrently
resource "null_resource" "provision_rest_of_dc_after_creation" {
  provisioner "local-exec" {
    working_dir = "${path.root}/../ansible"
    command     = "/bin/bash -c 'source venv/bin/activate && ansible-playbook domain-controllers.yml --skip-tags=base,init -v'"
  }

  depends_on = [
    azurerm_virtual_machine.dc,
    azurerm_virtual_machine.es_kibana
  ]
}
