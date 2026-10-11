$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root 'scratch'

$indexHtml = Join-Path $root 'index.html'
$content = [System.IO.File]::ReadAllText($indexHtml, [System.Text.Encoding]::UTF8)

# Inject override to ensure full visibility without scroll delay or transition opacity
$injectedStyle = @"
<style>
* {
    transition: none !important;
    animation: none !important;
}
.reveal-on-scroll, .reveal-stagger, .reveal-stagger > * {
    opacity: 1 !important;
    transform: none !important;
    visibility: visible !important;
}
</style>
<script>
window.addEventListener('load', () => {
    document.querySelectorAll('.reveal-on-scroll, .reveal-stagger').forEach(el => el.classList.add('is-revealed'));
    const sec = Array.from(document.querySelectorAll('h2')).find(h => h.textContent.includes('Shop by Material'))?.closest('section');
    if (sec) {
        sec.scrollIntoView({ behavior: 'instant', block: 'start' });
    }
});
</script>
"@

$testHtml = Join-Path $root 'test_verified_visual.html'
[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $injectedStyle + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$viewports = @(
    @{ Name = "desktop_1440"; W = 1440; H = 800 },
    @{ Name = "desktop_1280"; W = 1280; H = 800 },
    @{ Name = "desktop_1024"; W = 1024; H = 850 },
    @{ Name = "tablet_768";   W = 768;  H = 900 },
    @{ Name = "mobile_375";   W = 375;  H = 950 }
)

foreach ($vp in $viewports) {
    $tempFile = "C:\Users\Karan\temp_shot_$($vp.Name).png"
    $destFile = Join-Path $scratch "verified_$($vp.Name).png"
    
    Start-Process -FilePath $edge -ArgumentList @(
        '--headless=new',
        '--virtual-time-budget=2000',
        "--window-size=$($vp.W),$($vp.H)",
        "--screenshot=$tempFile",
        $url
    ) -NoNewWindow -Wait
    
    if (Test-Path $tempFile) {
        Copy-Item $tempFile $destFile -Force
        Remove-Item $tempFile -Force
        Write-Host "Captured verified_$($vp.Name).png: $((Get-Item $destFile).Length) bytes"
    } else {
        Write-Host "Failed to capture $($vp.Name)"
    }
}

Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
