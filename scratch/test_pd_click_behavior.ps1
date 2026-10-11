$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"
$testHtml = Join-Path $root "test_pd_click_behavior.html"
$testLog = Join-Path $scratch "test_pd_click_behavior.txt"

# Read product-details.html
$content = [System.IO.File]::ReadAllText((Join-Path $root "product-details.html"), [System.Text.Encoding]::UTF8)

# Inject test script right before </body>
$testScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const results = {};
        const img = document.getElementById('mainProductImage');
        results.initialSrc = img ? img.src : null;

        // Click Small
        const smallBtn = document.getElementById('sizeBtn-small');
        if (smallBtn) smallBtn.click();
        results.afterSmallClickSrc = img ? img.src : null;

        // Click Large
        const largeBtn = document.getElementById('sizeBtn-large');
        if (largeBtn) largeBtn.click();
        results.afterLargeClickSrc = img ? img.src : null;

        // Click Medium
        const medBtn = document.getElementById('sizeBtn-medium');
        if (medBtn) medBtn.click();
        results.afterMediumClickSrc = img ? img.src : null;

        // Test scale bar
        const scaleSmall = document.getElementById('scaleBtn-small');
        if (scaleSmall) scaleSmall.click();
        results.afterScaleSmallSrc = img ? img.src : null;

        // Test thumb card
        const thumbLarge = document.getElementById('dimThumbCard-large');
        if (thumbLarge) thumbLarge.click();
        results.afterThumbLargeSrc = img ? img.src : null;

        const out = document.createElement('div');
        out.id = 'CLICK_RESULTS';
        out.textContent = JSON.stringify(results);
        document.body.appendChild(out);
    }, 500);
});
</script>
"@

[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $testScript + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --virtual-time-budget=3000 --dump-dom $url | Out-File $testLog -Encoding utf8
$dom = Get-Content $testLog -Raw
if ($dom -match '<div id="CLICK_RESULTS">(.*?)</div>') {
    Write-Host "PD Click Results: $($matches[1])"
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
