$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$indexUrl = 'file:///' + (Join-Path $root 'index.html').Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$dest = 'C:\Users\Karan\temp_full.png'

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=3000',
    '--window-size=1280,5000',
    "--screenshot=$dest",
    $indexUrl
) -NoNewWindow -Wait

if (Test-Path $dest) {
    Copy-Item $dest (Join-Path $root 'scratch\home_full.png') -Force
    Remove-Item $dest -Force
    Write-Host 'Captured home_full.png'
}
