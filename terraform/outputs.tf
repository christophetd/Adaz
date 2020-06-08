output "dc_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "kibana_url" {
  value = "http://${azurerm_public_ip.elasticsearch.ip_address}:5601"
}

output "what_next" {
  value = <<EOF

####################
###  WHAT NEXT?  ###
####################

Check out your logs in Kibana: 
http://${azurerm_public_ip.elasticsearch.ip_address}:5601

RDP to your domain controller: 
xfreerdp /v:${azurerm_public_ip.main.ip_address} /u:${local.domain.dns_name}\\${local.domain.initial_domain_admin.username} '/p:${local.domain.initial_domain_admin.password}' +clipboard /cert-ignore

RDP to a workstation:
xfreerdp /v:${azurerm_public_ip.workstation[0].ip_address} /u:${local.domain.default_local_admin.username} '/p:${local.domain.default_local_admin.password}' +clipboard /cert-ignore

EOF
}

output "workstations_public_ips" {
  value = zipmap(azurerm_virtual_machine.workstation.*.name, azurerm_public_ip.workstation.*.ip_address)
}