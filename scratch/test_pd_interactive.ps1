$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$pdPath = (Join-Path $root "product-details.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$url = "file:///" + $pdPath + "?id=1"

# Test with Edge DevTools or console logging
$testRunnerJs = @"
(function() {
  window.addEventListener('load', () => {
    setTimeout(() => {
      console.log('--- STARTING INTERACTION TEST ---');
      const mainImg = document.getElementById('mainProductImage');
      console.log('Initial main image: ' + (mainImg ? mainImg.src : 'null'));

      const smallBtn = document.getElementById('sizeBtn-small');
      console.log('Small button found: ' + !!smallBtn);
      if (smallBtn) {
        smallBtn.click();
        console.log('After Small click, main image: ' + (mainImg ? mainImg.src : 'null'));
      }

      const largeBtn = document.getElementById('sizeBtn-large');
      console.log('Large button found: ' + !!largeBtn);
      if (largeBtn) {
        largeBtn.click();
        console.log('After Large click, main image: ' + (mainImg ? mainImg.src : 'null'));
      }

      const medBtn = document.getElementById('sizeBtn-medium');
      console.log('Medium button found: ' + !!medBtn);
      if (medBtn) {
        medBtn.click();
        console.log('After Medium click, main image: ' + (mainImg ? mainImg.src : 'null'));
      }
      console.log('--- END INTERACTION TEST ---');
    }, 500);
  });
})();
"@

# Let's create test_pd_interactive.html in the ROOT so all relative paths work
$content = [System.IO.File]::ReadAllText((Join-Path $root "product-details.html"), [System.Text.Encoding]::UTF8)
$injected = $content.Replace('</body>', "<script>$testRunnerJs</script></body>")
$testHtml = Join-Path $root "test_pd_interactive.html"
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)

$urlInteractive = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=1"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--enable-logging',
    '--v=1',
    '--virtual-time-budget=6000',
    '--dump-dom',
    $urlInteractive
) -NoNewWindow -PassThru -RedirectStandardOutput (Join-Path $root "scratch\test_pd_interactive_dom.txt") -RedirectStandardError (Join-Path $root "scratch\test_pd_interactive_err.txt")

$proc.WaitForExit(10000)

Write-Output "Exit code: $($proc.ExitCode)"
if (Test-Path (Join-Path $root "scratch\test_pd_interactive_err.txt")) {
    $errs = Get-Content (Join-Path $root "scratch\test_pd_interactive_err.txt") -Raw
    Write-Output "Errors/Console length: $($errs.Length)"
    # Filter for console logs
    $lines = $errs -split "`n" | Where-Object { $_ -match 'INTERACTION TEST|Initial main image|After Small click|After Large click|After Medium click|Error|Exception' }
    $lines | ForEach-Object { Write-Output $_ }
}
