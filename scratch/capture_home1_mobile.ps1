$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$artifactDir = "C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e"

$viewports = @(
    @{ Name = "mobile_390x844";    W = 390;  H = 844 },
    @{ Name = "mobile_375x667";    W = 375;  H = 667 }
)

foreach ($vp in $viewports) {
    $destPng = Join-Path $artifactDir "Home1_$($vp.Name).png"
    
    $p = Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--disable-gpu',
        '--no-first-run',
        '--disable-background-networking',
        '--disable-default-apps',
        '--disable-extensions',
        '--disable-sync',
        "--screenshot=$destPng",
        "--window-size=$($vp.W),$($vp.H)",
        '--dump-dom',
        'http://localhost:3000/index.html'
    ) -NoNewWindow -PassThru -RedirectStandardOutput "C:\Users\Karan\temp_h1_out.txt"
    
    $p.WaitForExit(10000)
    
    if (Test-Path $destPng) {
        $len = (Get-Item $destPng).Length
        Write-Host "Captured Home1_$($vp.Name).png ($len bytes)"
    } else {
        Write-Host "Failed Home1_$($vp.Name).png"
    }
}

Remove-Item "C:\Users\Karan\temp_h1_out.txt" -Force -ErrorAction SilentlyContinue
