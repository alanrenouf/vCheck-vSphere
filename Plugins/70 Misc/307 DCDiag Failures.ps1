

# Start of Settings 
# End of Settings

dcdiag.exe /s:$ADWebServer | FL | Out-file dcdiag.txt 
get-content dcdiag.txt | select-string "Failed" | select line, pattern
get-content dcdiag.txt | select-string "Passed" | select line, pattern

$Title = "DCDiag Failures"
$Header =  "DCDiag Failures"
$Comments = "List any failures from DCDiag Utility"
$Display = "Table"
$Author = "Eric Shanks"
$Version = 1.0
$PluginCategory = "Active Directory"