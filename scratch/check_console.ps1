$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$indexHtml = Join-Path $root 'products.html'
$url = 'file:///' + $indexHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$testLog = Join-Path $root 'scratch\browser_console_test.txt'

$script = @'
<script>
window.errors = [];
window.addEventListener('error', e => window.errors.push(e.message));
window.addEventListener('load', () => {
    setTimeout(() => {
        const out = document.createElement('div');
        out.id = 'CONSOLE_ERRORS_OUT';
        out.textContent = JSON.stringify(window.errors);
        document.body.appendChild(out);
    }, 1000);
});
</script>
'@

$testHtml = Join-Path $root 'test_console.html'
$content = [System.IO.File]::ReadAllText($indexHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $script + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --window-size="1280,1200" --virtual-time-budget=3000 --dump-dom $url | Out-File $testLog -Encoding utf8
$dom = Get-Content $testLog -Raw
if ($dom -match '<div id="CONSOLE_ERRORS_OUT">(.*?)</div>') {
    Write-Host "Console Errors: $($matches[1])"
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
