$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$productsHtml = (Resolve-Path "products.html").Path
$content = [System.IO.File]::ReadAllText($productsHtml, [System.Text.Encoding]::UTF8)

$inspectScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const leaves = [];
        document.querySelectorAll('*').forEach(el => {
            if (el.children.length === 0 && (el.offsetWidth > 360 || el.scrollWidth > 360)) {
                leaves.push({
                    tag: el.tagName,
                    class: (el.className && typeof el.className === 'string') ? el.className : '',
                    id: el.id,
                    text: el.textContent.trim().substring(0, 30),
                    w: el.offsetWidth,
                    sw: el.scrollWidth,
                    parent: el.parentElement ? (el.parentElement.className || el.parentElement.tagName) : ''
                });
            }
        });
        
        const out = document.createElement('div');
        out.id = 'measureOutput';
        out.textContent = JSON.stringify(leaves.slice(0, 20));
        document.body.appendChild(out);
    }, 1500);
});
</script>
"@

$testHtml = Join-Path (Get-Location).Path "test_inspect_leaves.html"
$injected = $content.Replace('</body>', $inspectScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$encodedUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=3000',
    '--window-size=360,1000',
    '--dump-dom',
    $encodedUrl
) -NoNewWindow -PassThru -RedirectStandardOutput "scratch/leaves_dom.txt"

$proc.WaitForExit(10000)

$dom = Get-Content "scratch/leaves_dom.txt" -Raw
if ($dom -match '<div id="measureOutput">(.*?)</div>') {
    Write-Host "LEAVES: $($matches[1])"
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
