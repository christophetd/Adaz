# Architecture

<p align="center">
    <img src="../screenshots/architecture.png" width="85%" />
</p>

## Network architecture

1 subnet for workstations and 1 subnet for servers. At the time, no specific filtering is done between the two. If you believe this would be valuable, please thumbs up this [feature proposal](https://github.com/christophetd/adaz/issues/3)!

## Provisioning flow

Creation of resources is performed by Terraform. Once a VM is created in Azure, it is then provisioned with Ansible using the `local-exec` provisioner. For instance:

```hcl
# Provision Elasticsearch/Kibana instance
provisioner "local-exec" {
    working_dir = "${path.root}/../ansible"
    command = "/bin/bash -c 'source venv/bin/activate && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook elasticsearch-kibana.yml -v'"
  }
```

In addition, a few tricks with `null_resources` are used to better parallelize provisioning.