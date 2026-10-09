$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$productsHtml = (Resolve-Path "products.html").Path
$encodedUrl = "file:///" + $productsHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$viewports = @(
    @{ Name = "desktop"; Width = 1280; Height = 1000 },
    @{ Name = "tablet";  Width = 768;  Height = 1000 },
    @{ Name = "mobile";  Width = 375;  Height = 1000 }
)

foreach ($vp in $viewports) {
    $tempPng = "C:\Users\Karan\temp_cards_$($vp.Name).png"
    $destPng = Join-Path $scratch "cards_$($vp.Name)_verified.png"
    
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
        Write-Host "Captured cards_$($vp.Name)_verified.png"
    }
}
