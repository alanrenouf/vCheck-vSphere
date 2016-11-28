Function Get-vCheckLogData {
	param(
		[string] $vCheckFile,
		[string] $Section
	)

	# Find the comment above the specified section table and grab the Post context for 6 lines beyond the comment
	# The HTML is stored within the next 6 lines.
	# line 1: <div style='height: 10px; font-size: 10px;'>&nbsp;</div>
	# line 2: <a name="plugin-#" />
	$ContextInfo = Select-String "Plugin Start - $Section" $vCheckFile -context 0,6

	# lines 3-6 are the data we want.
	$table = $ContextInfo.Context.PostContext | select -last 4

	# The table actually ends on line 7.  But line 6 looks like this:
	# <tr><td style="text-align: right; background: #FFFFFF"><a href="#top" style="color: black">Back To Top</a>
	# There is no ending </td></tr>
	# Line 7: </table>
	# So add these missing tags back in.
	$table += "</td></tr></table>"
	try {
		# Convert to XML for easier parsing
		$xmlObj = [xml]$table
	} catch {
		# This catches any instances where there are no matches in the file, and then the only data is the ending tags.
		# just in case you want to see it, Write-Verbose
		Write-Verbose "$vCheckFile : $table"
	}

	# There is a sub table with the data - so get the TR that contains a sub table
	$ParentTR = $xmlObj.table.tr | ? { $_.td.table }
	# Get the TD
	$ParentTD = $ParentTR.td
	# Get the table
	$SubTable = $ParentTD.Table

	# Use the TH to get the header names
	$th = $subTable.tr.th

	# Create a hash table that stores all the header names, and use the index as the key.  We'll use this as a lookup when we get to the TD
	$thHash = @{}
	for ($i=0;$i -lt $th.count; $i++) {
		$thHash.Add($i,$th[$i])
	}

	# Loop through each TR containing the log data
	for ($i=1; $i -lt $subTable.tr.count; $i++) {
		# Get the TDs under the TR, and loop through those
		$td = $subTable.tr[$i].td
		
		# build a hash table pulling the column name from the TH hash table, and the value from the TD
		$tdHash = @{}
		for ($j=0; $j -lt $td.count;$j++) {
			$tdHash.Add($thHash[$j],$td[$j])
		}
		# Return this as an object
		New-Object -Type PSObject -Prop $tdHash
	}
}
