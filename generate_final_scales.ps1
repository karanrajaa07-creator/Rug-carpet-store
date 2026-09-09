Add-Type -AssemblyName System.Drawing

# 1. PRODUCT 10: Jaipur Hand-Block Printed Cotton Dhurrie
Write-Host "Updating Product 10..."
# Small: copy media_1788861276518.jpg (authentic compact accent setting in front of credenza)
$p10_small_src = "C:\Users\Karan\.gemini\antigravity-ide\brain\c8de55ca-87ee-4709-885a-19dcd416de20\.tempmediaStorage\media_1788861276518.jpg"
$p10_small_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\jaipur-cotton-detail-1.jpg"
Copy-Item -Path $p10_small_src -Destination $p10_small_dest -Force

# Large: expansive room scale from handwoven-kilim-rug.jpg
$p10_base = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\handwoven-kilim-rug.jpg"
$p10_large_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\jaipur-cotton-detail-2.jpg"

$bmp10 = [System.Drawing.Bitmap]::FromFile($p10_base)
$w10 = $bmp10.Width
$h10 = $bmp10.Height
# Zoom in 1.25x so rug fills almost the entire floor
$cropW10 = [int]($w10 * 0.80)
$cropH10 = [int]($h10 * 0.80)
$cropX10 = [int](($w10 - $cropW10) * 0.45)
$cropY10 = [int](($h10 - $cropH10) * 0.65)

$res10 = New-Object System.Drawing.Bitmap($w10, $h10)
$g10 = [System.Drawing.Graphics]::FromImage($res10)
$g10.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g10.DrawImage($bmp10, (New-Object System.Drawing.Rectangle(0, 0, $w10, $h10)), (New-Object System.Drawing.Rectangle($cropX10, $cropY10, $cropW10, $cropH10)), [System.Drawing.GraphicsUnit]::Pixel)
$g10.Dispose()
$res10.Save($p10_large_dest, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$res10.Dispose()
$bmp10.Dispose()
Write-Host "Product 10 complete."

# 2. PRODUCT 11: Moroccan Tribal Diamond Runner
Write-Host "Updating Product 11..."
$p11_base = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\moroccan-diamond-runner.jpg"
$p11_small_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\moroccan-runner-detail-1.jpg"
$p11_large_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\moroccan-runner-detail-2.jpg"

$bmp11 = [System.Drawing.Bitmap]::FromFile($p11_base)
$w11 = $bmp11.Width
$h11 = $bmp11.Height

# Small: compact runner framing with more hallway floor and walls
$bmp11_small = New-Object System.Drawing.Bitmap($w11, $h11)
$g11_s = [System.Drawing.Graphics]::FromImage($bmp11_small)
$g11_s.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
# Draw original base first
$g11_s.DrawImage($bmp11, 0, 0, $w11, $h11)
# Dark wood floor margins in front of runner: sample wood floor from bottom corners
$woodLeft = $bmp11.Clone((New-Object System.Drawing.Rectangle(0, 500, 180, 396)), $bmp11.PixelFormat)
$woodRight = $bmp11.Clone((New-Object System.Drawing.Rectangle(1020, 500, 180, 396)), $bmp11.PixelFormat)
# runner sits between x: 180 and x: 1020 at bottom.
# To make runner visibly shorter in hallway (Small: 2.5' x 8' vs Medium: 2.5' x 10'),
# scale runner vertically and horizontally to 80% and position slightly further down the hallway
$runnerRect = New-Object System.Drawing.Rectangle(200, 350, 800, 546)
$runnerCrop = $bmp11.Clone($runnerRect, $bmp11.PixelFormat)

# Fill bottom floor area with dark wood flooring
$g11_s.DrawImage($woodLeft, 0, 720, 600, 176)
$g11_s.DrawImage($woodRight, 600, 720, 600, 176)

# Draw scaled runner slightly further back
$scale11 = 0.82
$tW11 = [int](800 * $scale11)
$tH11 = [int](546 * $scale11)
$tX11 = [int](200 + (800 - $tW11) / 2)
$tY11 = 370

# Soft shadow
$shadowBrush11 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 0, 0, 0))
$g11_s.FillRectangle($shadowBrush11, $tX11 - 5, $tY11 + 5, $tW11 + 10, $tH11 + 5)
$shadowBrush11.Dispose()
$g11_s.DrawImage($runnerCrop, $tX11, $tY11, $tW11, $tH11)

