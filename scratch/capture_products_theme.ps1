$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root "scratch"
$prodHtmlPath = Join-Path $root "products.html"
$htmlContent = [System.IO.File]::ReadAllText($prodHtmlPath, [System.Text.Encoding]::UTF8)

function Capture-View($name, $width, $height, $theme, $scrollSelector) {
    $tempHtml = Join-Path $root "temp_snap_$name.html"
    $tempFile = "C:\Users\Karan\temp_snap_$name.png"
    $dest = Join-Path $scratch "$name.png"

    $inject = @"
<script>
document.documentElement.setAttribute('data-theme', '$theme');
localStorage.setItem('rug_store_theme', '$theme');
window.addEventListener('load', () => {
    document.documentElement.setAttribute('data-theme', '$theme');
    const el = document.querySelector('$scrollSelector');
    if (el) {
        el.scrollIntoView({ block: 'start' });
    }
});
</script>
"@
    $modHtml = $htmlContent.Replace('</body>', $inject + '</body>')
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
        "--window-size=$width,$height",
        "--screenshot=$tempFile",
        $tempUrl
    ) -NoNewWindow -Wait

    if (Test-Path $tempFile) {
        Copy-Item $tempFile $dest -Force
        Remove-Item $tempFile -Force
        Write-Host "Success: $name -> $((Get-Item $dest).Length) bytes"
    } else {
        Write-Host "Failed to create screenshot for $name"
    }
    Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
}

# Mobile Light Theme Hero (375x700)
Capture-View -name "shop_hero_light_375" -width 375 -height 700 -theme "light" -scrollSelector ".page-hero-banner"

# Mobile Dark Theme Hero (375x700)
Capture-View -name "shop_hero_dark_375" -width 375 -height 700 -theme "dark" -scrollSelector ".page-hero-banner"

# Mobile Light Theme Product Cards (375x800)
Capture-View -name "shop_cards_light_375" -width 375 -height 800 -theme "light" -scrollSelector "#productsGridContainer"
