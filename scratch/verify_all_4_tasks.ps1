$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$dir = 'C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e'

Write-Host "Creating theme test wrappers..."

# 1. About Page Test Helper
$aboutHtml = Get-Content 'about.html' -Raw
$aboutScript = @"
<script>
window.addEventListener('load', () => {
  const icon = document.querySelector('.luxury-card i.bi-shield-check');
  const card = icon ? icon.closest('.luxury-card') : null;
  const cs = icon ? window.getComputedStyle(icon) : null;
  const info = {
    iconFound: !!icon,
    iconClass: icon ? icon.className : null,
    iconFontSize: cs ? cs.fontSize : null,
    iconColor: cs ? cs.color : null,
    cardTitle: card ? card.querySelector('h5').innerText : null
  };
  let d = document.createElement('div');
  d.id = 'ICON_VERIFY_DATA';
  d.textContent = JSON.stringify(info);
  document.body.appendChild(d);
});
</script>
"@
Set-Content -Path 'temp_about_verify.html' -Value ($aboutHtml.Replace('</body>', $aboutScript + '</body>')) -Encoding utf8

# 2. Shop Page (products.html) Light & Dark Wrappers
$prodHtml = Get-Content 'products.html' -Raw
$lightScript = @"
<script>
document.documentElement.setAttribute('data-theme', 'light');
try { localStorage.setItem('rug_store_theme', 'light'); } catch(e){}
</script>
"@
Set-Content -Path 'temp_shop_light.html' -Value ($prodHtml.Replace('<head>', "<head>`n" + $lightScript)) -Encoding utf8

$darkScript = @"
<script>
document.documentElement.setAttribute('data-theme', 'dark');
try { localStorage.setItem('rug_store_theme', 'dark'); } catch(e){}
</script>
"@
Set-Content -Path 'temp_shop_dark.html' -Value ($prodHtml.Replace('<head>', "<head>`n" + $darkScript)) -Encoding utf8

# 3. Home 2 Light & Dark Wrappers
$h2Html = Get-Content 'home-2.html' -Raw
Set-Content -Path 'temp_h2_light.html' -Value ($h2Html.Replace('<head>', "<head>`n" + $lightScript)) -Encoding utf8
Set-Content -Path 'temp_h2_dark.html' -Value ($h2Html.Replace('<head>', "<head>`n" + $darkScript)) -Encoding utf8

Write-Host "Capturing verification screenshots..."

$flags = @(
  '--headless=new',
  '--force-device-scale-factor=1',
  '--disable-features=msSmartScreenP3P,msSmartScreenProtection',
  '--no-first-run',
  '--no-default-browser-check'
)

# A. About Page with Restored Icon
& $edge $flags --window-size=1366,768 "--screenshot=$dir\About_guiding_values_icon.png" --dump-dom 'http://localhost:3000/temp_about_verify.html' | Out-Null
Write-Host "Captured: About_guiding_values_icon.png"

# B. Shop Page Centered Hero (Light & Dark)
& $edge $flags --window-size=1366,768 "--screenshot=$dir\Shop_hero_centered_light.png" --dump-dom 'http://localhost:3000/temp_shop_light.html' | Out-Null
Write-Host "Captured: Shop_hero_centered_light.png"

& $edge $flags --window-size=1366,768 "--screenshot=$dir\Shop_hero_centered_dark.png" --dump-dom 'http://localhost:3000/temp_shop_dark.html' | Out-Null
Write-Host "Captured: Shop_hero_centered_dark.png"

& $edge $flags --window-size=390,844 "--screenshot=$dir\Shop_hero_centered_mobile.png" --dump-dom 'http://localhost:3000/temp_shop_light.html' | Out-Null
Write-Host "Captured: Shop_hero_centered_mobile.png"

# C. Home 2 Light & Dark (Desktop, Mobile)
& $edge $flags --window-size=1366,768 "--screenshot=$dir\Home2_hero_light_desktop.png" --dump-dom 'http://localhost:3000/temp_h2_light.html' | Out-Null
Write-Host "Captured: Home2_hero_light_desktop.png"

& $edge $flags --window-size=390,844 "--screenshot=$dir\Home2_hero_light_mobile.png" --dump-dom 'http://localhost:3000/temp_h2_light.html' | Out-Null
Write-Host "Captured: Home2_hero_light_mobile.png"

# D. Home 1 Light Desktop & Mobile
& $edge $flags --window-size=1366,768 "--screenshot=$dir\Home1_hero_desktop.png" --dump-dom 'http://localhost:3000/index.html' | Out-Null
Write-Host "Captured: Home1_hero_desktop.png"

& $edge $flags --window-size=390,844 "--screenshot=$dir\Home1_hero_mobile.png" --dump-dom 'http://localhost:3000/index.html' | Out-Null
Write-Host "Captured: Home1_hero_mobile.png"

Write-Host "All verification screenshots captured successfully!"
