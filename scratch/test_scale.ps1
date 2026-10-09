$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$temp = 'C:\Users\Karan\temp_test_scale.png'
Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--force-device-scale-factor=1',
    '--window-size=360,800',
    '--virtual-time-budget=2000',
    "--screenshot=$temp",
    'file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/index.html'
) -NoNewWindow -Wait

if (Test-Path $temp) {
    Copy-Item $temp 'scratch/test_scale_360.png' -Force
    Remove-Item $temp -Force
    Write-Host "Captured with scale factor 1"
}
