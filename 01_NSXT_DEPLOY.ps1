#Sets Variables for script

#vCenter where $NSXTMGR was deployed to
$VISERVER="vcsa-01b.corp.local"
$VIUSER="administrator@vsphere.local"
$VIPASSWORD="VMware1!"
$NSXTMGRIP="192.168.0.107"
$NSXTUSER="admin"
$NSXTPASSWORD="VMware1!VMware1!"

#OVFTOOL Variables
$OVFTOOL_PATH="C:\Program Files\VMware\VMware OVF Tool\ovftool.exe" 
$NSXT_ARGS=' --sourceType=OVA --deploymentOption="small" --name=nsxt-01a.corp.local --X:injectOvfEnv --X:logFile=C:\temp\nsxovftool.log 
--allowExtraConfig --datastore=NFS --network=nsxt-restore-segment --acceptAllEulas --noSSLVerify --diskMode=thin --prop:"nsx_role=nsx-manager nsx-controller" 
--prop:"nsx_ip_0=192.168.0.107" --prop:"nsx_netmask_0=255.255.255.0" --prop:"nsx_gateway_0=192.168.0.3" --prop:"nsx_dns1_0=192.168.0.110" 
--prop:"nsx_domain_0=corp.local" --prop:"nsx_ntp_0=192.168.0.110" --prop:"nsx_isSSHEnabled=True" --prop:"nsx_allowSSHRootLogin=True" --prop:"nsx_passwd_0=VMware1!VMware1!" 
--prop:"nsx_cli_passwd_0=VMware1!VMware1!" --prop:"nsx_cli_audit_passwd_0=VMware1!VMware1!" 
--prop:"nsx_hostname=nsxt-01a.corp.local" "C:\temp\nsx-unified-appliance-2.4.1.0.0.13716579.ova" vi://administrator@vsphere.local:VMware1!@vcsa-01b.corp.local/DC-01b/host/COMP_CLUSTER-01b'

#Defines variables for a NSXT Tier-1 Gateway and a NSXT Segment
$NSXT_TIER1="T1-02a"
$NSXT_SEGMENT="nsxt-restore-segment"
$NSXT_GWADDR="1.1.1.1/24"
$MFD="false"

#Builds Credential and Authorization Headers
$NSXTHEADERS = @{ Authorization = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $NSXTUSER,$NSXTPASSWORD))) }

#Creates a NSXT Tier-1 Gateway and a NSXT Segment that's attached for the Backup NSXT Manager to attach to
$create_network_body=@"
{"resource_type":"Infra",
    "children":[
        {
            "resource_type": "ChildTier1",
            "marked_for_delete": $MFD,
            "Tier1":{
                "resource_type": "Tier1",
                "id": "$NSXT_TIER1",
                "description": "$NSXT_TIER1",
                "display_name": "$NSXT_TIER1",
            "children":[        
                    {      
                        "resource_type": "ChildSegment",
                        "Segment": {
                            "resource_type": "Segment",
                            "marked_for_delete": $MFD,
                            "id": "nsxt_restore-segment",
                            "description": "$NSXT_SEGMENT",
                            "display_name": "$NSXT_SEGMENT",
                            "type": "ROUTED",
                            
                            "subnets": [
                            {
                                "gateway_address": "$NSXT_GWADDR"
                            }
                        ]
                    }
                }
                    
            ]
        }
        }
    ]
    }
"@


#Calls NSXT Policy API to create an isolated Tier-1 GW and Segment
Write-Host -ForegroundColor Green "Creating NSX-T Tier-1 and NSX-T Segment for Restore Testing"
Invoke-RestMethod -Uri "https://$NSXTMGRIP/policy/api/v1/infra" -Method PATCH -ContentType "application/json" -SkipCertificateCheck -Headers $NSXTHEADERS -Body $create_network_body

#Deploys an NSXT Manager on the previously created isolated network
Write-Host -ForegroundColor Green "Connecting to vCenter Server and sleeping for 10 seconds"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm
Connect-VIServer -Server $VISERVER -User $VIUSER -Password $VIPASSWORD -InformationAction Ignore -ErrorAction Ignore
Start-Sleep 10

Write-Host -ForegroundColor Green "Deploying NSX-T OVA"
Start-Process $OVFTOOL_PATH $NSXT_ARGS 
