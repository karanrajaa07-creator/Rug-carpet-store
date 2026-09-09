Add-Type -AssemblyName System.Drawing

function Get-ImageSimilarity($file1, $file2) {
  if (-not (Test-Path $file1) -or -not (Test-Path $file2)) { return -1 }
  $f1 = Get-Item $file1
  $f2 = Get-Item $file2
  if ($f1.Length -eq $f2.Length -and (Get-FileHash $file1).Hash -eq (Get-FileHash $file2).Hash) {
    return 100 # exact file duplicate
  }
  $b1 = [System.Drawing.Bitmap]::FromFile($f1.FullName)
  $b2 = [System.Drawing.Bitmap]::FromFile($f2.FullName)
  $diffCount = 0
  $totalSamples = 100
  for ($i = 0; $i -lt $totalSamples; $i++) {
    $x = [int](($b1.Width - 1) * ($i / 100.0))
    $y = [int](($b1.Height - 1) * ($i / 100.0))
    $x2 = [int](($b2.Width - 1) * ($i / 100.0))
    $y2 = [int](($b2.Height - 1) * ($i / 100.0))
    $c1 = $b1.GetPixel($x, $y)
    $c2 = $b2.GetPixel($x2, $y2)
    if ([Math]::Abs($c1.R - $c2.R) -gt 10 -or [Math]::Abs($c1.G - $c2.G) -gt 10 -or [Math]::Abs($c1.B - $c2.B) -gt 10) {
      $diffCount++
    }
  }
  $b1.Dispose()
  $b2.Dispose()
  return (100 - $diffCount) # 100 means almost identical pixels
}

$js = Get-Content 'assets/js/products.js' -Raw

# Extract PRODUCTS_DATA JSON-like or evaluate via node or regex
# Let's inspect each product's 3 gallery images
$galleryMap = @{
  1 = @('isfahan-silk-detail-1.jpg', 'isfahan-silk-rug.jpg', 'isfahan-silk-detail-2.jpg')
  2 = @('atlas-berber-detail-1.jpg', 'atlas-berber-rug.jpg', 'atlas-berber-detail-2.jpg')
  3 = @('nordic-geometric-detail-1.jpg', 'nordic-geometric-rug.jpg', 'nordic-geometric-detail-2.jpg')
  4 = @('oushak-runner-detail-1.jpg', 'oushak-runner-rug.jpg', 'oushak-runner-detail-2.jpg')
  5 = @('kyoto-jute-detail-1.jpg', 'braided-jute-carpet.jpg', 'kyoto-jute-detail-2.jpg')
  6 = @('bauhaus-geometric-detail-1.jpg', 'bauhaus-geometric-rug.jpg', 'bauhaus-geometric-detail-2.jpg')
  7 = @('caspian-silk-detail-1.jpg', 'caspian-silk-rug.jpg', 'caspian-silk-detail-2.jpg')
  8 = @('santorini-outdoor-detail-1.jpg', 'santorini-outdoor-terrace-rug.jpg', 'santorini-outdoor-detail-2.jpg')
  9 = @('anatolian-vintage-detail-1.jpg', 'anatolian-vintage-rug.jpg', 'anatolian-vintage-detail-2.jpg')
  10 = @('jaipur-cotton-detail-1.jpg', 'handwoven-kilim-rug.jpg', 'jaipur-cotton-detail-2.jpg')
  11 = @('moroccan-runner-detail-1.jpg', 'moroccan-diamond-runner.jpg', 'moroccan-runner-detail-2.jpg')
  12 = @('solstice-jute-detail-1.jpg', 'jute-loop-rug.jpg', 'solstice-jute-detail-2.jpg')
  13 = @('amalfi-veranda-detail-1.jpg', 'amalfi-veranda-outdoor-rug.jpg', 'amalfi-veranda-detail-2.jpg')
  14 = @('scandinavian-cotton-detail-1.jpg', 'scandinavian-cotton-medium.jpg', 'scandinavian-cotton-detail-2.jpg')
  15 = @('manhattan-velvet-detail-1.jpg', 'manhattan-velvet-carpet.jpg', 'manhattan-velvet-detail-2.jpg')
}

$dir = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products"

foreach ($id in (1..15)) {
  $imgs = $galleryMap[$id]
  $s = Join-Path $dir $imgs[0]
  $m = Join-Path $dir $imgs[1]
  $l = Join-Path $dir $imgs[2]

  $sim_sm = Get-ImageSimilarity $s $m
  $sim_ml = Get-ImageSimilarity $m $l
  $sim_sl = Get-ImageSimilarity $s $l

  $status = "OK"
  if ($sim_sm -ge 95 -or $sim_ml -ge 95 -or $sim_sl -ge 95) {
    $status = "DUPLICATE_OR_NEAR_IDENTICAL"
  }
  Write-Output ('Prod {0,2}: S={1}, M={2}, L={3} -> Status={4} (Sim SM={5}%, ML={6}%, SL={7}%)' -f $id, (Test-Path $s), (Test-Path $m), (Test-Path $l), $status, $sim_sm, $sim_ml, $sim_sl)
}
