$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$productsHtml = (Resolve-Path "products.html").Path
$content = [System.IO.File]::ReadAllText($productsHtml, [System.Text.Encoding]::UTF8)

$inspectScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const bodyW = document.body.offsetWidth;
        const scrollW = document.documentElement.scrollWidth;
        const card = document.querySelector('.product-card');
        const cardW = card ? card.offsetWidth : 0;
        const col = card ? card.parentElement.offsetWidth : 0;
        const pills = document.querySelector('.card-size-pills');
        const pillsW = pills ? pills.offsetWidth : 0;
        const container = document.querySelector('.container');
        const containerW = container ? container.offsetWidth : 0;
        
        const wideElements = [];
        document.querySelectorAll('*').forEach(el => {
            if (el.scrollWidth > 375) {
                wideElements.push({ tag: el.tagName, class: el.className, id: el.id, scrollW: el.scrollWidth, offsetW: el.offsetWidth });
            }
        });
        
        const out = document.createElement('div');
        out.id = 'measureOutput';
        out.textContent = JSON.stringify({
            bodyW, scrollW, cardW, col, pillsW, containerW, wideCount: wideElements.length, topWide: wideElements.slice(0, 10)
        });
        document.body.appendChild(out);
    }, 1500);
});
</script>
"@

$testHtml = Join-Path (Get-Location).Path "test_inspect_mobile2.html"
$injected = $content.Replace('</body>', $inspectScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$encodedUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=3000',
    '--window-size=375,1000',
    '--dump-dom',
    $encodedUrl
) -NoNewWindow -PassThru -RedirectStandardOutput "scratch/mobile_inspect_dom2.txt"

$proc.WaitForExit(10000)

$dom = Get-Content "scratch/mobile_inspect_dom2.txt" -Raw
if ($dom -match '<div id="measureOutput">(.*?)</div>') {
    Write-Host "MEASURE_RESULT: $($matches[1])"
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
