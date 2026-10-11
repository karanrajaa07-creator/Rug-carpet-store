$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$pdPath = (Join-Path $root "product-details.html")
$content = [System.IO.File]::ReadAllText($pdPath, [System.Text.Encoding]::UTF8)

$testScript = @"
<script>
window.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    const results = [];
    const mainImg = document.getElementById('mainProductImage');

    function record(action) {
      results.push({
        action: action,
        imgSrc: mainImg ? mainImg.src : null,
        activePill: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier'),
        activeScale: document.querySelector('#pdRoomScaleBar .room-scale-btn.active')?.getAttribute('data-tier'),
        activeCard: document.querySelector('#pdThumbnailsRow .dimension-thumb-card.active')?.getAttribute('data-tier')
      });
    }

    record('initial');

    // 1. Click sizeBtn-small
    const smallBtn = document.getElementById('sizeBtn-small');
    if (smallBtn) smallBtn.click();
    record('click_sizeBtn-small');

    // 2. Click sizeBtn-large
    const largeBtn = document.getElementById('sizeBtn-large');
    if (largeBtn) largeBtn.click();
    record('click_sizeBtn-large');

    // 3. Click sizeBtn-medium
    const medBtn = document.getElementById('sizeBtn-medium');
    if (medBtn) medBtn.click();
    record('click_sizeBtn-medium');

    // 4. Click scaleBtn-small
    const scaleSmall = document.getElementById('scaleBtn-small');
    if (scaleSmall) scaleSmall.click();
    record('click_scaleBtn-small');

    // 5. Click dimThumbCard-large
    const thumbLarge = document.getElementById('dimThumbCard-large');
    if (thumbLarge) thumbLarge.click();
    record('click_dimThumbCard-large');

    const outDiv = document.createElement('div');
    outDiv.id = 'TEST_RESULTS_OUTPUT';
    outDiv.textContent = JSON.stringify(results);
    document.body.appendChild(outDiv);
  }, 100);
});
</script>
"@

$injected = $content.Replace('</body>', $testScript + '</body>')
$testHtml = Join-Path $root "test_clicks_run.html"
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)

$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=1"
$outFile = Join-Path $root "scratch\test_clicks_output.txt"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=4000',
    '--dump-dom',
    $url
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)

$dom = Get-Content $outFile -Raw
if ($dom -match '<div id="TEST_RESULTS_OUTPUT">(.*?)</div>') {
    Write-Output "RESULTS: $($matches[1])"
} else {
    Write-Output "TEST_RESULTS_OUTPUT not found"
}

Remove-Item $testHtml -ErrorAction SilentlyContinue
