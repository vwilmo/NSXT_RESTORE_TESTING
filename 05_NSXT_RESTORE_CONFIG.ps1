$NSXTMGRIP="192.168.0.107"
$NSXTUSER="admin"
$NSXTPASSWORD="VMware1!VMware1!"
$SFTPSERVER="192.168.0.106"
$SHA256THUMB="SHA256:2SBUw42tIdw8KdPDTbEH2k1CT1YV0i1LU64735q6ZlU"
$SFTPUSER="nsxt-sftp"
$SFTPPASS="VMware1!"
$SFTPPATH="/nsxt"
$SFTPENCRYPTPASS="VMware1!"
$SFTPPORT="22"



#Builds Credential and Authorization Headers
$NSXTHEADERS = @{ Authorization = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $NSXTUSER,$NSXTPASSWORD))) }

#Creates a NSXT Tier-1 Gateway and a NSXT Segment that's attached for the Backup NSXT Manager to attach to
$create_network_body=@"
{"remote_file_server":{
      "server":"$SFTPSERVER",
      "port":"$SFTPPORT",
      "protocol":{
         "protocol_name":"sftp",
         "ssh_fingerprint":"$SHA256THUMB",
         "authentication_scheme":{
            "scheme_name":"PASSWORD",
            "username":"$SFTPUSER",
            "password":"$SFTPPASS"
         }
      },
      "directory_path":"$SFTPPATH"
   },
      "passphrase":"$SFTPENCRYPTPASS"
}
"@

#Calls NSXT Policy API to create an isolated Tier-1 GW and Segment
Write-Host -ForegroundColor Green "Creating NSX-T Tier-1 and NSX-T Segment for Restore Testing"
Invoke-RestMethod -Uri "https://$NSXTMGRIP/api/v1/cluster/restore/config" -Method Put -ContentType "application/json" -SkipCertificateCheck -Headers $NSXTHEADERS -Body $create_network_body