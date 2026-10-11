$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$indexHtml = Join-Path $root 'index.html'
$content = [System.IO.File]::ReadAllText($indexHtml, [System.Text.Encoding]::UTF8)

$inspectScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const cards = [];
        document.querySelectorAll('.material-card').forEach((el, i) => {
            const rect = el.getBoundingClientRect();
            const parent = el.parentElement.getBoundingClientRect();
            const cs = window.getComputedStyle(el);
            const pcs = window.getComputedStyle(el.parentElement);
            cards.push({
                index: i,
                title: el.querySelector('h5') ? el.querySelector('h5').innerText : '',
                rect: { x: Math.round(rect.x), y: Math.round(rect.y), width: Math.round(rect.width), height: Math.round(rect.height) },
                parentRect: { x: Math.round(parent.x), y: Math.round(parent.y), width: Math.round(parent.width), height: Math.round(parent.height) },
                classes: el.className,
                parentClasses: el.parentElement.className
            });
        });
        const out = document.createElement('div');
        out.id = 'measureOutput';
        out.textContent = JSON.stringify(cards, null, 2);
        document.body.appendChild(out);
    }, 1000);
});
</script>
"@

$testHtml = Join-Path $root 'test_inspect_materials.html'
$injected = $content.Replace('</body>', $inspectScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$encodedUrl = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

foreach ($w in @(1280, 1024, 768, 576, 360)) {
    Write-Host "=== Width: $w ==="
    $outFile = Join-Path $root ("scratch\materials_dom_$w.txt")
    $proc = Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2000',
        "--window-size=$w,1200",
        '--dump-dom',
        $encodedUrl
    ) -NoNewWindow -PassThru -RedirectStandardOutput $outFile
    $proc.WaitForExit(10000)
    $dom = Get-Content $outFile -Raw
    if ($dom -match '<div id="measureOutput">(.*?)</div>') {
        Write-Host $matches[1]
    }
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
