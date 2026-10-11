$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"
$testHtml = Join-Path $root "test_inspect_data.html"
$testLog = Join-Path $scratch "test_inspect_data_out.txt"

$html = @"
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body>
<script src="assets/js/products.js"></script>
<script>
window.addEventListener('load', () => {
    const results = [];
    window.PRODUCTS_DATA.forEach(p => {
        const item = {
            id: p.id,
            name: p.name,
            gallery: p.gallery,
            smallImg: p.sizesData ? p.sizesData.small.image : null,
            medImg: p.sizesData ? p.sizesData.medium.image : null,
            largeImg: p.sizesData ? p.sizesData.large.image : null,
            allSame: false
        };
        if (item.smallImg === item.medImg && item.medImg === item.largeImg) {
            item.allSame = true;
        }
        results.push(item);
    });
    const div = document.createElement('div');
    div.id = 'RESULTS';
    div.textContent = JSON.stringify(results);
    document.body.appendChild(div);
});
</script>
</body>
</html>
"@

[System.IO.File]::WriteAllText($testHtml, $html, [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --dump-dom $url | Out-File $testLog -Encoding utf8
$dom = Get-Content $testLog -Raw
if ($dom -match '<div id="RESULTS">(.*?)</div>') {
    $json = $matches[1]
    $obj = ConvertFrom-Json $json
    foreach ($p in $obj) {
        Write-Host "Product $($p.id): $($p.name)"
        Write-Host "  Small: $($p.smallImg)"
        Write-Host "  Med:   $($p.medImg)"
        Write-Host "  Large: $($p.largeImg)"
        Write-Host "  All Same: $($p.allSame)"
        # Check if files exist
        $sExists = Test-Path (Join-Path $root $p.smallImg)
        $mExists = Test-Path (Join-Path $root $p.medImg)
        $lExists = Test-Path (Join-Path $root $p.largeImg)
        Write-Host "  Files exist: Small=$sExists, Med=$mExists, Large=$lExists"
    }
}

Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
