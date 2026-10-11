$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$indexHtml = Join-Path $root 'index.html'

$script = @'
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const info = {
            innerWidth: window.innerWidth,
            clientWidth: document.documentElement.clientWidth,
            scrollWidth: document.body.scrollWidth,
            containerWidth: document.querySelector('.container')?.getBoundingClientRect().width,
            rowWidth: document.querySelector('.row')?.getBoundingClientRect().width,
            cardWidth: document.querySelector('.material-card')?.getBoundingClientRect().width,
            colWidth: document.querySelector('.col-lg')?.getBoundingClientRect().width
        };
        const el = document.createElement('div');
        el.id = 'VIEWPORT_DEBUG_INFO';
        el.textContent = JSON.stringify(info, null, 2);
        document.body.appendChild(el);
    }, 500);
});
</script>
'@

$testHtml = Join-Path $root 'test_viewport.html'
$content = [System.IO.File]::ReadAllText($indexHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $script + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$testLog = Join-Path $root 'scratch\viewport_out.txt'
& $edge --headless=new --window-size="375,800" --virtual-time-budget=2000 --dump-dom $url | Out-File $testLog -Encoding utf8
$res = Get-Content $testLog -Raw
if ($res -match '<div id="VIEWPORT_DEBUG_INFO">([\s\S]*?)</div>') {
    Write-Host $matches[1]
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
