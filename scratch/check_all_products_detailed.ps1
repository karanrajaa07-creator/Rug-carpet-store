$content = Get-Content "assets\js\products.js" -Raw
# Let's inspect products definition
# We can use Edge to evaluate and dump everything about PRODUCTS_DATA
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$testHtml = Join-Path $root "test_products_detail_eval.html"
$testLog = Join-Path $root "scratch\test_products_detail_eval.txt"

$html = @"
<!DOCTYPE html><html><body>
<script src="assets/js/products.js"></script>
<script>
window.addEventListener('load', () => {
    const list = window.PRODUCTS_DATA.map(p => ({
        id: p.id,
        name: p.name,
        image: p.image,
        gallery: p.gallery,
        galleryLen: p.gallery ? p.gallery.length : 0,
        availableSizes: p.availableSizes,
        small: p.sizesData ? p.sizesData.small : null,
        medium: p.sizesData ? p.sizesData.medium : null,
        large: p.sizesData ? p.sizesData.large : null
    }));
    const out = document.createElement('div');
    out.id = 'OUT';
    out.textContent = JSON.stringify(list);
    document.body.appendChild(out);
});
</script>
</body></html>
"@

[System.IO.File]::WriteAllText($testHtml, $html, [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --dump-dom $url | Out-File $testLog -Encoding utf8
$dom = Get-Content $testLog -Raw
if ($dom -match '<div id="OUT">(.*?)</div>') {
    $data = ConvertFrom-Json $matches[1]
    foreach ($p in $data) {
        Write-Host "Product $($p.id): $($p.name)"
        Write-Host "  image: $($p.image)"
        Write-Host "  gallery: $($p.gallery -join ', ')"
        Write-Host "  smallImg: $($p.small.image)"
        Write-Host "  medImg:   $($p.medium.image)"
        Write-Host "  largeImg: $($p.large.image)"
        Write-Host "  smallPrice: $($p.small.price), medPrice: $($p.medium.price), largePrice: $($p.large.price)"
        Write-Host "  smallDim: $($p.small.dimensions), medDim: $($p.medium.dimensions), largeDim: $($p.large.dimensions)"
    }
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
