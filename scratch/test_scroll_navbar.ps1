$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url = 'http://localhost:8080/index.html'
$htmlPath = 'scratch/eval_scroll.html'

# Create a test page that loads index.html in an iframe or directly evaluates index.html
$script = @'
<!DOCTYPE html>
<html>
<body>
<iframe id="testFrame" src="http://localhost:8080/index.html" style="width:1280px; height:800px; border:none;"></iframe>
<div id="results"></div>
<script>
window.addEventListener('load', () => {
  const iframe = document.getElementById('testFrame');
  iframe.onload = () => {
    const doc = iframe.contentDocument || iframe.contentWindow.document;
    const win = iframe.contentWindow;
    const header = doc.querySelector('.site-header');
    const initialRect = header.getBoundingClientRect();
    
    win.scrollTo(0, 800);
    setTimeout(() => {
      const scrolledRect = header.getBoundingClientRect();
      const hStyle = win.getComputedStyle(header);
      const bStyle = win.getComputedStyle(doc.body);
      const docStyle = win.getComputedStyle(doc.documentElement);
      
      const res = {
        scrollY: win.scrollY,
        initialTop: initialRect.top,
        scrolledTop: scrolledRect.top,
        headerPosition: hStyle.position,
        headerTop: hStyle.top,
        headerZIndex: hStyle.zIndex,
        bodyOverflowX: bStyle.overflowX,
        bodyOverflowY: bStyle.overflowY,
        htmlOverflowX: docStyle.overflowX,
        htmlOverflowY: docStyle.overflowY
      };
      document.getElementById('results').textContent = JSON.stringify(res);
    }, 500);
  };
});
</script>
</body>
</html>
'@
Set-Content -Path $htmlPath -Value $script -Encoding utf8

$fileUrl = "http://localhost:8080/scratch/eval_scroll.html"
$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--dump-dom", "--window-size=1280,900", $fileUrl -NoNewWindow -PassThru -RedirectStandardOutput "scratch/eval_dom.txt"
$proc.WaitForExit(10000)

$content = Get-Content "scratch/eval_dom.txt" -Raw
if ($content -match '<div id="results">(.*?)</div>') {
    Write-Host "SCROLL EVALUATION RESULT: $($matches[1])"
} else {
    Write-Host "Did not match results div. Content length: $($content.Length)"
}
