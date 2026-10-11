$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"

$pages = @(
    "index.html",
    "home-2.html",
    "products.html",
    "about.html",
    "services.html",
    "service-details.html",
    "custom-sizing.html",
    "care-guide.html",
    "blog.html",
    "pricing.html",
    "contact.html",
    "wishlist.html"
)

$viewports = @(
    @{ name = "tablet"; w = 768; h = 800 },
    @{ name = "mobile"; w = 375; h = 667 }
)

foreach ($vp in $viewports) {
    foreach ($pageName in $pages) {
        $pagePath = Join-Path $root $pageName
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($pageName)
        $htmlContent = [System.IO.File]::ReadAllText($pagePath, [System.Text.Encoding]::UTF8)

        foreach ($theme in @("light", "dark")) {
            $tempHtml = Join-Path $root "temp_resp_$($baseName)_$($vp.name)_$($theme).html"
            $tempImg = "C:\Users\Karan\snap_$($baseName)_$($vp.name)_$($theme).png"
            $destImg = Join-Path $scratch "snap_$($baseName)_$($vp.name)_$($theme).png"

            $scriptInject = @"
<script>
document.documentElement.setAttribute('data-theme', '$theme');
localStorage.setItem('rug_store_theme', '$theme');
</script>
"@
            $modHtml = $htmlContent.Replace('</body>', $scriptInject + '</body>')
            if ($theme -eq 'dark') {
                $modHtml = $modHtml.Replace('<html lang="en"', '<html lang="en" data-theme="dark"')
            } else {
                $modHtml = $modHtml.Replace('<html lang="en"', '<html lang="en" data-theme="light"')
            }

            [System.IO.File]::WriteAllText($tempHtml, $modHtml, [System.Text.Encoding]::UTF8)
            $tempUrl = "file:///" + $tempHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

            Start-Process -FilePath $edge -ArgumentList @(
                '--headless=new',
                '--virtual-time-budget=1500',
                "--window-size=$($vp.w),$($vp.h)",
                "--screenshot=$tempImg",
                $tempUrl
            ) -NoNewWindow -Wait

            if (Test-Path $tempImg) {
                Copy-Item $tempImg $destImg -Force
                Remove-Item $tempImg -Force
            }
            Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
        }
        Write-Host "$($baseName) [$($vp.name)]: done"
    }
}
