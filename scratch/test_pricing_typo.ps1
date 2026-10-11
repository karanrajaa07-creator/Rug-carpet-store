$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$testHtml = Join-Path $root "test_pricing_typo.html"
$htmlContent = [System.IO.File]::ReadAllText((Join-Path $root "pricing.html"), [System.Text.Encoding]::UTF8)

$inspectScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const card = document.querySelector('.pricing-card.is-popular');
        const items = [];
        if (card) {
            // Traverse all elements with text
            const all = card.querySelectorAll('*');
            all.forEach(el => {
                if (el.children.length === 0 || el.classList.contains('pricing-price')) {
                    const cs = window.getComputedStyle(el);
                    items.push({
                        tag: el.tagName,
                        classes: el.className,
                        text: el.innerText.trim(),
                        fontFamily: cs.fontFamily,
                        fontSize: cs.fontSize,
                        fontWeight: cs.fontWeight,
                        lineHeight: cs.lineHeight,
                        letterSpacing: cs.letterSpacing,
                        fontStyle: cs.fontStyle,
                        color: cs.color
                    });
                }
            });
        }
        const out = document.createElement('div');
        out.id = 'typoOutput';
        out.textContent = JSON.stringify(items, null, 2);
        document.body.appendChild(out);
    }, 1000);
});
</script>
"@

$injected = $htmlContent.Replace('</body>', $inspectScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$testUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$outFile = Join-Path $root "scratch\pricing_typo_dom.txt"
$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=3000',
    '--dump-dom',
    $testUrl
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)
$dom = Get-Content $outFile -Raw
if ($dom -match '<div id="typoOutput">(.*?)</div>') {
    Write-Host "TYPO: $($matches[1])"
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
