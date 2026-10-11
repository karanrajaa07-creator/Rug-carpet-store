$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$scratch = Join-Path $root 'scratch'
$previewHtml = Join-Path $scratch 'preview_materials.html'
$url = 'file:///' + $previewHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$tempFile = "C:\Users\Karan\temp_mobile_emu.png"
$destFile = Join-Path $scratch "preview_mobile_emulated.png"

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--window-size=375,812',
    '--user-agent="Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"',
    "--screenshot=$tempFile",
    $url
) -NoNewWindow -Wait

if (Test-Path $tempFile) {
    Copy-Item $tempFile $destFile -Force
    Remove-Item $tempFile -Force
    Write-Host "Captured preview_mobile_emulated.png: $((Get-Item $destFile).Length) bytes"
}
