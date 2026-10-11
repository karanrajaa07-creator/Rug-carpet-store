$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$indexHtml = Join-Path $root 'products.html'
$testHtml = Join-Path $root 'test_console_theme.html'
$testLog = Join-Path $root 'scratch\test_console_theme_dom.txt'

$script = @'
<script>
window.testResults = {
    errors: [],
    initialTheme: null,
    afterToggleTheme: null,
    afterSecondToggleTheme: null,
    storedTheme: null
};

window.addEventListener('error', e => window.testResults.errors.push(e.message || String(e)));

window.addEventListener('load', () => {
    window.testResults.initialTheme = document.documentElement.getAttribute('data-theme');
    
    // Test theme toggle button click
    const toggleBtn = document.querySelector('[data-action="toggle-theme"]');
    if (toggleBtn) {
        toggleBtn.click();
        window.testResults.afterToggleTheme = document.documentElement.getAttribute('data-theme');
        window.testResults.storedTheme = localStorage.getItem('rug_store_theme');

        toggleBtn.click();
        window.testResults.afterSecondToggleTheme = document.documentElement.getAttribute('data-theme');
    }

    setTimeout(() => {
        const out = document.createElement('div');
        out.id = 'THEME_TOGGLE_TEST_RESULTS';
        out.textContent = JSON.stringify(window.testResults);
        document.body.appendChild(out);
    }, 500);
});
</script>
'@

$content = [System.IO.File]::ReadAllText($indexHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($testHtml, $content.Replace('</body>', $script + '</body>'), [System.Text.Encoding]::UTF8)
$url = 'file:///' + $testHtml.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

& $edge --headless=new --window-size="1280,800" --virtual-time-budget=2000 --dump-dom $url | Out-File $testLog -Encoding utf8
$dom = Get-Content $testLog -Raw
if ($dom -match '<div id="THEME_TOGGLE_TEST_RESULTS">(.*?)</div>') {
    Write-Host "Theme Results: $($matches[1])"
}
Remove-Item $testHtml -ErrorAction SilentlyContinue
Remove-Item $testLog -ErrorAction SilentlyContinue
