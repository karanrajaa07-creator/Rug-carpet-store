$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path "scratch").Path
$artifactDir = "C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e"

$viewports = @(
    @{ Name = "desktop_1920x1080"; W = 1920; H = 1080; Type = "Desktop" },
    @{ Name = "desktop_1440x900";  W = 1440; H = 900;  Type = "Desktop" },
    @{ Name = "desktop_1366x768";  W = 1366; H = 768;  Type = "Laptop/Short" },
    @{ Name = "desktop_1280x800";  W = 1280; H = 800;  Type = "Desktop" },
    @{ Name = "tablet_768x1024";   W = 768;  H = 1024; Type = "Tablet" },
    @{ Name = "mobile_390x844";    W = 390;  H = 844;  Type = "Mobile" },
    @{ Name = "mobile_375x667";    W = 375;  H = 667;  Type = "Mobile/Short" }
)

$pages = @(
    @{ Name = "Home1"; File = "index.html";  Url = "http://localhost:3000/index.html";  Selector = ".hero-home-1" },
    @{ Name = "Home2"; File = "home-2.html"; Url = "http://localhost:3000/home-2.html"; Selector = ".hero-home-2" }
)

$report = @()

foreach ($page in $pages) {
    Write-Host "`n======================================================="
    Write-Host "AUDITING $($page.Name) ($($page.File))"
    Write-Host "======================================================="

    foreach ($vp in $viewports) {
        $tempPng = "C:\Users\Karan\temp_$($page.Name)_$($vp.Name).png"
        $finalPng = Join-Path $artifactDir "$($page.Name)_$($vp.Name).png"
        
        # Capture screenshot
        $p = Start-Process -FilePath $edge -ArgumentList @(
            '--headless=new',
            '--hide-scrollbars',
            "--window-size=$($vp.W),$($vp.H)",
            "--screenshot=$tempPng",
            $page.Url
        ) -NoNewWindow -PassThru
        
        $p.WaitForExit(10000)
        
        if (Test-Path $tempPng) {
            Copy-Item $tempPng $finalPng -Force
            Remove-Item $tempPng -Force
            Write-Host "Saved screenshot: $($page.Name)_$($vp.Name).png"
        }
    }
}

Write-Host "`nAll screenshots captured successfully."
