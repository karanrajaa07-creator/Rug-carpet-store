$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url = 'file:///c:/Users/Karan/Downloads/Rug%20&%20Carpet%20Store/test_runner.html'
$screenshotPath = 'C:\Users\Karan\.gemini\antigravity-ide\brain\c8de55ca-87ee-4709-885a-19dcd416de20\test_suite_results.png'

$process = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--screenshot=$screenshotPath", "--window-size=1280,1800", "--dump-dom", "$url" -NoNewWindow -PassThru -RedirectStandardOutput "test_output.txt" -RedirectStandardError "test_err.txt"
$process.WaitForExit(15000)

$content = Get-Content "test_output.txt" -Raw
Write-Host "=== TEST RUNNER SUMMARY ==="
if ($content -match '<div id="testSummary"[^>]*>(.*?)</div>') {
    Write-Host "Summary: $($matches[1])"
}
$failures = [regex]::Matches($content, '<li class="test-fail">([^<]+)')
if ($failures.Count -gt 0) {
    Write-Host "FAILURES FOUND ($($failures.Count)):"
    foreach ($f in $failures) {
        Write-Host " - $($f.Groups[1].Value)"
    }
} else {
    Write-Host "NO FAILURES! ALL TESTS PASSED!"
}
$passes = [regex]::Matches($content, '<li class="test-pass">([^<]+)')
Write-Host "Total Passed Tests: $($passes.Count)"
