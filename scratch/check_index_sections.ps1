$lines = Get-Content .\index.html
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '<!--\s*(\d+.*?)-->') {
        Write-Host "Line $($i+1): $($matches[1])"
    }
}
