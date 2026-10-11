$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root 'scratch'

# Create temp CSS that matches HEAD
$headStyle = git show HEAD:assets/css/style.css
$tempCss = Join-Path $scratch 'head_style.css'
[System.IO.File]::WriteAllText($tempCss, $headStyle, [System.Text.Encoding]::UTF8)

# Read debug_index.html (which is HEAD index.html) and replace style.css with head_style.css
$html = [System.IO.File]::ReadAllText((Join-Path $scratch 'debug_index.html'), [System.Text.Encoding]::UTF8)
$html = $html.Replace('assets/css/style.css?v=2.2', 'scratch/head_style.css')
$html = $html.Replace('assets/css/responsive.css?v=2.2', 'assets/css/responsive.css')

$script = @'
<script>
window.addEventListener('load', () => {
    document.querySelectorAll('.reveal-on-scroll, .reveal-stagger').forEach(el => el.classList.add('is-revealed'));
    setTimeout(() => {
        const cards = Array.from(document.querySelectorAll('.material-card'));
        const res = cards.map((c, i) => {
            const r = c.getBoundingClientRect();
            const pr = c.parentElement.getBoundingClientRect();
            return {
                index: i,
                title: c.querySelector('h5')?.innerText.trim(),
                x: Math.round(r.x),
                y: Math.round(r.y),
                width: Math.round(r.width),
                height: Math.round(r.height),
                parentWidth: Math.round(pr.width),
                parentHeight: Math.round(pr.height),
                parentX: Math.round(pr.x),
                parentY: Math.round(pr.y)
            };
        });
        const el = document.createElement('div');
        el.id = 'HEAD_MEASURE_RES';
        el.textContent = JSON.stringify(res, null, 2);
        document.body.appendChild(el);
    }, 500);
});
</script>
'@

$testHtml = Join-Path $scratch 'test_measure_head.html'
[System.IO.File]::WriteAllText($testHtml, $html.Replace('</body>', $script + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

foreach ($w in @(1440, 1280, 1024, 992, 768, 576, 375)) {
    $outFile = Join-Path $scratch "head_res_$w.txt"
    & $edge --headless=new --window-size="$w,1200" --virtual-time-budget=3000 --dump-dom $url | Out-File $outFile -Encoding utf8
    $res = Get-Content $outFile -Raw
    if ($res -match '<div id="HEAD_MEASURE_RES">([\s\S]*?)</div>') {
        Write-Host "=== HEAD WIDTH $w ==="
        $matches[1] | ConvertFrom-Json | Format-Table -AutoSize | Out-String | Write-Host
    }
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $tempCss -ErrorAction SilentlyContinue
