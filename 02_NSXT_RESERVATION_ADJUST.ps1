#Sets Variables for script

#vCenter where $NSXTMGR was deployed to
$VISERVER="vcsa-01b.corp.local"
$VIUSER="administrator@vsphere.local"
$VIPASSWORD="VMware1!"

#NSXTMGR that was built using Ansible
$NSXTMGR="nsxt-01a.corp.local"

#Sets the memory reservation of the $NSXTMGR
$MEMRESERVMB="8192"


Connect-VIServer -Server $VISERVER -User $VIUSER -Password $VIPASSWORD -InformationAction Ignore -ErrorAction Ignore
Get-VMResourceConfiguration -VM $NSXTMGR | Set-VMResourceConfiguration -MemReservationMB $MEMRESERVMB
Start-VM $NSXTMGR
