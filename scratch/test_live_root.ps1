$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$pdPath = (Join-Path $root "product-details.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$url = "file:///" + $pdPath + "?id=1"
$outFile = Join-Path $root "scratch\test_root_pd_out.html"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=4000',
    '--dump-dom',
    $url
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(10000)
$content = Get-Content $outFile -Raw
Write-Output "Dumped DOM Length: $($content.Length)"

# Let's inspect the buttons in dumped DOM
if ($content -match 'id="sizeBtn-small"[^>]*>') {
    Write-Output "Found sizeBtn-small: $($matches[0])"
}
if ($content -match 'id="mainProductImage"[^>]*>') {
    Write-Output "Found mainProductImage: $($matches[0])"
}
if ($content -match 'id="pdRoomScaleBar"[^>]*>(.*?)</div>') {
    Write-Output "pdRoomScaleBar: $($matches[1].Substring(0, [Math]::Min(200, $matches[1].Length)))"
}
