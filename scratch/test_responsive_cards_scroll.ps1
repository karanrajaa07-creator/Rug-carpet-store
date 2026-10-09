$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$productsHtml = (Resolve-Path "products.html").Path
$content = [System.IO.File]::ReadAllText($productsHtml, [System.Text.Encoding]::UTF8)

$scrollScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const grid = document.getElementById('productsGridContainer');
        if (grid) { grid.scrollIntoView({ behavior: 'instant', block: 'start' }); }
    }, 400);
});
</script>
"@

$testHtml = Join-Path (Get-Location).Path "test_responsive_scroll.html"
$injected = $content.Replace('</body>', $scrollScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$encodedUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$viewports = @(
    @{ Name = "tablet";  Width = 768;  Height = 1200 },
    @{ Name = "mobile";  Width = 375;  Height = 1200 }
)

foreach ($vp in $viewports) {
    $tempPng = "C:\Users\Karan\temp_cards_grid_$($vp.Name).png"
    $destPng = Join-Path $scratch "cards_grid_$($vp.Name)_verified.png"
    
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2500',
        "--screenshot=$tempPng",
        "--window-size=$($vp.Width),$($vp.Height)",
        $encodedUrl
    ) -NoNewWindow -Wait
    
    if (Test-Path $tempPng) {
        Copy-Item $tempPng $destPng -Force
        Remove-Item $tempPng -Force
        Write-Host "Captured cards_grid_$($vp.Name)_verified.png"
    }
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
