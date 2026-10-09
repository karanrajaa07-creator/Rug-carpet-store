$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path scratch).Path
$html = (Resolve-Path products.html).Path
$tempPng = "C:\Users\Karan\temp_cards_full.png"
$destPng = Join-Path $scratch "cards_grid_full.png"

$encodedUrl = "file:///" + $html.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2500',
    "--screenshot=$tempPng",
    '--window-size=1280,2200',
    $encodedUrl
) -NoNewWindow -Wait

if (Test-Path $tempPng) {
    Copy-Item $tempPng $destPng -Force
    Remove-Item $tempPng -Force
    Write-Host "Successfully captured cards_grid_full.png"
}
