$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path

$viewports = @(
    @{ Name = "desktop_1920x1080"; W = 1920; H = 1080 },
    @{ Name = "desktop_1440x900";  W = 1440; H = 900 },
    @{ Name = "desktop_1366x768";  W = 1366; H = 768 },
    @{ Name = "desktop_1280x800";  W = 1280; H = 800 },
    @{ Name = "tablet_768x1024";   W = 768;  H = 1024 },
    @{ Name = "mobile_390x844";    W = 390;  H = 844 },
    @{ Name = "mobile_375x667";    W = 375;  H = 667 }
)

$pages = @(
    @{ Name = "Home1"; Url = "http://localhost:3000/index.html";  Selector = ".hero-home-1" },
    @{ Name = "Home2"; Url = "http://localhost:3000/home-2.html"; Selector = ".hero-home-2" }
)

Write-Host "=== VIEWPORT MEASUREMENT AUDIT ==="

foreach ($page in $pages) {
    Write-Host "`nPAGE: $($page.Name) ($($page.Url))"
    foreach ($vp in $viewports) {
        $tempPng = Join-Path $scratch "measure_$($page.Name)_$($vp.Name).png"
        
        $p = Start-Process -FilePath $edge -ArgumentList @(
            '--headless=new',
            '--hide-scrollbars',
            "--window-size=$($vp.W),$($vp.H)",
            "--screenshot=$tempPng",
            $page.Url
        ) -NoNewWindow -PassThru
        
        $p.WaitForExit(10000)
    }
}

Write-Host "Completed capturing initial screenshots across viewports."
