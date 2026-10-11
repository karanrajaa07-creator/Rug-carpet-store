$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

$testHtml = @'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="../assets/css/style.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <style>
    body { height: 3000px; margin: 0; padding: 0; }
  </style>
</head>
<body>
  <header class="site-header sticky-top">
    <div style="height: 60px; background: gold;">NAVBAR CONTENT</div>
  </header>
  <div style="height: 2000px; background: #eee;">CONTENT</div>
  <script>
    window.scrollTo(0, 500);
    const header = document.querySelector('.site-header');
    const rect = header.getBoundingClientRect();
    const st = window.getComputedStyle(header);
    const res = document.createElement('div');
    res.id = 'sticky-rect';
    res.textContent = JSON.stringify({
      scrollY: window.scrollY,
      rectTop: rect.top,
      rectY: rect.y,
      position: st.position,
      top: st.top,
      isSticky: rect.top === 0
    });
    document.body.appendChild(res);
  </script>
</body>
</html>
'@

Set-Content -Path "scratch/test_isolated_sticky.html" -Value $testHtml -Encoding utf8

$fileUrl = "http://localhost:8080/scratch/test_isolated_sticky.html"
$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--dump-dom", "--window-size=1280,800", $fileUrl -NoNewWindow -PassThru -RedirectStandardOutput "scratch/isolated_dom.txt"
$proc.WaitForExit(10000)

$content = Get-Content "scratch/isolated_dom.txt" -Raw
if ($content -match '<div id="sticky-rect">(.*?)</div>') {
    Write-Host "ISOLATED STICKY RESULT: $($matches[1])"
}
