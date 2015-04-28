<a name="Title">
# vCheck Daily Report for vSphere
[![Stories in Ready](http://badge.waffle.io/alanrenouf/vCheck-vSphere.png)](http://waffle.io/alanrenouf/vCheck-vSphere) &nbsp;&nbsp; &nbsp; [![Join the chat at https://gitter.im/alanrenouf/vCheck-vSphere](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/alanrenouf/vCheck-vSphere?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![Alt text](http://www.virtu-al.net/wp-content/uploads/2014/02/vCheck619.jpg "vCheck Sample")

|Navigation|
|-----------------|
|[About](#About)|
|[Features](#Features)|
|[More Info](#More)|
|[Release Notes](#ReleaseNotes)|
|[Contributing](#Contributing)|
|[Plugins](#Plugins)|
|[Styles](#Styles)|
|[Jobs & Settings](#JobsSettings)|

<a name="About">
# About
[*Back to top*](#Title)

vCheck is a PowerShell HTML framework script, the script is designed to run as a scheduled task before you get into the office to present you with key information via an email directly to your inbox in a nice easily readable format.

This script picks on the key known issues and potential issues scripted as plugins for various technologies written as powershell scripts and reports it all in one place so all you do in the morning is check your email.

One of they key things about this report is if there is no issue in a particular place you will not receive that section in the email, for example if there are no datastores with less than 5% free space (configurable) then the disk space section in the virtual infrastructure version of this script, it will not show in the email, this ensures that you have only the information you need in front of you when you get into the office.

This script is not to be confused with an Audit script, although the reporting framework can also be used for auditing scripts too.  I don't want to remind you that you have 5 hosts and what there names are and how many CPU's they have each and every day as you don't want to read that kind of information unless you need it, this script will only tell you about problem areas with your infrastructure.

<a name="Features">
# What is checked for in the vSphere version ?
[*Back to top*](#Title)

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

<a name="More">
# More Info
[*Back to top*](#Title)

For more information please read here: http://www.virtu-al.net/vcheck-pluginsheaders/vcheck/

For an example vSphere output (doesnt contain all info) click here http://virtu-al.net/Downloads/vCheck/vCheck.htm

<a name="ReleaseNotes">
# Release Notes
[*Back to top*](#Title)

* 6.22 - Fixes to VMware style. Consolidating plugins. Updates to style handling.
* 6.21 - Added support for charts. New plugins. Support non-standard vCenter Ports. Bugfixes
* 6.20 - First tagged release. Bugfixes. Email resource support added.
* 6.19 - Bugfixes.
* 6.18 - Added Job parameter to allow job specifications via XML file
* 6.17 - Basic Internationalization (i18n) support
* 6.16 - Table formatting rules
* 6.15 - Added Category to all plugins and features to vCheckUtils script for Categorys.
* 6.14 - Fixed a bug where a plugin was resetting the $VM variable so later plugins were not working :(
* 6.13 - Fixed issue with plugins 63 and 65 not using the days
* 6.12 - Changed Version to PluginVersion in each Plugin as the word Version is very hard to isolate!
* 6.11 - Fixed a copy and paste mistake and plugin issues.
* 6.10 - Fixed multiple spelling mistakes and small plugin issues
* 6.9 - Fixed VMKernel logs but had to remove date/Time parser due to inconsistent VMKernel Log entries
* 6.8 - Added Creator of snapshots back in due to popular demand
* 6.7 - Added Multiple plugins from contributors - Thanks!
* 6.6 - Tech Support Mode Plugin fixed to work with 5.0 hosts
* 6.5 - HW Version plugin fixed due to string output
* 6.4 - Added a 00 plugin and VeryLastPlugin for vCenter connection info to separate the report entirely from VMware if needed.
* 6.3 - Changed the format of each Plugin so you can include a count for each header and altered plugin layout for each plugin.
* 6.2 - Added Time to Run section based on TimeToBuild by Frederic Martin
* 6.1 - Bug fixes, filter for ps1 files only in the plugins folder so other files can be kept in the plugins folder.
* 6.0 - Moved plugins into seperate scripts to make it easier to expand vCheck and fixed issues + lots lots more !
* 5.1 - Code Fixes and ability to change colour for title text to fix issue with Outlook 2007/10 not displaying correctly
* 5.0 - Changed the order and a few titles etc, tidy up !
* 4.9 - Added Inacessable VMs
* 4.8 - Added HA VM restarts and resets
* 4.7 - VMTools Issues
* 4.6 - Added VCB Garbage
* 4.5 - Added Host config issues
* 4.4 - Added Disk Overcommit check
* 4.3 - Added vSwitch free ports check
* 4.2 - Added General Capacity Information based on CPU and MEM ussage per cluster
* 4.1 - Added the ability to change the colours of the report.
* 4.0 - HTML Tidy up, comments added for each item and the ability to enable/disable comments.

<a name="Contributing">
# Contributing
[*Back to top*](#Title)

See out [Contributions](CONTRIBUTING.md) guidelines

<a name="Plugins">
# Plugins
[*Back to top*](#Title)

## Plugin Structure
This section describes the basic structure of a vCheck plugin so that you can write your own plugins for either private use, or to contribute to the vCheck project.

### Settings
Your plugin must contain a section for settings. This may be blank, or may contain one or more variables that must be defined for your plugin to determine how it operates.

**Examples**

No Settings
  ```
  # Start of Settings   
  # End of Settings
  ```

Settings to define two variables
  ```
  # Start of Settings   
  # Comment - presented as part of the setup wizard   
  $variable = "value"     
  # Second variable     
  $variable2 = "value2"     
  ...     
  # End of Settings
  ```
  
### Required variables
Each plugin **must** define the following variables:
$Title - The display name of the plugin
$Header - the header of the plugin in the report
$Display - The format of the plugin (See Content section)
$Author - The author's name
$PluginVersion - Version of the plugin 
$PluginCategory - The Category of the plugin

### Content
#### Report output
Anything that is written to stdout is included in the report. This should be either an object or hashtable in order to generate the report information.

#### $Display variable
- List
- Table
- Chart - Not currently merged to master

#### Plugin Template
  ```
  # Start of Settings
  # End of Settings

  # generate your report content here. Simple placeholder hashtable for the sake of example
  @{"Plugin"="Awesome"}

  $Title = "Plugin Template"
  $Header =  "Plugin Template"
  $Comments = "Comment about this awesome plugin"
  $Display = "List"
  $Author = "Plugin Author"
  $PluginVersion = 1.0
  $PluginCategory = "vSphere"
  ```
## Table Formatting
Since v6.16, vCheck has supported Table formatting rules in plugins. This allows you to define a set of rules for data, in order to provide more richly formatted HTML reports.

### Using Formatting Rules

To use formatting rules, a `$TableFormat` variable must be defined in the module. 

The `$TableFormat` variable is a Hastable, with the key being the "column" of the table that the rule should apply to.

The Value of the Hashtable is an array of rule. Each rule is a hashtable, with the Key being the expression to evaluate, and the value containing the formatting options. 

### Formatting options

The Formatting options are made up of two comma-separated values: 
 1. The scope of the formatting rule - "Row" to apply to the entire row, or "Cell" to only apply to that particular cell. 
 2. A pipe-separated HTML attribute, and value. E.g. class|green to apply the "green" class to the HTML element specified in number 1. 

### Examples

#### Example 1

Assume you have a CSS class named "green", which you want to apply to any compliant objects. Similarly, you have a "red" class that you wish to use to highlight non-compliant objects. We would define the formatting rules as follows:

`$TableFormat = @{"Compliant" = @(@{ "-eq $true" = "Cell,class|green"; }, @{ "-eq$false" = "Cell,class|red" })}` 

Here we can see two rules; the first checks if the value in the Compliant column is equal to $true, in which case it applies the "green" class to the table cell (i.e. 
element). The second rule applies when the compliant column is equal to $false, and applied the "red" class. 

#### Example 2

Suppose you now want to run a report on Datastores. You wish to highlight datastores with less than 25% free space as "warning", those with free space less than 15% as "critical". To make them stand out more, you want to highlight the entire row on the report. You also wish to highlight datastores with a capacity less than 500GB as silver.

To achieve this, you could use the following: 
```
$TableFormat = @{"PercentFree" = @(@{ "-le 25" = "Row,class|warning"; }, @{ "-le 15" = "Row,class|critical" }); "CapacityGB" = @(@{ "-lt 500" = "Cell,style|background-color: silver"})}
 ```
Here we see the rules that apply to two different columns, with rules applied to the values in a fashion similar to Example 1.

[*Back to top*](#Title)


<a name="JobsSettings">
# Jobs & Settings
[*Back to top*](#Title)
