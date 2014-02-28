![Alt text](http://www.virtu-al.net/wp-content/uploads/2014/02/vCheck619.jpg "vCheck Sample")

[![Stories in Ready](http://badge.waffle.io/alanrenouf/vCheck-vSphere.png)](http://waffle.io/alanrenouf/vCheck-vSphere)  
vCheck-vSphere
==============

vCheck Daily Report for vSphere

vCheck is a PowerShell HTML framework script, the script is designed to run as a scheduled task before you get into the office to present you with key information via an email directly to your inbox in a nice easily readable format.

This script picks on the key known issues and potential issues scripted as plugins for various technologies written as powershell scripts and reports it all in one place so all you do in the morning is check your email.

One of they key things about this report is if there is no issue in a particular place you will not receive that section in the email, for example if there are no datastores with less than 5% free space (configurable) then the disk space section in the virtual infrastructure version of this script, it will not show in the email, this ensures that you have only the information you need in front of you when you get into the office.

This script is not to be confused with an Audit script, although the reporting framework can also be used for auditing scripts too.  I dont want to remind you that you have 5 hosts and what there names are and how many CPUs they have each and every day as you dont want to read that kind of information unless you need it, this script will only tell you about problem areas with your infrastructure.

What is checked for in the vSphere version ?
============================================

The following items are included as part of the vCheck vSphere download, they are included as vCheck Plugins and can be removed or altered very easily by editing the specific plugin file which contains the data.  vCheck Plugins are found under the Plugins folder.

- General Details
- Number of Hosts
- Number of VMs
- Number of Templates
- Number of Clusters
- Number of Datastores
- Number of Active VMs
- Number of Inactive VMs
- Number of DRS Migrations for the last days
- Snapshots over x Days old
- Datastores with less than x% free space
- VMs created over the last x days
- VMs removed over the last x days
- VMs with No Tools
- VMs with CD-Roms connected
- VMs with Floppy Drives Connected
- VMs with CPU ready over x%
- VMs with over x amount of vCPUs
- List of DRS Migrations
- Hosts in Maintenance Mode
- Hosts in disconnected state
- NTP Server check for a given NTP Name
- NTP Service check
- vmkernel warning messages ov the last x days
- VC Error Events over the last x days
- VC Windows Event Log Errors for the last x days with VMware in the details
- VC VMware Service details
- VMs stored on datastores attached to only one host
- VM active alerts
- Cluster Active Alerts
- If HA Cluster is set to use host datastore for swapfile, check the host has a swapfile location set
- Host active Alerts
- Dead SCSI Luns
- VMs with over x amount of vCPUs
- vSphere check: Slot Sizes
- vSphere check: Outdated VM Hardware (Less than V7)
- VMs in Inconsistent folders (the name of the folder is not the same as the name)
- VMs with high CPU usage
- Guest disk size check
- Host over committing memory check
- VM Swap and Ballooning
- ESXi hosts without Lockdown enabled
- ESXi hosts with unsupported mode enabled
- General Capacity information based on CPU/MEM usage of the VMs
- vSwitch free ports
- Disk over commit check
- Host configuration issues
- VCB Garbage (left snapshots)
- HA VM restarts and resets
- Inaccessible VMs
- Much, Much more.......

More Info
=========

For more information please read here: http://www.virtu-al.net/vcheck-pluginsheaders/vcheck/

For an example vSphere output (doesnt contain all info) click here http://virtu-al.net/Downloads/vCheck/vCheck.htm

