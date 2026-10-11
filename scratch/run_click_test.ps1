$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$root = (Get-Location).Path
$html = Join-Path $root "index.html"
$url = "file:///" + $html.Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')

$testScript = @"
<!DOCTYPE html>
<html>
<body>
<iframe id='testFrame' src='$url' style='width:1280px;height:900px;'></iframe>
<script>
window.addEventListener('message', (e) => {});
const frame = document.getElementById('testFrame');
frame.onload = function() {
    setTimeout(() => {
        try {
            const doc = frame.contentDocument || frame.contentWindow.document;
            const card1 = doc.getElementById('productCard-1');
            console.log('Card 1 exists:', !!card1);
            if (card1) {
                const imgBefore = doc.getElementById('cardImg-1').src;
                const priceBefore = doc.getElementById('cardPrice-1').textContent;
                const sizeLabelBefore = doc.getElementById('cardSizeLabel-1').textContent;
                
                // Find small button
                const smallBtn = card1.querySelector('[data-tier="small"]');
                console.log('Small button exists:', !!smallBtn);
                if (smallBtn) {
                    smallBtn.click();
                    const imgAfter = doc.getElementById('cardImg-1').src;
                    const priceAfter = doc.getElementById('cardPrice-1').textContent;
                    const sizeLabelAfter = doc.getElementById('cardSizeLabel-1').textContent;
                    
                    document.body.setAttribute('data-result', JSON.stringify({
                        imgBefore: imgBefore,
                        imgAfter: imgAfter,
                        priceBefore: priceBefore,
                        priceAfter: priceAfter,
                        sizeLabelBefore: sizeLabelBefore,
                        sizeLabelAfter: sizeLabelAfter
                    }));
                }
            }
        } catch(e) {
            document.body.setAttribute('data-error', e.toString());
        }
    }, 1500);
};
</script>
</body>
</html>
"@

Set-Content -Path "scratch\test_click_index.html" -Value $testScript -Encoding UTF8
Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--dump-dom',
    "file:///" + (Join-Path $root "scratch\test_click_index.html").Replace('\', '/').Replace(' ', '%20').Replace('&', '%26')
) -NoNewWindow -Wait
