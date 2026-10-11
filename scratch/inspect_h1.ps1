$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$tempHtml = Join-Path $root 'temp_inspect_h1.html'
$outTxt = Join-Path $root 'scratch\inspect_h1_out.txt'
$html = [System.IO.File]::ReadAllText((Join-Path $root 'products.html'), [System.Text.Encoding]::UTF8)

$inject = @"
<script>
window.addEventListener('load', () => {
    const h1 = document.querySelector('.page-hero-banner h1');
    const banner = document.querySelector('.page-hero-banner');
    const container = document.querySelector('.page-hero-banner > .container');
    const btn = document.querySelector('.page-hero-banner .btn-luxury-outline');
    const res = {
        h1Rect: h1.getBoundingClientRect(),
        h1Lines: h1.getClientRects().length,
        bannerRect: banner.getBoundingClientRect(),
        containerRect: container.getBoundingClientRect(),
        btnRect: btn.getBoundingClientRect(),
        winWidth: window.innerWidth,
        winHeight: window.innerHeight,
        h1HTML: h1.innerHTML
    };
    document.body.setAttribute('data-res', JSON.stringify(res));
});
</script>
"@

$mod = $html.Replace('</body>', $inject + '</body>')
[System.IO.File]::WriteAllText($tempHtml, $mod, [System.Text.Encoding]::UTF8)
$url = 'file:///' + $tempHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2000',
    '--window-size=375,700',
    '--dump-dom',
    $url
) -NoNewWindow -RedirectStandardOutput $outTxt -Wait

$content = [System.IO.File]::ReadAllText($outTxt)
if ($content -match 'data-res="([^"]+)"') {
    Write-Host "RESULT: $($matches[1])"
} else {
    Write-Host "data-res not found"
}
Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
