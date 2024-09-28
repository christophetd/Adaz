variable "domain_config_file" {
  description = "Path to the domain configuration file"
  default     = "../ansible/domain-config.yml"
}

variable "accounts_config_file" {
  description = "Path to the domain configuration file"
  default     = "../ansible/account_ansible.yml"
}

variable "servers_subnet_cidr" {
  description = "CIDR to use for the Servers subnet"
  default     = "10.0.4.0/24"
}

variable "workstations_subnet_cidr" {
  description = "CIDR to use for the Workstations subnet"
  default     = "10.0.5.0/24"
}

variable "region" {
  description = "Azure region in which resources should be created. See https://azure.microsoft.com/en-us/global-infrastructure/locations/"
  default     = "UK South"
}

variable "resource_group" {
  # Warning: see https://github.com/christophetd/adaz/blob/master/doc/faq.md#how-to-change-the-name-of-the-resource-group-in-which-resources-are-created
  description = "Resource group in which resources should be created. Will automatically be created and should not exist prior to running Terraform"
  default     = "ad-domtest-lab"
}

variable "dc_vm_size" {
  description = "Size of the Domain Controller VM. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
  default     = "Standard_D2s_v3"
}

variable "workstations_vm_size" {
  description = "Size of the workstations VMs. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
  default     = "Standard_D2s_v3"
}
