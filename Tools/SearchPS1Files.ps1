$rootFolder = 'D:\Temp\vCheck-vSphere'
$search = 'Windowscreds.xml'

foreach($file in (Get-ChildItem -Path $rootFolder -Filter *.ps1 -Recurse -File)){
    Get-Content -Path $file.FullName | where{$_ -match [Regex]::Escape($search)} |
    Select @{N='File';E={$file.FullName}},
        @{N='Line';E={$_}}
}