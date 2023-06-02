locals {
  domain    = yamldecode(file(var.domain_config_file))
  accounts = yamldecode(file(var.accounts_config_file))
  public_ip = chomp(data.http.public_ip.body)
  ssh_key   = file(pathexpand(var.ssh_key))
}
