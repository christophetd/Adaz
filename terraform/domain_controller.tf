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
    tags = {  kind = "domain-controller" }
  network_interface_ids = [azurerm_network_interface.main.id]

  boot_diagnostics {
    enabled     = "true"
    storage_uri = ""
  }

  vm_size               = var.dc_vm_size
  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true
  # Delete data disks automatically when deleting the VM
  delete_data_disks_on_termination = true
  license_type = "Windows_Server"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-G2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = local.domain.dc_name
    admin_username = local.accounts.ansible.username
    admin_password = local.accounts.ansible.password
  }
  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = false
    
    timezone                  = "Central European Standard Time"
    winrm {
      protocol = "HTTP"
    }
  }

}

resource "azurerm_virtual_machine_extension" "domsoft" {
  name                 = "install-domsoft"
   publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
   virtual_machine_id = azurerm_virtual_machine.dc.id
  type_handler_version = "1.10"
  settings = <<SETTINGS
        {
              "fileUris": [
                "https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
                    ],
            "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
        }
    SETTINGS
   depends_on = [ 
     azurerm_virtual_machine.dc
    ]
  }



# Provision rest of DC outside of the VM resource block to allow provisioning workstations concurrently
resource "null_resource" "dc_provision" {
  provisioner "local-exec" {
    working_dir = "${path.root}/../ansible"
    command     =  "bash -c 'source ~/Adaz/ansible/venv/bin/activate && ansible-playbook ~/Adaz/ansible/domain-controllers.yml --tags=common,init -v'"
  }

   depends_on = [
    azurerm_virtual_machine.dc,
    azurerm_virtual_machine_extension.domsoft,
  ]
}
