$files = Get-ChildItem -Path . -Filter "*.html"
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    # Check for words Small, Medium, Large near each other or in buttons/options
    if ($content -match 'Small' -and $content -match 'Medium' -and $content -match 'Large') {
        Write-Host "Found Small+Medium+Large in: $($f.Name)"
    }
}
