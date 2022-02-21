resource "random_password" "elasticsearch" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_network_interface" "elasticsearch" {
  name                = "es-kibana-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "static"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.servers_subnet_cidr, 100)
    public_ip_address_id          = azurerm_public_ip.elasticsearch.id
  }
}
resource "azurerm_network_interface_security_group_association" "elasticsearch" {
  network_interface_id      = azurerm_network_interface.elasticsearch.id
  network_security_group_id = azurerm_network_security_group.elasticsearch_kibana.id
}
resource "azurerm_virtual_machine" "es_kibana" {

  name                  = "es-kibana"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.elasticsearch.id]
  vm_size               = "Standard_DS1_v2"

  # Delete OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Delete data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "es-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "elasticsearch-kibana"
    admin_username = var.elasticsearch_admin_user
    # The admin password shouldn't be needed since the admin user can sudo without password
    # and SSH uses SSH keys authentication
    admin_password = random_password.elasticsearch.result
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.elasticsearch_admin_user}/.ssh/authorized_keys"
      key_data = local.ssh_key
    }
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/../ansible"
    # Note: ANSIBLE_HOST_KEY_CHECKING needs to be set like this because 'source venv/bin/activate' will reset the environment, hence it cannot be passed via an environment {} block
    command = "/bin/bash -c 'source venv/bin/activate && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook elasticsearch-kibana.yml -v'"
  }

  tags = {
    kind = "elasticsearch"
  }
}