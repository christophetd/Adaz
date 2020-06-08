# Common operations

This page provides some guidance around common operations you might wish to perform on your lab.

## Viewing public IPs of your instances


```bash
$ terraform output

dc_public_ip = 13.89.191.140
kibana_url = http://52.176.3.250:5601
what_next =
####################
###  WHAT NEXT?  ###
####################

Check out your logs in Kibana:
http://52.176.3.250:5601

RDP to your domain controller:
xfreerdp /v:13.89.191.140 /u:hunter.lab\\hunter '/p:Hunt3r123.' +clipboard /cert-ignore

RDP to a workstation:
xfreerdp /v:52.176.5.229 /u:localadmin '/p:Localadmin!' +clipboard /cert-ignore


workstations_public_ips = {
  "DANY-WKS" = "52.165.182.15"
  "XTOF-WKS" = "52.176.5.229"
}
```

## Destroying the lab

While `terraform destroy` is an option, I found that simply nuking the resource group works better. You'll also need to remove the Terraform state file to make sure Terraform understands it shouldn't manage it anymore.

```bash
az group delete --yes --no-wait -g ad-hunting-lab
rm terraform/terraform.tfstate
```

Note: Resource groups take a non-negligible amount of time to be deleted. Remove the `--no-wait` flag to have the command hang until the deletion is performed. If you remove the lab and re-instantiate it shortly afterwards, you might run into vCPU quota issues in Free Tier subscriptions, in which case I'd suggest to change the region and resource group name to something else in your new instantiation (e.g. `East US` and `ad-hunting-lab-2`)

## SSH'ing to the Elasticsearch/Kibana instance

By default, Terraform adds your `~/.ssh/id_rsa.pub` key to the authorized_keys of the `hunter` user of the instance. Therefore you should directly be able to SSH to the instance using its public IP.

## Adding users, groups, OUs after the lab has been instantiated

Change the configuration in `domain.yml` and run Ansible against your workstations and domain controller:

```bash
cd ansible
source venv/bin/activate

ansible-playbook domain-controllers.yml
ansible-playbook workstations.yml
```

Note that you cannot modify every setting this way. For instance, you cannot change the domain's FQDN or the number of workstations.

## Adding/removing workstations

Change the configuration in `domain.yml` and run a `terraform apply`. If, on the first instantiation, you specified non-defaults variables (e.g. the Azure region), don't forget to include them (e.g. `terraform apply -var 'region=East US'`) 

## Applying OS updates

When the lab is provisioned, the latest OS updates (Windows/Ubuntu) are not applied. To apply them, run the dedicated Ansible playbooks:

```bash
cd ansible
source venv/bin/activate

ansible-playbook workstations-os-updates.yml
ansible-playbook domain-controllers-os-updates.yml
ansible-playbook elasticsearch-kibana-os-updates.yml
```

This will apply critical updates, security updates and update rollups.