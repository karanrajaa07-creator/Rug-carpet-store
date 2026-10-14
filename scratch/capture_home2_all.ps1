$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$artifactDir = "C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e"

$viewports = @(
    @{ Name = "desktop_1920x1080"; W = 1920; H = 1080 },
    @{ Name = "desktop_1440x900";  W = 1440; H = 900 },
    @{ Name = "desktop_1366x768";  W = 1366; H = 768 },
    @{ Name = "tablet_768x1024";   W = 768;  H = 1024 },
    @{ Name = "mobile_390x844";    W = 390;  H = 844 },
    @{ Name = "mobile_375x667";    W = 375;  H = 667 }
)

foreach ($vp in $viewports) {
    $destPng = Join-Path $artifactDir "Home2_$($vp.Name).png"
    
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
        'http://localhost:3000/home-2.html'
    ) -NoNewWindow -PassThru -RedirectStandardOutput "C:\Users\Karan\temp_h2_out.txt"
    
    $p.WaitForExit(10000)
    
    if (Test-Path $destPng) {
        $len = (Get-Item $destPng).Length
        Write-Host "Captured Home2_$($vp.Name).png ($len bytes)"
    } else {
        Write-Host "Failed Home2_$($vp.Name).png"
    }
}

Remove-Item "C:\Users\Karan\temp_h2_out.txt" -Force -ErrorAction SilentlyContinue
