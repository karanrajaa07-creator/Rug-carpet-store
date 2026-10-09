$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path scratch).Path

$tests = @(
    @{ name = "cards_products_1280"; url = "file:///" + (Resolve-Path products.html).Path.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26'); w = 1280; h = 1000 },
    @{ name = "cards_products_1024"; url = "file:///" + (Resolve-Path products.html).Path.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26'); w = 1024; h = 1000 },
    @{ name = "cards_home_1280"; url = "file:///" + (Resolve-Path index.html).Path.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26'); w = 1280; h = 1200 }
)

foreach ($t in $tests) {
    $tempFile = "C:\Users\Karan\temp_$($t.name).png"
    $destFile = Join-Path $scratch "$($t.name).png"
    
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2500',
        "--screenshot=$tempFile",
        "--window-size=$($t.w),$($t.h)",
        $t.url
    ) -NoNewWindow -Wait
    
    if (Test-Path $tempFile) {
        Copy-Item $tempFile $destFile -Force
        Remove-Item $tempFile -Force
        Write-Host "Captured $($t.name)"
    }
}
