$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$tempFile = "C:\Users\Karan\temp_mat.png"
$dest = Join-Path $root "scratch\material_section_desktop.png"

$tempHtml = Join-Path $root "temp_scroll_mat.html"
$htmlContent = [System.IO.File]::ReadAllText((Join-Path $root "index.html"), [System.Text.Encoding]::UTF8)
$scrollScript = @"
<script>
window.addEventListener('load', () => {
    const heading = Array.from(document.querySelectorAll('h2')).find(h => h.textContent.includes('Shop by Material'));
    if (heading) {
        heading.closest('section').scrollIntoView({ block: 'start' });
    }
});
</script>
"@
$htmlWithScroll = $htmlContent.Replace('</body>', $scrollScript + '</body>')
[System.IO.File]::WriteAllText($tempHtml, $htmlWithScroll, [System.Text.Encoding]::UTF8)
$tempUrl = "file:///" + $tempHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2000',
    '--window-size=1280,900',
    "--screenshot=$tempFile",
    $tempUrl
) -NoNewWindow -Wait

if (Test-Path $tempFile) {
    Copy-Item $tempFile $dest -Force
    Remove-Item $tempFile -Force
    Write-Host "Success: $dest"
} else {
    Write-Host "Failed to create temp screenshot"
}
Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
