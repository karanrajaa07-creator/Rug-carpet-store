$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$testHtml = @'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Size Switch Test</title>
  <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
  <div id="homeBestSellersRow" class="row"></div>
  <script src="../assets/js/products.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      const row = document.getElementById('homeBestSellersRow');
      row.innerHTML = window.PRODUCTS_DATA.slice(0, 3).map(window.renderProductCard).join('');
      
      const results = [];
      [1, 2, 3].forEach(id => {
        const product = window.PRODUCTS_DATA.find(p => p.id === id);
        ['small', 'medium', 'large'].forEach(tier => {
          window.selectCardSize(id, tier);
          const img = document.getElementById('cardImg-' + id);
          const expectedImg = product.sizesData[tier].image;
          const label = document.getElementById('cardSizeLabel-' + id).textContent;
          const match = img.src.indexOf(expectedImg.replace('assets/images/products/', '')) !== -1;
          const labelMatch = label.indexOf(product.sizesData[tier].label) !== -1;
          results.push({ id, tier, match, expectedImg, actualSrc: img.src, labelMatch, label });
        });
      });
      window.__TEST_RESULTS__ = results;
      const resDiv = document.createElement('div');
      resDiv.id = 'results-dump';
      resDiv.textContent = JSON.stringify(results);
      document.body.appendChild(resDiv);
    });
  </script>
</body>
</html>
'@
Set-Content -Path 'scratch\test_size_switch.html' -Value $testHtml -Encoding utf8

$fileUrl = "file:///c:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/scratch/test_size_switch.html"
$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--dump-dom", "`"$fileUrl`"" -NoNewWindow -PassThru -RedirectStandardOutput "scratch\dom_out.txt"
$proc.WaitForExit(10000)

$content = Get-Content "scratch\dom_out.txt" -Raw
if ($content -match '<div id="results-dump"[^>]*>(.*?)</div>') {
    $matches[1] | ConvertFrom-Json | Format-Table -AutoSize
} else {
    Write-Host "Did not find results-dump in DOM output"
}
