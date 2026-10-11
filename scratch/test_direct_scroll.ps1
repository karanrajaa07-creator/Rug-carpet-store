$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$out0 = "C:\Users\Karan\.gemini\antigravity-ide\brain\1238d468-beab-4358-a7b9-a2f6826e8741\scroll_pos_0.png"
$out600 = "C:\Users\Karan\.gemini\antigravity-ide\brain\1238d468-beab-4358-a7b9-a2f6826e8741\scroll_pos_600.png"

# Inject small test script to scroll and check rect
$testHtml = @'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Scroll Test</title>
</head>
<body>
  <div id="status">Loading...</div>
  <script>
    fetch('http://localhost:8080/index.html')
      .then(r => r.text())
      .then(html => {
        document.open();
        document.write(html);
        document.close();
        setTimeout(() => {
          const header = document.querySelector('.site-header');
          const r0 = header ? header.getBoundingClientRect() : null;
          window.scrollTo(0, 800);
          setTimeout(() => {
            const r1 = header ? header.getBoundingClientRect() : null;
            const log = document.createElement('div');
            log.id = 'scroll-diag';
            log.style.cssText = 'position:fixed;bottom:10px;left:10px;background:white;color:black;padding:10px;z-index:99999;font-size:16px;border:2px solid red;';
            log.textContent = JSON.stringify({
              scrollY: window.scrollY,
              beforeScrollTop: r0 ? r0.top : null,
              afterScrollTop: r1 ? r1.top : null,
              headerPosition: window.getComputedStyle(header).position,
              headerTop: window.getComputedStyle(header).top,
              bodyOverflow: window.getComputedStyle(document.body).overflow,
              htmlOverflow: window.getComputedStyle(document.documentElement).overflow
            });
            document.body.appendChild(log);
          }, 400);
        }, 500);
      });
  </script>
</body>
</html>
'@
Set-Content -Path 'scratch/direct_scroll_test.html' -Value $testHtml -Encoding utf8

$fileUrl = "http://localhost:8080/scratch/direct_scroll_test.html"
$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--dump-dom", "--screenshot=$out600", "--window-size=1280,1000", $fileUrl -NoNewWindow -PassThru -RedirectStandardOutput "scratch/direct_scroll_out.txt"
$proc.WaitForExit(10000)

$content = Get-Content "scratch/direct_scroll_out.txt" -Raw
if ($content -match '<div id="scroll-diag"[^>]*>(.*?)</div>') {
    Write-Host "DIAG RESULTS: $($matches[1])"
} else {
    Write-Host "No diag found. Length: $($content.Length)"
}
