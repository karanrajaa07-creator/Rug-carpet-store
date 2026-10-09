$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$html = Join-Path $scratch "render_mobile_products.html"
$encodedUrl = "file:///" + $html.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$tempPng = "C:\Users\Karan\temp_mobile_devices.png"
$destPng = Join-Path $scratch "mobile_devices_verified.png"

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--allow-file-access-from-files',
    '--virtual-time-budget=4500',
    "--screenshot=$tempPng",
    '--window-size=1280,1300',
    $encodedUrl
) -NoNewWindow -Wait

if (Test-Path $tempPng) {
    Copy-Item $tempPng $destPng -Force
    Remove-Item $tempPng -Force
    Write-Host "Captured mobile_devices_verified.png"
}
