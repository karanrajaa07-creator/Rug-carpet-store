$files = Get-ChildItem -Path . -Filter "*.html"
foreach ($f in $files) {
    $matches = Select-String -Path $f.FullName -Pattern 'Small|Medium|Large|size-pill|data-tier|selectCardSize|selectProductDetailTier'
    if ($matches) {
        Write-Host "File: $($f.Name) ($($matches.Count) matches)"
        $matches | Select-Object -First 5 | ForEach-Object {
            Write-Host "  Line $($_.LineNumber): $($_.Line.Trim())"
        }
    }
}
