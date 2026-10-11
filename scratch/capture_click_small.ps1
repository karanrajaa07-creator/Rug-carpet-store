$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$artifactDir = "C:\Users\Karan\.gemini\antigravity-ide\brain\1238d468-beab-4358-a7b9-a2f6826e8741"

$srcHtml = Join-Path $root "product-details.html"
$content = [System.IO.File]::ReadAllText($srcHtml, [System.Text.Encoding]::UTF8)

$interactScript = @"
<script>
window.addEventListener('load', () => {
  setTimeout(() => {
    const btn = document.getElementById('sizeBtn-small');
    if (btn) btn.click();
  }, 400);
});
</script>
"@

$tempFile = Join-Path $root "temp_click_small.html"
$injected = $content.Replace('</body>', $interactScript + '</body>')
[System.IO.File]::WriteAllText($tempFile, $injected, [System.Text.Encoding]::UTF8)

$url = "file:///" + $tempFile.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26') + "?id=1"
$outPath = Join-Path $artifactDir "pd_small_desktop.png"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--window-size=1280,900',
    '--virtual-time-budget=4000',
    "--screenshot=$outPath",
    $url
) -NoNewWindow -PassThru

$proc.WaitForExit(10000)
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Output "pd_small_desktop captured: $((Get-Item $outPath).Length) bytes"
