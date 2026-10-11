$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

$pages = @('index.html', 'products.html', 'services.html', 'about.html', 'contact.html')
$viewports = @(
    @{ name = 'desktop'; width = 1280; height = 900 },
    @{ name = 'tablet';  width = 768;  height = 1024 },
    @{ name = 'mobile';  width = 375;  height = 812 }
)

$results = @()

foreach ($page in $pages) {
    foreach ($vp in $viewports) {
        $testScript = @"
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
</head>
<body style='margin:0;padding:0;'>
  <iframe id='frame' src='http://localhost:8080/$page' style='width:$($vp.width)px;height:$($vp.height)px;border:none;'></iframe>
  <div id='res'></div>
  <script>
    const f = document.getElementById('frame');
    f.onload = () => {
      setTimeout(() => {
        const w = f.contentWindow;
        const d = f.contentDocument;
        const h = d.querySelector('.site-header');
        if (!h) {
          document.getElementById('res').textContent = JSON.stringify({ error: 'No .site-header found' });
          return;
        }
        const topBefore = h.getBoundingClientRect().top;
        w.scrollTo(0, 500);
        setTimeout(() => {
          const topAfter = h.getBoundingClientRect().top;
          const pos = w.getComputedStyle(h).position;
          const isSticky = (topAfter === 0);
          document.getElementById('res').textContent = JSON.stringify({
            page: '$page',
            vp: '$($vp.name)',
            topBefore: topBefore,
            topAfter: topAfter,
            position: pos,
            isSticky: isSticky
          });
        }, 300);
      }, 300);
    };
  </script>
</body>
</html>
"@
        Set-Content -Path "scratch/test_vp.html" -Value $testScript -Encoding utf8
        $dumpFile = "scratch/dump_$($vp.name)_$page.txt"
        $proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--dump-dom", "--window-size=$($vp.width + 50),$($vp.height + 100)", "http://localhost:8080/scratch/test_vp.html" -NoNewWindow -PassThru -RedirectStandardOutput $dumpFile
        $proc.WaitForExit(10000)

        $c = Get-Content $dumpFile -Raw
        if ($c -match '<div id="res">(.*?)</div>') {
            $parsed = $matches[1] | ConvertFrom-Json
            $results += $parsed
            Write-Host "$page [$($vp.name)]: isSticky = $($parsed.isSticky) (topAfter: $($parsed.topAfter), pos: $($parsed.position))"
        } else {
            Write-Host "$page [$($vp.name)]: Could not parse result"
        }
    }
}

Write-Host "=== FINAL STICKY RESULTS ==="
$results | Format-Table -AutoSize
