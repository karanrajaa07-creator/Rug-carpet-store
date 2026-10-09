$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$workspace = (Get-Location).Path
$scratch = Join-Path $workspace "scratch"

$tests = @(
    @{ name = "home_360"; url = "file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/index.html"; width = 360; height = 800 },
    @{ name = "home_1024"; url = "file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/index.html"; width = 1024; height = 768 },
    @{ name = "products_1024"; url = "file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/products.html"; width = 1024; height = 768 },
    @{ name = "pricing_1024"; url = "file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/pricing.html"; width = 1024; height = 768 },
    @{ name = "contact_1024"; url = "file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/contact.html"; width = 1024; height = 768 }
)

foreach ($t in $tests) {
    $tempFile = "C:\Users\Karan\temp_$($t.name).png"
    $destFile = Join-Path $scratch "$($t.name).png"
    
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2000',
        "--screenshot=$tempFile",
        "--window-size=$($t.width),$($t.height)",
        $t.url
    ) -NoNewWindow -Wait
    
    if (Test-Path $tempFile) {
        Copy-Item $tempFile $destFile -Force
        Remove-Item $tempFile -Force
        Write-Host "Successfully captured $($t.name)"
    } else {
        Write-Host "Failed to capture $($t.name)"
    }
}
