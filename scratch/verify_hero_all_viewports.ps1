$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"
$prodHtmlPath = Join-Path $root "products.html"
$htmlContent = [System.IO.File]::ReadAllText($prodHtmlPath, [System.Text.Encoding]::UTF8)

function Capture-Hero-Test($name, $width, $height, $theme) {
    $tempHtml = Join-Path $root "temp_verify_$name.html"
    $tempFile = "C:\Users\Karan\temp_verify_$name.png"
    $dest = Join-Path $scratch "$name.png"

    $inject = @"
<script>
document.documentElement.setAttribute('data-theme', '$theme');
localStorage.setItem('rug_store_theme', '$theme');
window.addEventListener('DOMContentLoaded', () => {
    document.documentElement.setAttribute('data-theme', '$theme');
});
</script>
"@
    $modHtml = $htmlContent.Replace('</head>', $inject + '</head>')
    if ($theme -eq 'dark') {
        $modHtml = $modHtml.Replace('<html lang="en"', '<html lang="en" data-theme="dark"')
    } else {
        $modHtml = $modHtml.Replace('<html lang="en"', '<html lang="en" data-theme="light"')
    }

    [System.IO.File]::WriteAllText($tempHtml, $modHtml, [System.Text.Encoding]::UTF8)
    $tempUrl = "file:///" + $tempHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2500',
        "--window-size=$width,$height",
        "--screenshot=$tempFile",
        $tempUrl
    ) -NoNewWindow -Wait

    if (Test-Path $tempFile) {
        Copy-Item $tempFile $dest -Force
        Remove-Item $tempFile -Force
        Write-Host "Success: $name ($width x $height, $theme) -> $((Get-Item $dest).Length) bytes"
    } else {
        Write-Host "Failed: $name"
    }
    Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
}

Write-Host "Capturing Hero across viewports in Light & Dark themes..."
Capture-Hero-Test -name "hero_desktop_light" -width 1280 -height 650 -theme "light"
Capture-Hero-Test -name "hero_desktop_dark" -width 1280 -height 650 -theme "dark"
Capture-Hero-Test -name "hero_tablet_light" -width 768 -height 650 -theme "light"
Capture-Hero-Test -name "hero_tablet_dark" -width 768 -height 650 -theme "dark"
Capture-Hero-Test -name "hero_mobile_light" -width 375 -height 650 -theme "light"
Capture-Hero-Test -name "hero_mobile_dark" -width 375 -height 650 -theme "dark"
Write-Host "Completed capturing all hero viewports."
