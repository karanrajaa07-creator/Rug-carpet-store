$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$content = Get-Content 'index.html' -Raw
$debugScript = @'
<script>
window.addEventListener('load', () => {
  setTimeout(() => {
    const docW = document.documentElement.clientWidth;
    console.error('DEBUG_INFO: DOC_CLIENT_WIDTH=' + docW + ' BODY_SCROLL_WIDTH=' + document.body.scrollWidth);
    const bad = [];
    document.querySelectorAll('*').forEach(el => {
      const r = el.getBoundingClientRect();
      if (r.right > docW + 2) {
        bad.push({
          tag: el.tagName,
          id: el.id,
          cls: (el.className || '').toString().substring(0, 40),
          right: Math.round(r.right),
          width: Math.round(r.width)
        });
      }
    });
    console.error('DEBUG_INFO: BAD_COUNT=' + bad.length);
    console.error('DEBUG_INFO: BAD_LIST=' + JSON.stringify(bad.slice(0, 15)));
  }, 500);
});
</script>
</body>
'@

$newContent = $content -replace '</body>', $debugScript
Set-Content -Path 'temp_debug_root.html' -Value $newContent -Encoding UTF8

$errLog = 'C:\Users\Karan\edge_err.log'
if (Test-Path $errLog) { Remove-Item $errLog -Force }

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=3000',
    '--window-size=360,800',
    '--enable-logging=stderr',
    'file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/temp_debug_root.html'
) -NoNewWindow -Wait -RedirectStandardError $errLog

Remove-Item 'temp_debug_root.html' -Force

if (Test-Path $errLog) {
    Get-Content $errLog | Select-String 'DEBUG_INFO' | ForEach-Object { Write-Host $_ }
}
