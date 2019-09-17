#Sets Variables for script

#vCenter where $NSXTMGR was deployed to
$VISERVER="vcsa-01b.corp.local"
$VIUSER="administrator@vsphere.local"
$VIPASSWORD="VMware1!"

#NSXTMGR that was built 
$NSXTMGR="nsxt-01a.corp.local"
$AD="AD-01a_restored"
$SFTP="SFTP-01a_restored"
$BACKUP="BACKUP-01a_restored"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
Connect-VIServer -Server $VISERVER -User $VIUSER -Password $VIPASSWORD -InformationAction Ignore -ErrorAction Ignore

Stop-VM -Kill $NSXTMGR -Confirm:$false
Stop-VM -Kill $BACKUP -Confirm:$false
Stop-VM -Kill $SFTP -Confirm:$false
Stop-VM -Kill $AD -Confirm:$false

Remove-VM -VM $NSXTMGR -Confirm:$false -DeletePermanently
Remove-VM -VM $AD -Confirm:$false -DeletePermanently
Remove-VM -VM $SFTP -Confirm:$false -DeletePermanently
Remove-VM -VM $BACKUP -Confirm:$false -DeletePermanently
