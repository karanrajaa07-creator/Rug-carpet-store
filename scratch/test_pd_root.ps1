$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

$htmlFile = Join-Path $root "product-details.html"
$content = [System.IO.File]::ReadAllText($htmlFile, [System.Text.Encoding]::UTF8)

# Inject test script
$injectedScript = @"
<script>
window.addEventListener('load', function() {
  const log = [];
  try {
    const mainImg = document.getElementById('mainProductImage');
    log.push({ step: 'initial', src: mainImg ? mainImg.src : null });

    // Click Small
    const smallBtn = document.getElementById('sizeBtn-small');
    if (smallBtn) {
      smallBtn.click();
      log.push({ step: 'after_small', src: mainImg ? mainImg.src : null, activePill: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier') });
    }

    // Click Large
    const largeBtn = document.getElementById('sizeBtn-large');
    if (largeBtn) {
      largeBtn.click();
      log.push({ step: 'after_large', src: mainImg ? mainImg.src : null, activePill: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier') });
    }

    // Click Medium
    const medBtn = document.getElementById('sizeBtn-medium');
    if (medBtn) {
      medBtn.click();
      log.push({ step: 'after_medium', src: mainImg ? mainImg.src : null, activePill: document.querySelector('#pdSizeOptions .size-pill.active')?.getAttribute('data-tier') });
    }
  } catch (err) {
    log.push({ step: 'error', message: err.message, stack: err.stack });
  }

  const resDiv = document.createElement('div');
  resDiv.id = 'PD_ROOT_TEST_RESULT';
  resDiv.textContent = JSON.stringify(log);
  document.body.appendChild(resDiv);
});
</script>
"@

$testHtml = Join-Path $root "test_pd_root2.html"
$injectedContent = $content.Replace('</body>', $injectedScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injectedContent, [System.Text.Encoding]::UTF8)

$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=4"
$outFile = Join-Path $root "scratch\test_pd_root2_out.txt"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=5000',
    '--dump-dom',
    $url
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)
$res = Get-Content $outFile -Raw
if ($res -match '<div id="PD_ROOT_TEST_RESULT">(.*?)</div>') {
    Write-Output "ROOT_RESULT: $($matches[1])"
} else {
    Write-Output "PD_ROOT_TEST_RESULT not found in output"
}

Remove-Item $testHtml -ErrorAction SilentlyContinue
