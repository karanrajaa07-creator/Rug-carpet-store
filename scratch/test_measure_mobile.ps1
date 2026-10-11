$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

$measureScript = @"
<script>
window.addEventListener('load', function() {
  const cards = Array.from(document.querySelectorAll('.material-card'));
  const data = cards.map((c, i) => {
    const r = c.getBoundingClientRect();
    const title = c.querySelector('h5')?.textContent.trim();
    return { index: i, title: title, width: Math.round(r.width), height: Math.round(r.height), top: Math.round(r.top) };
  });
  const out = document.createElement('div');
  out.id = 'MATERIAL_MOBILE_OUTPUT';
  out.textContent = JSON.stringify(data);
  document.body.appendChild(out);
});
</script>
"@

$homeContent = [System.IO.File]::ReadAllText((Join-Path $root "index.html"), [System.Text.Encoding]::UTF8)
$injectedHome = $homeContent.Replace('</body>', $measureScript + '</body>')
$testHomeHtml = Join-Path $root "test_measure_mobile.html"
[System.IO.File]::WriteAllText($testHomeHtml, $injectedHome, [System.Text.Encoding]::UTF8)
$testHomeUrl = "file:///" + $testHomeHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$outF = Join-Path $root "scratch\measure_mobile_out.txt"
& $edge --headless=new --window-size="375,667" --virtual-time-budget=3000 --dump-dom $testHomeUrl | Out-File -FilePath $outF -Encoding utf8
$content = Get-Content $outF -Raw
if ($content -match '<div id="MATERIAL_MOBILE_OUTPUT">(.*?)</div>') {
    Write-Output "MEASURE_MOBILE: $($matches[1])"
}
Remove-Item $testHomeHtml -ErrorAction SilentlyContinue
