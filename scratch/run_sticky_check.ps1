$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

# Let's create an index copy with script injected at end of body that scrolls after load and reports rect
$indexContent = Get-Content "index.html" -Raw

$injectScript = @"
<script>
window.addEventListener('load', () => {
  setTimeout(() => {
    const header = document.querySelector('.site-header');
    const r0 = header.getBoundingClientRect();
    window.scrollTo(0, 700);
    setTimeout(() => {
      const r1 = header.getBoundingClientRect();
      const st = window.getComputedStyle(header);
      const bst = window.getComputedStyle(document.body);
      const hst = window.getComputedStyle(document.documentElement);
      const d = document.createElement('div');
      d.id = 'sticky-test-result';
      d.setAttribute('data-scroll-y', window.scrollY);
      d.setAttribute('data-top-before', r0.top);
      d.setAttribute('data-top-after', r1.top);
      d.setAttribute('data-position', st.position);
      d.setAttribute('data-top', st.top);
      d.setAttribute('data-zindex', st.zIndex);
      d.setAttribute('data-body-overflow-x', bst.overflowX);
      d.setAttribute('data-html-overflow-x', hst.overflowX);
      document.body.appendChild(d);
    }, 400);
  }, 200);
});
</script>
"@

$testIndex = $indexContent -replace '</body>', "$injectScript`n</body>"
Set-Content -Path "scratch/test_sticky_page.html" -Value $testIndex -Encoding utf8

$fileUrl = "http://localhost:8080/scratch/test_sticky_page.html"
$outPng = "C:\Users\Karan\.gemini\antigravity-ide\brain\1238d468-beab-4358-a7b9-a2f6826e8741\scrolled_page_capture.png"
$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--screenshot=$outPng", "--window-size=1280,1000", "--dump-dom", $fileUrl -NoNewWindow -PassThru -RedirectStandardOutput "scratch/sticky_dom_dump.txt"
$proc.WaitForExit(10000)

$content = Get-Content "scratch/sticky_dom_dump.txt" -Raw
if ($content -match '<div id="sticky-test-result"[^>]*>') {
    Write-Host "FOUND RESULT TAG: $($matches[0])"
} else {
    Write-Host "No result tag found"
}
