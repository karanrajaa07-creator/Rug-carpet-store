$files = Get-ChildItem -Path "assets\js" -Filter "*.js"
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    if ($content -match 'Small' -and $content -match 'Medium' -and $content -match 'Large') {
        Write-Host "Found Small+Medium+Large in: $($f.Name)"
    }
}
