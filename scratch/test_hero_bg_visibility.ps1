$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"
$prodHtmlPath = Join-Path $root "products.html"
$htmlContent = [System.IO.File]::ReadAllText($prodHtmlPath, [System.Text.Encoding]::UTF8)

function Test-Hero-Overlay($name, $theme, $customCss) {
    $tempHtml = Join-Path $root "temp_hero_$name.html"
    $tempFile = "C:\Users\Karan\temp_hero_$name.png"
    $dest = Join-Path $scratch "$name.png"

    $styleInject = "<style>$customCss</style>"
    $scriptInject = @"
<script>
document.documentElement.setAttribute('data-theme', '$theme');
localStorage.setItem('rug_store_theme', '$theme');
</script>
"@
    $modHtml = $htmlContent.Replace('</head>', $styleInject + '</head>').Replace('</body>', $scriptInject + '</body>')
    if ($theme -eq 'dark') {
        $modHtml = $modHtml.Replace('<html lang="en"', '<html lang="en" data-theme="dark"')
    } else {
        $modHtml = $modHtml.Replace('<html lang="en"', '<html lang="en" data-theme="light"')
    }

    [System.IO.File]::WriteAllText($tempHtml, $modHtml, [System.Text.Encoding]::UTF8)
    $tempUrl = "file:///" + $tempHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2000',
        "--window-size=1280,680",
        "--screenshot=$tempFile",
        $tempUrl
    ) -NoNewWindow -Wait

    if (Test-Path $tempFile) {
        Copy-Item $tempFile $dest -Force
        Remove-Item $tempFile -Force
        Write-Host "Success: $name -> $((Get-Item $dest).Length) bytes"
    }
    Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
}

# Test 1: Light Theme with balanced translucent scrim (0.70 -> 0.45 -> 0.15) & center 55%
$css1 = @"
.page-hero-banner.hero-products {
  background-position: center 55% !important;
}
.page-hero-banner.hero-products::before {
  background: linear-gradient(100deg, rgba(250, 246, 240, 0.72) 0%, rgba(247, 242, 234, 0.46) 48%, rgba(243, 236, 226, 0.16) 100%) !important;
}
.page-hero-banner.hero-products h1 {
  text-shadow: 0 1px 3px rgba(255, 255, 255, 0.9), 0 0 15px rgba(255, 255, 255, 0.7) !important;
}
.page-hero-banner.hero-products .section-desc {
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.9), 0 0 10px rgba(255, 255, 255, 0.6) !important;
}
.page-hero-banner.hero-products .section-tag {
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.9) !important;
}
"@
Test-Hero-Overlay -name "test_hero_light_balanced" -theme "light" -customCss $css1

# Test 2: Dark Theme with balanced translucent scrim (0.75 -> 0.50 -> 0.22) & center 55%
$css2 = @"
.page-hero-banner.hero-products {
  background-position: center 55% !important;
}
[data-theme="dark"] .page-hero-banner.hero-products::before {
  background: linear-gradient(100deg, rgba(16, 14, 12, 0.76) 0%, rgba(22, 19, 16, 0.50) 50%, rgba(26, 23, 20, 0.22) 100%) !important;
}
[data-theme="dark"] .page-hero-banner.hero-products h1 {
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.85) !important;
}
[data-theme="dark"] .page-hero-banner.hero-products .section-desc {
  text-shadow: 0 1px 6px rgba(0, 0, 0, 0.85) !important;
}
"@
Test-Hero-Overlay -name "test_hero_dark_balanced" -theme "dark" -customCss $css2
