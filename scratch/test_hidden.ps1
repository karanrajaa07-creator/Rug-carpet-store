$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

$script = @'
<!DOCTYPE html>
<html id="htmlEl" style="overflow-x: hidden;">
<head>
  <style>
    body { margin:0; padding:0; height:3000px; }
    .header { position: sticky; top: 0; height: 60px; background: red; z-index: 100; }
  </style>
</head>
<body id="bodyEl" style="overflow-x: hidden;">
  <div class="header">HEADER</div>
  <div style="height: 2000px;">BODY CONTENT</div>
  <script>
    // Scroll and measure
    window.scrollTo(0, 500);
    const rect = document.querySelector('.header').getBoundingClientRect();
    const result = {
      scrollY: window.scrollY,
      rectTop: rect.top,
      isSticky: rect.top === 0
    };
    const div = document.createElement('div');
    div.id = 'res';
    div.textContent = JSON.stringify(result);
    document.body.appendChild(div);
  </script>
</body>
</html>
'@
Set-Content -Path "scratch/test_clip_behavior.html" -Value $script -Encoding utf8

$fileUrl = "http://localhost:8080/scratch/test_clip_behavior.html"
$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--dump-dom", $fileUrl -NoNewWindow -PassThru -RedirectStandardOutput "scratch/clip_dom.txt"
$proc.WaitForExit(10000)

$content = Get-Content "scratch/clip_dom.txt" -Raw
if ($content -match '<div id="res">(.*?)</div>') {
    Write-Host "HIDDEN BEHAVIOR RESULT: $($matches[1])"
}
