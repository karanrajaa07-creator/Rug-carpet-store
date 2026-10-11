$matches = Select-String -Path .\*.html -Pattern 'gallery-interior'
foreach ($m in $matches) {
    Write-Host "$($m.Filename):$($m.LineNumber): $($m.Line.Trim())"
}
