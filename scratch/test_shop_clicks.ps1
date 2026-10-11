$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$prodPath = (Join-Path $root "products.html")
$content = [System.IO.File]::ReadAllText($prodPath, [System.Text.Encoding]::UTF8)

$testScript = @"
<script>
window.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    const results = [];
    const p1Img = document.getElementById('cardImg-1');
    const p1SmallBtn = document.querySelector('#cardSizePills-1 button[data-tier="small"]');
    const p1LargeBtn = document.querySelector('#cardSizePills-1 button[data-tier="large"]');
    const p1MedBtn = document.querySelector('#cardSizePills-1 button[data-tier="medium"]');

    results.push({
      step: 'initial',
      imgSrc: p1Img ? p1Img.src : null,
      activePill: document.querySelector('#cardSizePills-1 .card-size-pill.active')?.getAttribute('data-tier')
    });

    if (p1SmallBtn) {
      p1SmallBtn.click();
      results.push({
        step: 'after_small_click',
        imgSrc: p1Img ? p1Img.src : null,
        activePill: document.querySelector('#cardSizePills-1 .card-size-pill.active')?.getAttribute('data-tier')
      });
    }

    if (p1LargeBtn) {
      p1LargeBtn.click();
      results.push({
        step: 'after_large_click',
        imgSrc: p1Img ? p1Img.src : null,
        activePill: document.querySelector('#cardSizePills-1 .card-size-pill.active')?.getAttribute('data-tier')
      });
    }

    if (p1MedBtn) {
      p1MedBtn.click();
      results.push({
        step: 'after_med_click',
        imgSrc: p1Img ? p1Img.src : null,
        activePill: document.querySelector('#cardSizePills-1 .card-size-pill.active')?.getAttribute('data-tier')
      });
    }

    const outDiv = document.createElement('div');
    outDiv.id = 'SHOP_RESULTS_OUTPUT';
    outDiv.textContent = JSON.stringify(results);
    document.body.appendChild(outDiv);
  }, 300);
});
</script>
"@

$injected = $content.Replace('</body>', $testScript + '</body>')
$testHtml = Join-Path $root "test_shop_run.html"
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)

$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$outFile = Join-Path $root "scratch\test_shop_output.txt"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=4000',
    '--dump-dom',
    $url
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)

$dom = Get-Content $outFile -Raw
if ($dom -match '<div id="SHOP_RESULTS_OUTPUT">(.*?)</div>') {
    Write-Output "SHOP RESULTS: $($matches[1])"
} else {
    Write-Output "SHOP_RESULTS_OUTPUT not found"
}

Remove-Item $testHtml -ErrorAction SilentlyContinue