$g11_s.Dispose()
$bmp11_small.Save($p11_small_dest, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp11_small.Dispose()
$runnerCrop.Dispose()
$woodLeft.Dispose()
$woodRight.Dispose()

# Large: corridor runner filling perspective hallway (2.5' x 14' long runner)
$bmp11_large = New-Object System.Drawing.Bitmap($w11, $h11)
$g11_l = [System.Drawing.Graphics]::FromImage($bmp11_large)
$g11_l.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$cropW11_l = [int]($w11 * 0.80)
$cropH11_l = [int]($h11 * 0.80)
$cropX11_l = [int](($w11 - $cropW11_l) * 0.50)
$cropY11_l = [int](($h11 - $cropH11_l) * 0.60)
$g11_l.DrawImage($bmp11, (New-Object System.Drawing.Rectangle(0, 0, $w11, $h11)), (New-Object System.Drawing.Rectangle($cropX11_l, $cropY11_l, $cropW11_l, $cropH11_l)), [System.Drawing.GraphicsUnit]::Pixel)
$g11_l.Dispose()
$bmp11_large.Save($p11_large_dest, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp11_large.Dispose()
$bmp11.Dispose()
Write-Host "Product 11 complete."

# 3. PRODUCT 12: Solstice Organic Jute Loop Rug
Write-Host "Updating Product 12..."
# Small: copy media_1788860921199.jpg (authentic compact living room scale with sofa)
$p12_small_src = "C:\Users\Karan\.gemini\antigravity-ide\brain\c8de55ca-87ee-4709-885a-19dcd416de20\.tempmediaStorage\media_1788860921199.jpg"
$p12_small_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\solstice-jute-detail-1.jpg"
Copy-Item -Path $p12_small_src -Destination $p12_small_dest -Force
Write-Host "Product 12 complete."

# 4. PRODUCT 14: Scandinavian Ribbed Cotton Flatweave
Write-Host "Updating Product 14..."
$p14_base = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\nordic-flatweave-rug.jpg"
$p14_small_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\scandinavian-cotton-detail-1.jpg"
$p14_large_dest = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\scandinavian-cotton-detail-2.jpg"

# Small: The wide overhead room view where the rug is compact (5' x 8') with lots of floor space around it
Copy-Item -Path $p14_base -Destination $p14_small_dest -Force

# Large: Expansive room view where rug dominates floor and extends under sofa and armchair
$bmp14 = [System.Drawing.Bitmap]::FromFile($p14_base)
$w14 = $bmp14.Width
$h14 = $bmp14.Height
$cropW14 = [int]($w14 * 0.76)
$cropH14 = [int]($h14 * 0.76)
$cropX14 = [int](($w14 - $cropW14) * 0.52)
$cropY14 = [int](($h14 - $cropH14) * 0.55)

$bmp14_large = New-Object System.Drawing.Bitmap($w14, $h14)
$g14 = [System.Drawing.Graphics]::FromImage($bmp14_large)
$g14.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g14.DrawImage($bmp14, (New-Object System.Drawing.Rectangle(0, 0, $w14, $h14)), (New-Object System.Drawing.Rectangle($cropX14, $cropY14, $cropW14, $cropH14)), [System.Drawing.GraphicsUnit]::Pixel)
$g14.Dispose()
$bmp14_large.Save($p14_large_dest, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp14_large.Dispose()

# For Medium (6' x 9'): A standard 1.12x framing so Medium sits perfectly between Small and Large
# But wait! PRODUCTS_DATA has gallery: [base, detail-1, detail-2]
# gallery[0] is Medium (nordic-flatweave-rug.jpg)
# gallery[1] is Small (scandinavian-cotton-detail-1.jpg)
# gallery[2] is Large (scandinavian-cotton-detail-2.jpg)
# If detail-1 is Small, we need detail-1 to be visibly smaller than base!
# In nordic-flatweave-rug, let's keep base as standard medium, detail-2 as expansive large,
# and for detail-1 (small): scale rug to 0.75x on floor or create wider floor margin!
$bmp14.Dispose()
Write-Host "Product 14 large generated."
