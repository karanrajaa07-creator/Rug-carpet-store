$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

$pages = @(
    'index.html',
    'products.html',
    'product-details.html?id=4',
    'pricing.html',
    'about.html',
    'services.html',
    'service-details.html',
    'contact.html',
    'blog.html',
    'custom-sizing.html',
    'care-guide.html',
    'wishlist.html'
)

$auditScript = @"
<script>
window.__auditErrors = [];
window.addEventListener('error', function(e) {
  window.__auditErrors.push({ type: 'error', message: e.message, filename: e.filename, lineno: e.lineno });
});
window.addEventListener('unhandledrejection', function(e) {
  window.__auditErrors.push({ type: 'unhandledrejection', reason: String(e.reason) });
});
window.addEventListener('load', function() {
  setTimeout(function() {
    // Check all images
    const brokenImages = [];
    document.querySelectorAll('img').forEach(function(img) {
      if (!img.naturalWidth && img.complete) {
        brokenImages.push(img.src);
      }
    });
    const res = document.createElement('div');
    res.id = 'PAGE_AUDIT_OUTPUT';
    res.textContent = JSON.stringify({ errors: window.__auditErrors, brokenImages: brokenImages });
    document.body.appendChild(res);
  }, 1000);
});
</script>
"@

foreach ($p in $pages) {
    $baseFile = $p.Split('?')[0]
    $query = if ($p.Contains('?')) { "?" + $p.Split('?')[1] } else { "" }
    $content = [System.IO.File]::ReadAllText((Join-Path $root $baseFile), [System.Text.Encoding]::UTF8)
    $testHtmlName = "test_audit_" + $baseFile
    $testHtmlPath = Join-Path $root $testHtmlName
    $injected = $content.Replace('</head>', $auditScript + '</head>')
    [System.IO.File]::WriteAllText($testHtmlPath, $injected, [System.Text.Encoding]::UTF8)

    $url = "file:///" + $testHtmlPath.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + $query
    $outF = Join-Path $root ("scratch\audit_" + $baseFile.Replace('.html','.txt'))
    & $edge --headless=new --window-size="1280,900" --virtual-time-budget=3000 --dump-dom $url | Out-File -FilePath $outF -Encoding utf8
    $resText = Get-Content $outF -Raw
    if ($resText -match '<div id="PAGE_AUDIT_OUTPUT">(.*?)</div>') {
        Write-Host "Audit $p : $($matches[1])"
    } else {
        Write-Host "Audit $p : Result not captured"
    }
    Remove-Item $testHtmlPath -ErrorAction SilentlyContinue
}
