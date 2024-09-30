output "dc_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "what_next" {
  value = <<EOF

####################
###  WHAT NEXT?  ###
####################


RDP to your domain controller: 
cmdkey /generic:"${azurerm_public_ip.main.ip_address}" /user:"${local.domain.dns_name}\${local.accounts.ansible.username}" /pass:"${local.accounts.ansible.password}"
mstsc /v:${azurerm_public_ip.main.ip_address} 
cmdkey /delete:TERMSRV/${azurerm_public_ip.main.ip_address}

RDP to a workstation:
cmdkey /generic:"${azurerm_public_ip.workstation[0].ip_address}" /user:"${local.accounts.ansible.username}" /pass:"${local.accounts.ansible.password}"
mstsc /v:${azurerm_public_ip.workstation[0].ip_address} 
cmdkey /delete:${azurerm_public_ip.workstation[0].ip_address}


EOF
}


