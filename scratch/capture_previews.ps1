$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$previewHtml = Join-Path $scratch "preview_materials.html"
$encodedUrl = "file:///" + $previewHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$viewports = @(
    @{ Name = "desktop_1280"; Width = 1280; Height = 750 },
    @{ Name = "desktop_1024"; Width = 1024; Height = 800 },
    @{ Name = "tablet_768";   Width = 768;  Height = 1100 },
    @{ Name = "mobile_375";   Width = 375;  Height = 1400 }
)

foreach ($vp in $viewports) {
    $tempPng = "C:\Users\Karan\temp_prev_$($vp.Name).png"
    $destPng = Join-Path $scratch "preview_$($vp.Name).png"
    
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        "--screenshot=$tempPng",
        "--window-size=$($vp.Width),$($vp.Height)",
        $encodedUrl
    ) -NoNewWindow -Wait
    
    if (Test-Path $tempPng) {
        Copy-Item $tempPng $destPng -Force
        Remove-Item $tempPng -Force
        Write-Host "Captured preview_$($vp.Name).png: $((Get-Item $destPng).Length) bytes"
    }
}
