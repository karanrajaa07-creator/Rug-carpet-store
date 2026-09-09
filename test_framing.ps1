Add-Type -AssemblyName System.Drawing

$src = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\anatolian-vintage-rug.jpg"
$out = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\anatolian-vintage-detail-2.jpg"

$bmp = [System.Drawing.Bitmap]::FromFile($src)
$w = $bmp.Width
$h = $bmp.Height

# For LARGE: zoom in slightly so the rug expands and fills the floor/room much more dramatically
# In anatolian-vintage-rug, the rug is centered. If we crop 82% of the frame centered around the rug and scale to full 1200x896:
$cropW = [int]($w * 0.82)
$cropH = [int]($h * 0.82)
$cropX = [int](($w - $cropW) * 0.45) # slightly towards bottom-center where rug sits
$cropY = [int](($h - $cropH) * 0.65)

$res = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($res)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)

$g.DrawImage($bmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$g.Dispose()
$res.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$res.Dispose()
$bmp.Dispose()
Write-Host "Created Anatolian Large image"
