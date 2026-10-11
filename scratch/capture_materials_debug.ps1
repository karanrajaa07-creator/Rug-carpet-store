$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$indexHtml = (Resolve-Path "index.html").Path
$content = [System.IO.File]::ReadAllText($indexHtml, [System.Text.Encoding]::UTF8)

$scrollScript = @"
<script>
window.addEventListener('load', () => {
    document.querySelectorAll('.reveal-on-scroll, .reveal-stagger').forEach(el => el.classList.add('is-revealed'));
    const heading = Array.from(document.querySelectorAll('h2')).find(h => h.textContent.includes('Shop by Material'));
    if (heading) {
        heading.closest('section').scrollIntoView({ behavior: 'instant', block: 'start' });
    }
});
</script>
"@

$testHtml = Join-Path (Get-Location).Path "test_material_scroll.html"
$injected = $content.Replace('</body>', $scrollScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$encodedUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$viewports = @(
    @{ Name = "desktop_1440"; Width = 1440; Height = 800 },
    @{ Name = "desktop_1024"; Width = 1024; Height = 800 },
    @{ Name = "tablet_768";   Width = 768;  Height = 1000 },
    @{ Name = "mobile_375";   Width = 375;  Height = 1200 }
)

foreach ($vp in $viewports) {
    $tempPng = "C:\Users\Karan\temp_mat_$($vp.Name).png"
    $destPng = Join-Path $scratch "mat_$($vp.Name).png"
    
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2000',
        "--screenshot=$tempPng",
        "--window-size=$($vp.Width),$($vp.Height)",
        $encodedUrl
    ) -NoNewWindow -Wait
    
    if (Test-Path $tempPng) {
        Copy-Item $tempPng $destPng -Force
        Remove-Item $tempPng -Force
        Write-Host "Captured mat_$($vp.Name).png: $((Get-Item $destPng).Length) bytes"
    }
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
