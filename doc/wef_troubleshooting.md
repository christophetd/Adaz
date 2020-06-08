# WEF troubleshooting

This guide aims at providing pointers to troubleshoot issues with Windows Event Forwarding. It can be used in the context of this project but also more generally.

## On the collector

(In the context of this project, the collector is the domain controller)

### Check if the subscription has active event sources (e.g. workstations)

```
wecutil gr Workstations

Subscription: Workstations
        RunTimeStatus: Active
        LastError: 0
        EventSources:
                DANY-WKS.hunter.lab
                        RunTimeStatus: Active
                        LastError: 0
                        LastHeartbeatTime: 2020-05-27T15:48:43.387
                XTOF-WKS.hunter.lab
                        RunTimeStatus: Active
                        LastError: 0
                        LastHeartbeatTime: 2020-05-27T15:42:20.502
```

### Check which event sources are included in the subscription

... and make sure they are correct:
- Open the Event Log (`eventvwr`)
- Go to *Subscriptions*
- Right-click on your subscription and select *Properties*
- Click on *Select computer groups*
- Ensure the right groups are selected, e.g. `YOURDOMAIN\Domain Computers`

### Ensure the Windows Event Collector service is started

```
PS C:\Users\christophe> Get-Service wecsvc

Status   Name               DisplayName
------   ----               -----------
Running  wecsvc             Windows Event Collector
```

### Ensure that WinRM is enabled and listening on the right IPs

```
PS C:\Users\christophe> winrm enum winrm/config/Listener

Listener
    Address = *
    Transport = HTTP
    Port = 5985
    Hostname
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint
    ListeningOn = 10.0.10.10, 127.0.0.1
```

### Ensure URL ACLs are correctly set

If, in the Windows Forwarding Logs on the workstation (see below: *Check Windows Event Forwarding logs*) you have an error similar to:

> The forwarder is having a problem communicating with subscription manager at address http://DC-1.hunter.lab:5985/wsman/SubscriptionManager/WEC. Error code is 2150859027 and Error Message is The WinRM client sent a request to an HTTP server and got a response saying the requested HTTP URL was not available. This is usually returned by a HTTP server that does not support the WS-Management protocol.

Run:

```powershell
netsh http delete urlacl url=http://+:5985/wsman/ 
netsh http add urlacl url=http://+:5985/wsman/ sddl=D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)
netsh http delete urlacl url=https://+:5986/wsman/
netsh http add urlacl url=https://+:5986/wsman/ sddl=D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)
```

Source: https://support.microsoft.com/en-us/help/4494462/events-not-forwarded-if-the-collector-runs-windows-server

## On the event source (i.e. workstation)

### Check permissions on event logs

Ensure that the group `Event Log Readers` is allowed to `ListDirectory` on the security event logs:

```powershell
PS> wevtutil gl Security | findstr channelAccess
channelAccess: O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)

PS>  ConvertFrom-SddlString "O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)" | Select -ExpandProperty DiscretionaryAcl
NT AUTHORITY\SYSTEM: AccessAllowed (ChangePermissions, ...)
BUILTIN\Administrators: AccessAllowed (CreateDirectories, ListDirectory)
BUILTIN\Event Log Readers: AccessAllowed (ListDirectory)
```

And make sure that `NETWORK SERVICE` is in the `Event Log Readers`:

```powershell
PS> Get-LocalGroupMember "Event Log Readers"

ObjectClass Name                         PrincipalSource
----------- ----                         ---------------
Group       NT AUTHORITY\NETWORK SERVICE Unknown
```

### Check Windows Event Forwarding logs

```powershell
Get-WinEvent -LogName Microsoft-Windows-Forwarding/Operational `
| Sort-Object -Desc -Property TimeCreated `
| Out-GridView
```

(or *Microsoft > Windows > EventLog-ForwardingPlugin > Operational* in the event viewer GUI)

### Check WinRM logs

```powershell
Get-WinEvent -LogName Microsoft-Windows-WinRM/Operational -MaxEvents 100 `
| Sort-Object -Desc -Property TimeCreated `
| Out-GridView
```

(or *Microsoft > Windows > Windows Remote Management > Operational* in the event viewer GUI)

### Check connectivity to the WEF

The local user `NT AUTHORIT\NETWORK SERVICE` should be able to communicate to the WEF over the WinRM port:

```powershell
# Should return a 404 but not hang
iwr http://DC-1.hunter.lab:5985
```

### Restart the WinRM service

I found that restarting the WinRM service (or the machine) can help in case the subscription was temporarily removed / disabled from the WEF in order to have the machine reach out to the WEF again to enumerate the subscriptions.

```powershell
Restart-Service WinRM
```