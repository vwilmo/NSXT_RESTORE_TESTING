#Defines variables for a NSXT Tier-1 Gateway and a NSXT Segment
$NSXTUSER="admin"
$NSXTPASSWORD="VMware1!VMware1!"
$NSXT_TIER1="T1-02a"
$NSXT_SEGMENT="nsxt-restore-segment"
$NSXT_GWADDR="1.1.1.1/24"
#Changes Policy API 'marked for delete' to true, which removes all objects in the hierarchy
$MFD="true"

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