$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

$targets = @(
    @{ Name = 'verify_home_1024.png'; Url = "file:///$root/index.html"; W = 1024; H = 768 },
    @{ Name = 'verify_home_360.png'; Url = "file:///$root/index.html"; W = 360; H = 740 },
    @{ Name = 'verify_products_1024.png'; Url = "file:///$root/products.html"; W = 1024; H = 768 },
    @{ Name = 'verify_pricing_1024.png'; Url = "file:///$root/pricing.html"; W = 1024; H = 768 },
    @{ Name = 'verify_contact_1024.png'; Url = "file:///$root/contact.html"; W = 1024; H = 768 }
)

foreach ($t in $targets) {
    $outPath = Join-Path $root ("scratch\" + $t.Name)
    $argList = @(
        '--headless=new',
        '--disable-gpu',
        "--window-size=$($t.W),$($t.H)",
        '--virtual-time-budget=2000',
        "--screenshot=$outPath",
        $t.Url
    )
    Start-Process -FilePath $edgePath -ArgumentList $argList -Wait
}

Get-ChildItem -Path (Join-Path $root 'scratch\verify_*.png') | Select-Object Name, Length
