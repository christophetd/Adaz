variable "domain_config_file" {
  description = "Path to the domain configuration file"
  default     = "../ansible/domain-config.yml"
}

variable "accounts_config_file" {
  description = "Path to the domain configuration file"
  default     = "../ansible/accansible.yml"
}

variable "servers_subnet_cidr" {
  description = "CIDR to use for the Servers subnet"
  default     = "10.0.10.0/24"
}

variable "workstations_subnet_cidr" {
  description = "CIDR to use for the Workstations subnet"
  default     = "10.0.11.0/24"
}

variable "elasticsearch_admin_user" {
  description = "Name of the initial admin user on the Elasticsearch / Kibana machine"
  # Warning: if you change this, also change it in ansible/elasticsearch-kibana.yml
  default = "hunter"
}

variable "ssh_key" {
  description = "Path to SSH key to add to the Elasticsearch / Kibana instance"
  default     = "~/.ssh/id_rsa.pub"
}

variable "region" {
  description = "Azure region in which resources should be created. See https://azure.microsoft.com/en-us/global-infrastructure/locations/"
  default     = "West Europe"
}

variable "resource_group" {
  # Warning: see https://github.com/christophetd/adaz/blob/master/doc/faq.md#how-to-change-the-name-of-the-resource-group-in-which-resources-are-created
  # Warning: if you change this, also change it in ansible/inventory_azure_rm.yml
  description = "Resource group in which resources should be created. Will automatically be created and should not exist prior to running Terraform"
  default     = "ad-hunting-lab"
}

variable "dc_vm_size" {
  description = "Size of the Domain Controller VM. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
  default     = "Standard_D1_v2"
}

variable "workstations_vm_size" {
  description = "Size of the workstations VMs. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
  default     = "Standard_D1_v2"
}
