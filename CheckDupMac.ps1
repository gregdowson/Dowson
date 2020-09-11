<#
.SYNOPSIS
This script accepts the name of a VM and the credentials to its
source vCenter Server as well as destination vCenter Server and its
credentials to check if there are any MAC Address conflicts prior to 
issuing a xVC-vMotion of VM (applicable to same and differnet SSO Domain)
.NOTES
File Name : check-vm-mac-conflict.ps1
Author : William Lam - @lamw
Version : 1.0
.LINK
http://www.virtuallyghetto.com/2015/03/duplicate-mac-address-concerns-with-xvc-vmotion-in-vsphere-6-0.html
.LINK
https://github.com/lamw
.INPUTS
sourceVC, sourceVCUsername, sourceVCPassword,destVC, destVCUsername, destVCPassword, vmname
.OUTPUTS
Console output
.PARAMETER sourceVC
The hostname or IP Address of the source vCenter Server
.PARAMETER sourceVCUsername
The username to connect to source vCenter Server
.PARAMETER sourceVCPassword
The password to connect to source vCenter Server
.PARAMETER destVC
The hostname or IP Address of the destination vCenter Server
.PARAMETER destVCUsername
The username to connect to the destination vCenter Server
.PARAMETER destVCPassword
The password to connect to the destination vCenter Server
.PARAMETER vmname
The name of the source VM to check for duplicated MAC Addresses
#>
param
(
   [Parameter(Mandatory=$true)]
   [string]
   $sourceVC,
   [Parameter(Mandatory=$true)]
   [string]
   $sourceVCUsername,
   [Parameter(Mandatory=$true)]
   [string]
   $sourceVCPassword,
   [Parameter(Mandatory=$true)]
   [string]
   $destVC,
   [Parameter(Mandatory=$true)]
   [string]
   $destVCUsername,
   [Parameter(Mandatory=$true)]
   [string]
   $destVCPassword,
   [Parameter(Mandatory=$true)]
   [string]
   $vmname
);

# Debug
#$sourceVC = "vcenter60-1.primp-industries.com"
#$sourceVCUsername = "administrator@vghetto.local"
#$sourceVCPassword = "VMware1!"
#
#$destVC = "vcenter60-2.primp-industries.com"
#$destVCUsername = "administrator@vghetto.local"
#$destVCPassword = "VMware1!"
#
#$vmname = "VM1"

# Connect to Source vCenter Server
$sourceVCConn = Connect-VIServer -Server $sourceVC -user $sourceVCUsername -password $sourceVCPassword

# Connect to Destination vCenter Server
$destVCConn = Connect-VIServer -Server $destVC -user $destVCUsername -password $destVCpassword

# Retrieve Source VM MAC Addresses
$sourceVMMACs = (Get-NetworkAdapter -Server $sourceVCConn -VM $vmname).MacAddress

# Retrieve ALL VM Mac Addresses from Destination vCenter Server
$allVMMacs = @{}
$vms = Get-View -Server $destVCConn -ViewType VirtualMachine -Property Name,Config.Hardware.Device -Filter @{"Config.Template" = "False"}
foreach ($vm in $vms) {
	$devices = $vm.Config.Hardware.Device
	foreach ($device in $devices) {
		if($device -is  [VMware.Vim.VirtualEthernetCard]) {
			# Store hash of Mac to VM to be used later for later comparison
			$allVMMacs.add($device.MacAddress,$vm.Name)
		}
	}
}

# Disconnect from Source/Dest vCenter Servers as it is no longer needed
Disconnect-VIServer -Server $sourceVCConn -Confirm:$false
Disconnect-VIServer -Server $destVCConn -Confirm:$false

# Check for duplicated MAC Addresses in destionation vCenter Server
Write-Host "`nChecking to see if there are MAC Address conflicts with" $vmname "at destination vCenter Server...`n"

foreach ($mac in $sourceVMMACs) {
	if($allVMMacs[$mac]) {
		Write-Host $allVMMacs[$mac] "also has MAC Address: $mac"
	}
}