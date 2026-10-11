$files = Get-ChildItem -Path . -Filter "*.html"
foreach ($f in $files) {
    $lines = Get-Content $f.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match 'Medium|Large') {
            Write-Host "$($f.Name):$($i+1): $($line.Trim())"
        }
    }
}
