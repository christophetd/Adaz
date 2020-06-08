# Troubleshooting

## RDP/Kibana is unreachable

By default, only your public outgoing IP (as returned by canihazip.com) is allowed to access your lab. This is configured on the Network Security Groups attached to VM network interfaces.

Make sure your IP didn't change compared to when you last ran `terraform apply`. If it did change, just run `terraform apply` and the whitelisted IP will be automatically updated for you.

## No logs in Kibana

The logs flow from workstations to the domain controller via the Windows Event Forwarding protocol (on top of WinRM). Once on the domain controller, Winlogbeat sends them to Elasticsearch.

- Check if the logs of the workstations are in the `Forwarded Events` event log of the domain controller. If not, you'll need to troubleshoot the WEF - see [WEF troubleshooting guide](./wef_troubleshooting.md)

- Check the logs of Winlogbeat on the domain controller. They are located under `C:\ProgramData\Elastic\Beats\winlogbeat\logs`

- Check if Winlogbeat is running (`Get-Service winlogbeat`)
    
## "Operation could not be completed as it results in exceeding approved Total Regional Cores quota"

You might run into this error when running `terraform apply`. The full error looks like this:

```
Error: compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: autorest/azure: Service returned an error. Status=<nil> Code="OperationNotAllowed" Message="Ope
ration could not be completed as it results in exceeding approved Total Regional Cores quota. Additional details - Deployment Model: Resource Manager, Location: westeurope, Current Limit: 4, Current Usage:
4, Additional Required: 1, (Minimum) New Limit Required: 5. Submit a request for Quota increase at https://aka.ms/ProdportalCRP/?#create/Microsoft.Support/Parameters/%7B%22subId%22:%221c7e10d2-091b-4384-8
c75-b6d50232464a%22,%22pesId%22:%2206bfd9d3-516b-d5c6-5802-169c800dec89%22,%22supportTopicId%22:%22e12e3d1d-7fa0-af33-c6d0-3c50df9658a3%22%7D by specifying parameters listed in the ‘Details’ section for de
ployment to succeed. Please read more about quota limits at https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests." 
```

If you are using a Free Trial subscription, you will need to upgrade it to a Pay As You Go subscription or to reduce the number of cores of the lab you spin up. Azure currently allows at most 5 vCPUs per region with Free Trial subscriptions

If not, follow the link included in the error message to request a quota increase (Free Trial subscriptions are not eligible for this).