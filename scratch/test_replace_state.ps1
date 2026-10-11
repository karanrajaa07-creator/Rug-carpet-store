$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$testHtml = Join-Path $root "test_history_replace.html"
$content = @"
<!DOCTYPE html>
<html>
<body>
<div id="status">Testing</div>
<script>
try {
    const newUrl = new URL(window.location.href);
    newUrl.searchParams.set('size', 'small');
    window.history.replaceState({}, '', newUrl.toString());
    document.getElementById('status').textContent = 'REPLACE_STATE_SUCCESS';
} catch (e) {
    document.getElementById('status').textContent = 'REPLACE_STATE_ERROR: ' + e.name + ': ' + e.message;
}
</script>
</body>
</html>
"@
[System.IO.File]::WriteAllText($testHtml, $content, [System.Text.Encoding]::UTF8)
$url = "file:///" + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
$outFile = Join-Path $root "scratch\replace_state_out.txt"

$proc = Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--dump-dom',
    $url
) -NoNewWindow -PassThru -RedirectStandardOutput $outFile

$proc.WaitForExit(5000)
$res = Get-Content $outFile -Raw
if ($res -match '<div id="status">(.*?)</div>') {
    Write-Host "RESULT: $($matches[1])"
}
Remove-Item $testHtml -Force -ErrorAction SilentlyContinue
