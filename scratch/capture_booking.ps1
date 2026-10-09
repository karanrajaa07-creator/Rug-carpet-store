$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$scratch = (Resolve-Path scratch).Path
$tempFile = "C:\Users\Karan\temp_contact_booking.png"
$destFile = Join-Path $scratch "contact_booking.png"

$html = (Resolve-Path contact.html).Path
$content = Get-Content $html -Raw
# inject script to scroll down to showroomBooking
$scrollScript = @"
<script>
window.addEventListener('DOMContentLoaded', () => {
    const el = document.getElementById('showroomBooking') || document.querySelector('input[type="date"]');
    if (el) {
        el.scrollIntoView({ behavior: 'instant', block: 'center' });
    }
});
</script>
"@
$injected = $content.Replace('</body>', $scrollScript + '</body>')
$tempHtml = "C:\Users\Karan\temp_contact_scroll.html"
Set-Content $tempHtml $injected -Encoding UTF8

Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=2000',
    "--screenshot=$tempFile",
    '--window-size=1024,800',
    'file:///C:/Users/Karan/temp_contact_scroll.html'
) -NoNewWindow -Wait

if (Test-Path $tempFile) {
    Copy-Item $tempFile $destFile -Force
    Remove-Item $tempFile -Force
    Write-Host "Captured booking section"
}

Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
