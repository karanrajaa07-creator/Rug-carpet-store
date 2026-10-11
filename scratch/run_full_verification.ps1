$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path

Write-Host "================================================="
Write-Host "ATELIER RUGS - FULL VERIFICATION TEST SUITE"
Write-Host "================================================="

# 1. Test Home Page Shop by Material section dimensions across viewports
$viewports = @(
    @{ name = "Desktop"; width = 1280; height = 800 },
    @{ name = "Tablet";  width = 1024; height = 768 },
    @{ name = "Mobile";  width = 375;  height = 667 }
)

$homeUrl = "file:///" + (Join-Path $root "index.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
foreach ($vp in $viewports) {
    $outFile = Join-Path $root "scratch\verify_home_$($vp.width).txt"
    $shotFile = Join-Path $root "scratch\verify_home_$($vp.width).png"
    & $edge --headless=new --window-size="$($vp.width),$($vp.height)" --screenshot=$shotFile --dump-dom $homeUrl | Out-File -FilePath $outFile -Encoding utf8
    Write-Host "Captured Home at $($vp.name) ($($vp.width)px)"
}

# 2. Check Natural Fibers alignment script
$measureScript = @"
<script>
window.addEventListener('load', function() {
  const cards = Array.from(document.querySelectorAll('.material-card'));
  const data = cards.map((c, i) => {
    const r = c.getBoundingClientRect();
    const title = c.querySelector('h5')?.textContent.trim();
    return { index: i, title: title, width: Math.round(r.width), height: Math.round(r.height), top: Math.round(r.top) };
  });
  const out = document.createElement('div');
  out.id = 'MATERIAL_MEASURE_OUTPUT';
  out.textContent = JSON.stringify(data);
  document.body.appendChild(out);
});
</script>
"@

$homeContent = [System.IO.File]::ReadAllText((Join-Path $root "index.html"), [System.Text.Encoding]::UTF8)
$injectedHome = $homeContent.Replace('</body>', $measureScript + '</body>')
$testHomeHtml = Join-Path $root "test_verify_home.html"
[System.IO.File]::WriteAllText($testHomeHtml, $injectedHome, [System.Text.Encoding]::UTF8)
$testHomeUrl = "file:///" + $testHomeHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

foreach ($vp in $viewports) {
    $outF = Join-Path $root "scratch\measure_home_$($vp.width).txt"
    & $edge --headless=new --window-size="$($vp.width),$($vp.height)" --virtual-time-budget=3000 --dump-dom $testHomeUrl | Out-File -FilePath $outF -Encoding utf8
    $content = Get-Content $outF -Raw
    if ($content -match '<div id="MATERIAL_MEASURE_OUTPUT">(.*?)</div>') {
        Write-Host "Home Materials ($($vp.name) $($vp.width)px): $($matches[1])"
    }
}
Remove-Item $testHomeHtml -ErrorAction SilentlyContinue

# 3. Test Shop Page Hero and Image Overlays (Light and Dark)
$shopUrl = "file:///" + (Join-Path $root "products.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
& $edge --headless=new --window-size="1280,900" --screenshot=(Join-Path $root "scratch\verify_shop_light.png") $shopUrl

# Dark mode test
$darkShopScript = @"
<script>
document.documentElement.setAttribute('data-theme', 'dark');
document.documentElement.setAttribute('data-bs-theme', 'dark');
</script>
"@
$shopContent = [System.IO.File]::ReadAllText((Join-Path $root "products.html"), [System.Text.Encoding]::UTF8)
$injectedDarkShop = $shopContent.Replace('</head>', $darkShopScript + '</head>')
$testDarkShopHtml = Join-Path $root "test_verify_dark_shop.html"
[System.IO.File]::WriteAllText($testDarkShopHtml, $injectedDarkShop, [System.Text.Encoding]::UTF8)
$testDarkShopUrl = "file:///" + $testDarkShopHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
& $edge --headless=new --window-size="1280,900" --screenshot=(Join-Path $root "scratch\verify_shop_dark.png") $testDarkShopUrl
Remove-Item $testDarkShopHtml -ErrorAction SilentlyContinue
Write-Host "Captured Shop Light & Dark Screenshots"

# 4. Test Size Option Clicks on Details & Catalog Cards
$testClicksScript = @"
<script>
window.addEventListener('load', function() {
  const log = [];
  // Detail page test
  const mainImg = document.getElementById('mainProductImage');
  log.push({ page: 'details', initialSrc: mainImg ? mainImg.src : null });

  const smallBtn = document.getElementById('sizeBtn-small');
  if (smallBtn) {
    smallBtn.click();
    log.push({ page: 'details', afterSmall: mainImg ? mainImg.src : null, activeTier: window.currentSelectedTier });
  }

  const largeBtn = document.getElementById('sizeBtn-large');
  if (largeBtn) {
    largeBtn.click();
    log.push({ page: 'details', afterLarge: mainImg ? mainImg.src : null, activeTier: window.currentSelectedTier });
  }

  const medBtn = document.getElementById('sizeBtn-medium');
  if (medBtn) {
    medBtn.click();
    log.push({ page: 'details', afterMedium: mainImg ? mainImg.src : null, activeTier: window.currentSelectedTier });
  }

  const resDiv = document.createElement('div');
  resDiv.id = 'CLICKS_VERIFY_OUTPUT';
  resDiv.textContent = JSON.stringify(log);
  document.body.appendChild(resDiv);
});
</script>
"@
$pdContent = [System.IO.File]::ReadAllText((Join-Path $root "product-details.html"), [System.Text.Encoding]::UTF8)
$injectedPd = $pdContent.Replace('</body>', $testClicksScript + '</body>')
$testPdHtml = Join-Path $root "test_verify_clicks.html"
[System.IO.File]::WriteAllText($testPdHtml, $injectedPd, [System.Text.Encoding]::UTF8)
$testPdUrl = "file:///" + $testPdHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=4"

$outClicks = Join-Path $root "scratch\verify_clicks_out.txt"
& $edge --headless=new --window-size="1280,900" --virtual-time-budget=4000 --dump-dom $testPdUrl | Out-File -FilePath $outClicks -Encoding utf8
$contentClicks = Get-Content $outClicks -Raw
if ($contentClicks -match '<div id="CLICKS_VERIFY_OUTPUT">(.*?)</div>') {
    Write-Host "Size Selection Test: $($matches[1])"
}
Remove-Item $testPdHtml -ErrorAction SilentlyContinue

# 5. Check Pricing Page Typography
$pricingUrl = "file:///" + (Join-Path $root "pricing.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
& $edge --headless=new --window-size="1280,900" --screenshot=(Join-Path $root "scratch\verify_pricing.png") $pricingUrl
Write-Host "Captured Pricing Screenshot"

# 6. Verify all hero images across subpages
$pages = @('about.html', 'products.html', 'services.html', 'pricing.html', 'contact.html', 'blog.html', 'custom-sizing.html', 'care-guide.html', 'wishlist.html', 'service-details.html')
foreach ($p in $pages) {
    $pUrl = "file:///" + (Join-Path $root $p).Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
    $pShot = Join-Path $root "scratch\verify_hero_$($p.Replace('.html','')).png"
    & $edge --headless=new --window-size="1280,600" --screenshot=$pShot $pUrl
    Write-Host "Verified hero banner: $p"
}

Write-Host "VERIFICATION RUN COMPLETE."
