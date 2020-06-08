# Audit policies

Ansible playbook: https://github.com/christophetd/ADAZ/blob/master/ansible/roles/logging-base/tasks/main.yml

|    Audit Policy    |       Audit      |
|:------------------:|:----------------:|
|    [Account logon](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-account-logon-events)   | Success, Failure |
| [Account management](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-account-management) | Success, Failure |
|      [DS Access](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-directory-service-access)     | Success, Failure |
|    [Logon/Logoff](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-account-logon-events)    | Success, Failure |
|    [Privilege use](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-privilege-use)    | Success, Failure |
|    [Policy Change](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-policy-change)    | Success, Failure |
|    [System](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-system-events)    | Success, Failure |
|    [Detailed tracking](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/basic-audit-process-tracking)    | Success, Failure |