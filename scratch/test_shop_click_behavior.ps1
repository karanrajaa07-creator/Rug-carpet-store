$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"
$testHtml = Join-Path $root "test_shop_click_behavior.html"
$testLog = Join-Path $scratch "test_shop_click_behavior.txt"

# Read products.html
$content = [System.IO.File]::ReadAllText((Join-Path $root "products.html"), [System.Text.Encoding]::UTF8)

# Inject test script right before </body>
$testScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const results = [];
        // Test first 3 products on products.html
        [1, 2, 3].forEach(id => {
            const img = document.getElementById('cardImg-' + id);
            const r = { id: id };
            r.initialSrc = img ? img.src : null;

            // Find Small pill
            const pills = document.querySelectorAll('#cardSizePills-' + id + ' .card-size-pill');
            let smallPill, medPill, largePill;
            pills.forEach(p => {
                if (p.getAttribute('data-tier') === 'small') smallPill = p;
                if (p.getAttribute('data-tier') === 'medium') medPill = p;
                if (p.getAttribute('data-tier') === 'large') largePill = p;
            });

            if (smallPill) smallPill.click();
            r.afterSmallSrc = img ? img.src : null;

            if (largePill) largePill.click();
            r.afterLargeSrc = img ? img.src : null;

            if (medPill) medPill.click();
            r.afterMedSrc = img ? img.src : null;

            results.push(r);
        });

        const out = document.createElement('div');
        out.id = 'SHOP_CLICK_RESULTS';
        out.textContent = JSON.stringify(results);
        document.body.appendChild(out);
    }, 1000);
});
</script>
"@

[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $testScript + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --virtual-time-budget=3000 --dump-dom $url | Out-File $testLog -Encoding utf8
$dom = Get-Content $testLog -Raw
if ($dom -match '<div id="SHOP_CLICK_RESULTS">(.*?)</div>') {
    Write-Host "Shop Click Results: $($matches[1])"
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
