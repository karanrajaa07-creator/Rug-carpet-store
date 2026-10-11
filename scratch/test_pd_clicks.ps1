$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

$testHtml = Join-Path $root "test_pd_click_runner.html"
$htmlContent = [System.IO.File]::ReadAllText((Join-Path $root "product-details.html"), [System.Text.Encoding]::UTF8)

$clickScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const results = [];
        const mainImgBefore = document.getElementById('mainProductImage') ? document.getElementById('mainProductImage').src : 'none';
        results.push({ test: 'PD Before click', src: mainImgBefore, tier: window.currentSelectedTier });
        
        // Find small button in pdSizeOptions
        const smallBtn = document.querySelector('#pdSizeOptions button[data-tier="small"]');
        if (smallBtn) {
            smallBtn.click();
            setTimeout(() => {
                const mainImgAfterSmall = document.getElementById('mainProductImage').src;
                results.push({ test: 'PD After small click', src: mainImgAfterSmall, changed: (mainImgAfterSmall !== mainImgBefore), tier: window.currentSelectedTier });
                
                const largeBtn = document.querySelector('#pdSizeOptions button[data-tier="large"]');
                largeBtn.click();
                setTimeout(() => {
                    const mainImgAfterLarge = document.getElementById('mainProductImage').src;
                    results.push({ test: 'PD After large click', src: mainImgAfterLarge, changed: (mainImgAfterLarge !== mainImgAfterSmall), tier: window.currentSelectedTier });
                    
                    const out = document.createElement('div');
                    out.id = 'pdClickResultsOutput';
                    out.textContent = JSON.stringify(results);
                    document.body.appendChild(out);
                }, 300);
            }, 300);
        } else {
            results.push({ error: 'smallBtn not found in #pdSizeOptions' });
            const out = document.createElement('div');
            out.id = 'pdClickResultsOutput';
            out.textContent = JSON.stringify(results);
            document.body.appendChild(out);
        }
    }, 1000);
});
</script>
"@

$injected = $htmlContent.Replace('</body>', $clickScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$testUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=4"

$outFile = Join-Path $root "scratch\pd_click_test_dom.txt"
$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=4000',
    '--dump-dom',
    $testUrl
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)
$dom = Get-Content $outFile -Raw
if ($dom -match '<div id="pdClickResultsOutput">(.*?)</div>') {
    Write-Host "RESULTS: $($matches[1])"
} else {
    Write-Host "Output div not found in DOM."
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
