# You can change the following defaults by altering the below settings:
#


# Set the following to true to enable the setup wizard for first time run
$SetupWizard =$true


# Start of Settings
# Please Specify the IP address or Hostname of the server to connect to
$Server ="192.168.0.9"
# Please Specify the SMTP server address
$SMTPSRV ="mysmtpserver.mydomain.local"
# Please specify the email address who will send the vCheck report
$EmailFrom ="me@mydomain.local"
# Please specify the email address who will receive the vCheck report
$EmailTo ="me@mydomain.local"
# Please specify an email subject
$EmailSubject="$Server vCheck Report"
# Would you like the report displayed in the local browser once completed ?
$DisplaytoScreen =$True
# Use the following item to define if an email report should be sent once completed
$SendEmail =$true
# Send the report by e-mail even if it is empty?
$SendEmptyReport =$true
# If you would prefer the HTML file as an attachment then enable the following:
$SendAttachment =$false
# Set the style template to use.
$Style ="VMware"
# Set the following setting to $true to see how long each Plugin takes to run as part of the report
$TimeToRun = $true
# Report an plugins that take longer than the following amount of seconds
$PluginSeconds = 30
# End of Settings


$Date = Get-Date
