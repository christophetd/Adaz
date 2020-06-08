# `domain.yml` reference

This page provides reference documentation for the `domain.yml` configuration file used to configure your lab.

Annotated configuration file:

```yaml
# FQDN of your domain
dns_name: hunter.lab

# Hostname of the domain controller
dc_name: DC-1

# Credentials of the initial domain admin
initial_domain_admin:
  username: christophe
  password: MyP4ssword!

# Credentials of the local admin created on all workstations
default_local_admin:
  username: localadmin
  password: Localadmin!

# Organizational units
organizational_units:
- OU=Roles
- OU=Privileged,OU=Roles
- OU=France
- OU=Marseille,OU=France

# Domain users - by default, password := username
users:
- username: john
- username: brent
  OU: OU=France
- username: dany
  password: Dany123
  OU: OU=Marseille,OU=France

# Domain groups to create
groups:
- dn: CN=MyRole,OU=Roles
  members: [john, brent, dany]
- dn: CN=AllMyUsers,CN=Users
  members: [john, brent, dany]

workstations:
- name: XTOF-WKS # Must be less than 15 characters
  # Local users to create on the machine - by default, password := username
  local_users:
  - localuser
  - username: localuser2
    password: woot

    # Local admins of the machine - can be domain or local users
    local_admins: [john, dany, localuser2]

- name: DANY-WKS

enable_windows_firewall: no
```
