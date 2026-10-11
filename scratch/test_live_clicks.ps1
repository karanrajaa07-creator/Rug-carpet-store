$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

$htmlFile = Join-Path $root "product-details.html"
$content = [System.IO.File]::ReadAllText($htmlFile, [System.Text.Encoding]::UTF8)

# Inject immediate test runner script
$injectedScript = @"
<script>
window.addEventListener('load', function() {
  const log = [];
  try {
    const mainImg = document.getElementById('mainProductImage');
    log.push({ step: 'initial', src: mainImg ? mainImg.src : null });

    // Test clicking Small
    const smallBtn = document.getElementById('sizeBtn-small') || document.querySelector('button[data-tier="small"]');
    if (smallBtn) {
      smallBtn.click();
      log.push({ step: 'after_small_click', src: mainImg ? mainImg.src : null, activeBtn: document.querySelector('.size-pill.active') ? document.querySelector('.size-pill.active').getAttribute('data-tier') : null });
    } else {
      log.push({ step: 'small_btn_missing' });
    }

    // Test clicking Large
    const largeBtn = document.getElementById('sizeBtn-large') || document.querySelector('button[data-tier="large"]');
    if (largeBtn) {
      largeBtn.click();
      log.push({ step: 'after_large_click', src: mainImg ? mainImg.src : null, activeBtn: document.querySelector('.size-pill.active') ? document.querySelector('.size-pill.active').getAttribute('data-tier') : null });
    } else {
      log.push({ step: 'large_btn_missing' });
    }

    // Test clicking Medium
    const medBtn = document.getElementById('sizeBtn-medium') || document.querySelector('button[data-tier="medium"]');
    if (medBtn) {
      medBtn.click();
      log.push({ step: 'after_med_click', src: mainImg ? mainImg.src : null, activeBtn: document.querySelector('.size-pill.active') ? document.querySelector('.size-pill.active').getAttribute('data-tier') : null });
    } else {
      log.push({ step: 'med_btn_missing' });
    }
  } catch (err) {
    log.push({ step: 'error', message: err.message, stack: err.stack });
  }

  const resDiv = document.createElement('div');
  resDiv.id = 'CLICK_TEST_RESULT';
  resDiv.textContent = JSON.stringify(log);
  document.body.appendChild(resDiv);
});
</script>
"@

$testHtml = Join-Path $root "scratch\test_live_pd.html"
$injectedContent = $content.Replace('</body>', $injectedScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injectedContent, [System.Text.Encoding]::UTF8)

$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=4"
$outFile = Join-Path $root "scratch\test_live_pd_out.txt"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=5000',
    '--dump-dom',
    $url
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)
$res = Get-Content $outFile -Raw
if ($res -match '<div id="CLICK_TEST_RESULT">(.*?)</div>') {
    Write-Output "RESULT: $($matches[1])"
} else {
    Write-Output "CLICK_TEST_RESULT not found in output"
}
