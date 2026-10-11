$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$prodUrl = "file:///" + (Join-Path $root "products.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$testHtml = Join-Path $root "test_click_runner.html"
$htmlContent = [System.IO.File]::ReadAllText((Join-Path $root "products.html"), [System.Text.Encoding]::UTF8)

$clickScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const results = [];
        // Test clicking Small on product 4 (Oushak runner)
        const p4SmallBtn = document.querySelector('#cardSizePills-4 button[data-tier="small"]');
        const p4ImgBefore = document.getElementById('cardImg-4') ? document.getElementById('cardImg-4').src : 'none';
        
        results.push({ test: 'Before click P4', src: p4ImgBefore });
        
        if (p4SmallBtn) {
            p4SmallBtn.click();
            setTimeout(() => {
                const p4ImgAfterSmall = document.getElementById('cardImg-4').src;
                results.push({ test: 'After small click P4', src: p4ImgAfterSmall, changed: (p4ImgAfterSmall !== p4ImgBefore) });
                
                const p4LargeBtn = document.querySelector('#cardSizePills-4 button[data-tier="large"]');
                p4LargeBtn.click();
                setTimeout(() => {
                    const p4ImgAfterLarge = document.getElementById('cardImg-4').src;
                    results.push({ test: 'After large click P4', src: p4ImgAfterLarge, changed: (p4ImgAfterLarge !== p4ImgAfterSmall) });
                    
                    const out = document.createElement('div');
                    out.id = 'clickResultsOutput';
                    out.textContent = JSON.stringify(results);
                    document.body.appendChild(out);
                }, 300);
            }, 300);
        } else {
            results.push({ error: 'p4SmallBtn not found' });
            const out = document.createElement('div');
            out.id = 'clickResultsOutput';
            out.textContent = JSON.stringify(results);
            document.body.appendChild(out);
        }
    }, 1000);
});
</script>
"@

$injected = $htmlContent.Replace('</body>', $clickScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$testUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$outFile = Join-Path $root "scratch\click_test_dom.txt"
$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=4000',
    '--dump-dom',
    $testUrl
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)
$dom = Get-Content $outFile -Raw
if ($dom -match '<div id="clickResultsOutput">(.*?)</div>') {
    Write-Host "RESULTS: $($matches[1])"
} else {
    Write-Host "Output div not found in DOM."
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
