$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

Write-Host "Verifying all 6 items..."

# 1. Measure Home Page Material cards
$testHtml = Join-Path $root "test_measure_home.html"
$content = [System.IO.File]::ReadAllText((Join-Path $root "index.html"), [System.Text.Encoding]::UTF8)
$script = @"
<script>
window.addEventListener('load', () => {
    const cards = Array.from(document.querySelectorAll('.material-card'));
    const res = cards.map(c => ({
        title: c.querySelector('h5')?.innerText.trim(),
        width: Math.round(c.getBoundingClientRect().width),
        height: Math.round(c.getBoundingClientRect().height),
        top: Math.round(c.getBoundingClientRect().top)
    }));
    const el = document.createElement('div');
    el.id = 'MAT_RES';
    el.textContent = JSON.stringify(res);
    document.body.appendChild(el);
});
</script>
"@
[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $script + '</body>'), [System.Text.Encoding]::UTF8)
$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$outMat = Join-Path $root "scratch\verify_final_mat.txt"

& $edge --headless=new --window-size="1280,800" --virtual-time-budget=3000 --dump-dom $url | Out-File $outMat -Encoding utf8
$res1 = Get-Content $outMat -Raw
if ($res1 -match '<div id="MAT_RES">(.*?)</div>') {
    Write-Host "Item 1 Material Cards (1280px): $($matches[1])"
}
Remove-Item $testHtml -ErrorAction SilentlyContinue

# 2. Check Size Clicks on Details Page
$testPd = Join-Path $root "test_pd_final.html"
$pdContent = [System.IO.File]::ReadAllText((Join-Path $root "product-details.html"), [System.Text.Encoding]::UTF8)
$pdScript = @"
<script>
window.addEventListener('load', () => {
    const mainImg = document.getElementById('mainProductImage');
    const log = [];
    log.push({ step: 'init', src: mainImg ? mainImg.src.split('/').pop() : '' });
    
    document.getElementById('sizeBtn-small')?.click();
    log.push({ step: 'small', src: mainImg ? mainImg.src.split('/').pop() : '', active: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier') });
    
    document.getElementById('sizeBtn-large')?.click();
    log.push({ step: 'large', src: mainImg ? mainImg.src.split('/').pop() : '', active: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier') });
    
    document.getElementById('sizeBtn-medium')?.click();
    log.push({ step: 'medium', src: mainImg ? mainImg.src.split('/').pop() : '', active: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier') });
    
    const el = document.createElement('div');
    el.id = 'PD_RES';
    el.textContent = JSON.stringify(log);
    document.body.appendChild(el);
});
</script>
"@
[System.IO.File]::WriteAllText($testPd, $pdContent.Replace('</body>', $pdScript + '</body>'), [System.Text.Encoding]::UTF8)
$pdUrl = "file:///" + $testPd.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=4"
$outPd = Join-Path $root "scratch\verify_final_pd.txt"

& $edge --headless=new --window-size="1280,800" --virtual-time-budget=3000 --dump-dom $pdUrl | Out-File $outPd -Encoding utf8
$res2 = Get-Content $outPd -Raw
if ($res2 -match '<div id="PD_RES">(.*?)</div>') {
    Write-Host "Item 4 Size Clicks: $($matches[1])"
}
Remove-Item $testPd -ErrorAction SilentlyContinue

# 3. Check Pricing Typography
$testPricing = Join-Path $root "test_pricing_final.html"
$pricingContent = [System.IO.File]::ReadAllText((Join-Path $root "pricing.html"), [System.Text.Encoding]::UTF8)
$prScript = @"
<script>
window.addEventListener('load', () => {
    const card = document.querySelector('.pricing-card.is-popular');
    const items = Array.from(card.querySelectorAll('.pricing-feature-item'));
    const res = items.map((it, idx) => ({
        index: idx + 1,
        text: it.innerText.trim(),
        hasStrong: !!it.querySelector('strong'),
        fontWeight: window.getComputedStyle(it).fontWeight,
        fontFamily: window.getComputedStyle(it).fontFamily
    }));
    const el = document.createElement('div');
    el.id = 'PR_RES';
    el.textContent = JSON.stringify(res);
    document.body.appendChild(el);
});
</script>
"@
[System.IO.File]::WriteAllText($testPricing, $pricingContent.Replace('</body>', $prScript + '</body>'), [System.Text.Encoding]::UTF8)
$prUrl = "file:///" + $testPricing.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$outPr = Join-Path $root "scratch\verify_final_pr.txt"

& $edge --headless=new --window-size="1280,800" --virtual-time-budget=3000 --dump-dom $prUrl | Out-File $outPr -Encoding utf8
$res3 = Get-Content $outPr -Raw
if ($res3 -match '<div id="PR_RES">(.*?)</div>') {
    Write-Host "Item 6 Pricing Feature Items: $($matches[1])"
}
Remove-Item $testPricing -ErrorAction SilentlyContinue

Write-Host "ALL VERIFICATION COMPLETE."
