$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$homeUrl = "file:///" + (Join-Path $root "index.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

# Capture element screenshot
$script = @"
<script>
window.addEventListener('load', () => {
    const sec = document.querySelector('section.py-5.reveal-on-scroll:has(.material-card)') || document.querySelectorAll('section.py-5')[3];
    if (sec) {
        sec.scrollIntoView();
    }
});
</script>
"@

$injected = [System.IO.File]::ReadAllText((Join-Path $root "index.html"), [System.Text.Encoding]::UTF8).Replace('</body>', $script + '</body>')
$testHtml = Join-Path $root "scratch\test_material_view.html"
[System.IO.File]::WriteAllText($testHtml, $injected, [System.Text.Encoding]::UTF8)
$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --window-size="1440,900" --screenshot=(Join-Path $root "scratch\mat_1440.png") $url
& $edge --headless=new --window-size="1200,900" --screenshot=(Join-Path $root "scratch\mat_1200.png") $url
& $edge --headless=new --window-size="992,900" --screenshot=(Join-Path $root "scratch\mat_992.png") $url
& $edge --headless=new --window-size="768,900" --screenshot=(Join-Path $root "scratch\mat_768.png") $url
& $edge --headless=new --window-size="375,900" --screenshot=(Join-Path $root "scratch\mat_375.png") $url

Write-Output "Screenshots captured."
Remove-Item $testHtml -ErrorAction SilentlyContinue
