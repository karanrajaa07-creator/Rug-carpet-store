$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$html = (Resolve-Path index.html).Path
$content = Get-Content $html -Raw
$debugScript = @"
<script>
window.addEventListener('DOMContentLoaded', () => {
    const brand = document.querySelector('.navbar-brand-logo');
    const actions = document.querySelector('.site-header .d-flex.align-items-center.gap-2');
    const toggler = document.querySelector('.navbar-toggler');
    const nav = document.querySelector('.site-header .navbar');
    const info = {
        viewportWidth: window.innerWidth,
        navWidth: nav ? nav.offsetWidth : 0,
        brandWidth: brand ? brand.offsetWidth : 0,
        brandRight: brand ? brand.getBoundingClientRect().right : 0,
        actionsWidth: actions ? actions.offsetWidth : 0,
        actionsLeft: actions ? actions.getBoundingClientRect().left : 0,
        actionsRight: actions ? actions.getBoundingClientRect().right : 0,
        togglerWidth: toggler ? toggler.offsetWidth : 0,
        togglerLeft: toggler ? toggler.getBoundingClientRect().left : 0,
        togglerRight: toggler ? toggler.getBoundingClientRect().right : 0
    };
    const div = document.createElement('div');
    div.id = 'debugResult';
    div.innerText = JSON.stringify(info);
    document.body.appendChild(div);
});
</script>
"@
$injected = $content.Replace('</body>', $debugScript + '</body>')
$tempHtml = "C:\Users\Karan\temp_debug_header.html"
Set-Content $tempHtml $injected -Encoding UTF8

$tempOut = "C:\Users\Karan\temp_dom_output.txt"
Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2000',
    '--dump-dom',
    '--window-size=360,800',
    'file:///C:/Users/Karan/temp_debug_header.html'
) -RedirectStandardOutput $tempOut -Wait -NoNewWindow

$dom = Get-Content $tempOut -Raw
if ($dom -match '<div id="debugResult">([^<]+)</div>') {
    Write-Host "RESULT: $($matches[1])"
} else {
    Write-Host "debugResult not found"
}

Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
Remove-Item $tempOut -Force -ErrorAction SilentlyContinue
