$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$html = (Resolve-Path "products.html").Path
$encodedUrl = "file:///" + $html.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

# Tablet
$tempPng = "C:\Users\Karan\temp_cards_tablet_tall.png"
$destPng = Join-Path $scratch "cards_tablet_tall.png"
Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2500',
    "--screenshot=$tempPng",
    '--window-size=768,2600',
    $encodedUrl
) -NoNewWindow -Wait
if (Test-Path $tempPng) {
    Copy-Item $tempPng $destPng -Force
    Remove-Item $tempPng -Force
    Write-Host "Captured cards_tablet_tall.png"
}

# Mobile
$tempPng2 = "C:\Users\Karan\temp_cards_mobile_tall.png"
$destPng2 = Join-Path $scratch "cards_mobile_tall.png"
Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2500',
    "--screenshot=$tempPng2",
    '--window-size=375,3200',
    $encodedUrl
) -NoNewWindow -Wait
if (Test-Path $tempPng2) {
    Copy-Item $tempPng2 $destPng2 -Force
    Remove-Item $tempPng2 -Force
    Write-Host "Captured cards_mobile_tall.png"
}
