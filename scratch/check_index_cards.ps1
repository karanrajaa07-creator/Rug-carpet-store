$match = Select-String -Path .\index.html -Pattern 'product-card|renderProductCard|PRODUCTS_DATA|size-pill|card-size'
if ($match) {
    Write-Host "Found in index.html: $($match.Count) matches"
    $match | ForEach-Object { Write-Host "  Line $($_.LineNumber): $($_.Line.Trim())" }
} else {
    Write-Host "No matches in index.html"
}
