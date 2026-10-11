$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$artifactDir = "C:\Users\Karan\.gemini\antigravity-ide\brain\1238d468-beab-4358-a7b9-a2f6826e8741"

# Helper function to render, select tier, and capture screenshot
function Capture-Option-Screenshot {
    param(
        [string]$pageName,
        [string]$tier,
        [string]$theme = "light",
        [int]$width = 1280,
        [int]$height = 900,
        [string]$outputFileName
    )

    $srcHtml = Join-Path $root $pageName
    $content = [System.IO.File]::ReadAllText($srcHtml, [System.Text.Encoding]::UTF8)

    $interactScript = @"
<script>
window.addEventListener('DOMContentLoaded', () => {
  if ('$theme' === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark');
    document.documentElement.setAttribute('data-bs-theme', 'dark');
  }
  setTimeout(() => {
    if ('$pageName' === 'product-details.html') {
      if (typeof window.selectProductDetailTier === 'function') {
        window.selectProductDetailTier('$tier', false);
      }
    } else if ('$pageName' === 'products.html') {
      if (typeof window.selectCardSize === 'function') {
        window.selectCardSize(1, '$tier');
      }
    }
  }, 250);
});
</script>
"@

    $tempFile = Join-Path $root "temp_snap_$outputFileName.html"
    $injected = $content.Replace('</body>', $interactScript + '</body>')
    [System.IO.File]::WriteAllText($tempFile, $injected, [System.Text.Encoding]::UTF8)

    $url = "file:///" + $tempFile.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
    if ($pageName -eq 'product-details.html') {
        $url += "?id=1"
    }

    $outPath = Join-Path $artifactDir $outputFileName

    $proc = Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        "--window-size=$width,$height",
        '--virtual-time-budget=3000',
        "--screenshot=$outPath",
        $url
    ) -NoNewWindow -PassThru

    $proc.WaitForExit(10000)
    Remove-Item $tempFile -ErrorAction SilentlyContinue

    if (Test-Path $outPath) {
        Write-Output "Captured: $outputFileName (Size: $((Get-Item $outPath).Length) bytes)"
    } else {
        Write-Output "Failed to capture: $outputFileName"
    }
}

# 1. Product Details - Small
Capture-Option-Screenshot -pageName 'product-details.html' -tier 'small' -outputFileName 'pd_small_desktop.png'

# 2. Product Details - Medium
Capture-Option-Screenshot -pageName 'product-details.html' -tier 'medium' -outputFileName 'pd_medium_desktop.png'

# 3. Product Details - Large
Capture-Option-Screenshot -pageName 'product-details.html' -tier 'large' -outputFileName 'pd_large_desktop.png'

# 4. Product Details - Small Dark Mode
Capture-Option-Screenshot -pageName 'product-details.html' -tier 'small' -theme 'dark' -outputFileName 'pd_small_dark.png'

# 5. Product Details - Small Mobile
Capture-Option-Screenshot -pageName 'product-details.html' -tier 'small' -width 375 -height 812 -outputFileName 'pd_small_mobile.png'

# 6. Products Catalog - Small
Capture-Option-Screenshot -pageName 'products.html' -tier 'small' -outputFileName 'shop_small_desktop.png'

# 7. Products Catalog - Large
Capture-Option-Screenshot -pageName 'products.html' -tier 'large' -outputFileName 'shop_large_desktop.png'
