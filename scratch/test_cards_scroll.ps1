$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path scratch).Path
$html = (Resolve-Path products.html).Path
$content = [System.IO.File]::ReadAllText($html, [System.Text.Encoding]::UTF8)

# Inject scroll to row 2
$scrollScript = @"
<script>
window.addEventListener('load', () => {
    setTimeout(() => {
        const card4 = document.getElementById('productCard-4') || document.querySelectorAll('.product-card')[3];
        if (card4) { card4.scrollIntoView({ behavior: 'instant', block: 'center' }); }
    }, 300);
});
</script>
"@

$testHtml = Join-Path (Get-Location).Path "test_cards_scroll.html"
$injected = $content.Replace('</body>', $scrollScript + '</body>')
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)

$tempPng = "C:\Users\Karan\temp_cards_scroll.png"
$destPng = Join-Path $scratch "cards_scroll_verified.png"

$encodedUrl = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2500',
    "--screenshot=$tempPng",
    '--window-size=1280,1000',
    $encodedUrl
) -NoNewWindow -Wait

if (Test-Path $tempPng) {
    Copy-Item $tempPng $destPng -Force
    Remove-Item $tempPng -Force
    Write-Host "Successfully captured cards_scroll_verified.png"
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
