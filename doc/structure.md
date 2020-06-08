# Project structure and organization

## domain.yml

High-level configuration file for the domain. See: [Domain configuration file reference](./configuration_reference.md).

## `ansible/`

Contains all Ansible playbooks and roles.

- `inventory_azure_rm.yml`: Dynamic inventory using the [Azure Resource Manager inventory plugin](https://docs.ansible.com/ansible/latest/plugins/inventory/azure_rm.html)

- `*-os-updates.yml`: Playbooks to update OS packages of workstations/domain controller/elasticsearch and kibana

- `workstations.yml`: Playbook to configure workstations (Azure tag `kind=workstation`). Uses the credentials of `default_local_admin` defined in `domain.yml`

- `workstations.yml`: Playbook to configure domain controllers (Azure tag `kind=domain-controller`). Uses the credentials of `initial_domain_admin` defined in `domain.yml`.

## `terraform/`

Contains Terraform configuration files.

- `domain_controller.tf`: VM running the domain controller
- `elasticsearch_kibana.tf`: VM running Elasticsearch and Kibana
- `locals.tf`: Local values, typically values read from `domain.yml`
- `network.tf`: Virtual network, subnets and network security groups
- `provider.tf`: Configuration of the [Azure provider](https://www.terraform.io/docs/providers/azurerm/index.html)
- `public_ips.tf`: Public IPs mapped to VMs
- `workstations.tf`: VMs running workstations