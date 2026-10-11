$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$html = Join-Path $scratch "render_mobile_hero_test.html"
$encodedUrl = "file:///" + $html.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$tempPng = "C:\Users\Karan\temp_mobile_hero_verified.png"
$destPng = Join-Path $scratch "mobile_hero_verified.png"

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--allow-file-access-from-files',
    '--virtual-time-budget=3500',
    "--screenshot=$tempPng",
    '--window-size=1300,1200',
    $encodedUrl
) -NoNewWindow -Wait

if (Test-Path $tempPng) {
    Copy-Item $tempPng $destPng -Force
    Remove-Item $tempPng -Force
    Write-Host "Success: captured mobile_hero_verified.png ($((Get-Item $destPng).Length) bytes)"
}
