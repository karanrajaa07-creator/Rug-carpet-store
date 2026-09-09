Add-Type -AssemblyName System.Drawing

$src = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\jute-loop-rug.jpg"
$outSmall = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\solstice-jute-detail-1.jpg"
$outLarge = "c:\Users\Karan\Downloads\Rug & Carpet Store\assets\images\products\solstice-jute-detail-2.jpg"

$bmp = [System.Drawing.Bitmap]::FromFile($src)
$w = $bmp.Width
$h = $bmp.Height

# 1. LARGE: Zoom in 1.25x so rug expands to fill almost 100% of the room/frame
$largeW = [int]($w * 0.8)
$largeH = [int]($h * 0.8)
$largeX = [int](($w - $largeW) * 0.5)
$largeY = [int](($h - $largeH) * 0.6)

$bmpLarge = New-Object System.Drawing.Bitmap($w, $h)
$gLarge = [System.Drawing.Graphics]::FromImage($bmpLarge)
$gLarge.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gLarge.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $w, $h)), (New-Object System.Drawing.Rectangle($largeX, $largeY, $largeW, $largeH)), [System.Drawing.GraphicsUnit]::Pixel)
$gLarge.Dispose()
$bmpLarge.Save($outLarge, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmpLarge.Dispose()

# 2. SMALL: Create smaller centered rug on expanded wood floor
# Rug bounds in original 1200x896:
# Center is approx (600, 520)
# Radius X is ~540, Radius Y is ~360
# Scale factor 0.70:
$scale = 0.70
$bmpSmall = New-Object System.Drawing.Bitmap($w, $h)
$gSmall = [System.Drawing.Graphics]::FromImage($bmpSmall)
$gSmall.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# First fill background with floor texture sampled from top/edges
# In jute-loop-rug, top 180px has window, plant, bench, and clean wood floor
$gSmall.DrawImage($bmp, 0, 0, $w, $h)

# Fill center floor with wood flooring sampled from bottom/top corners
# Let's clone wood floor samples:
$woodSample = $bmp.Clone((New-Object System.Drawing.Rectangle(0, 0, 400, 250)), $bmp.PixelFormat)
$woodSample2 = $bmp.Clone((New-Object System.Drawing.Rectangle(800, 0, 400, 250)), $bmp.PixelFormat)
$woodBottom = $bmp.Clone((New-Object System.Drawing.Rectangle(0, 700, 300, 196)), $bmp.PixelFormat)
$woodBottom2 = $bmp.Clone((New-Object System.Drawing.Rectangle(900, 700, 300, 196)), $bmp.PixelFormat)

# Texture tile/stretch floor over center:
$gSmall.DrawImage($woodSample, 0, 200, 600, 400)
$gSmall.DrawImage($woodSample2, 600, 200, 600, 400)
$gSmall.DrawImage($woodBottom, 0, 600, 600, 296)
$gSmall.DrawImage($woodBottom2, 600, 600, 600, 296)

# Extract circular/oval rug mask
$rugCrop = New-Object System.Drawing.Bitmap($w, $h)
$gCrop = [System.Drawing.Graphics]::FromImage($rugCrop)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(55, 135, 1090, 740)
$gCrop.SetClip($path)
$gCrop.DrawImage($bmp, 0, 0, $w, $h)
$gCrop.Dispose()

# Draw scaled down rug:
$targetW = [int]($w * $scale)
$targetH = [int]($h * $scale)
$targetX = [int](($w - $targetW) / 2)
$targetY = [int](($h - $targetH) / 2 + 30)

# Soft drop shadow under rug:
$shadowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$shadowPath.AddEllipse($targetX - 8, $targetY + 5, $targetW + 16, $targetH + 10)
$shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 0, 0, 0))
$gSmall.FillPath($shadowBrush, $shadowPath)
$shadowBrush.Dispose()

$gSmall.DrawImage($rugCrop, $targetX, $targetY, $targetW, $targetH)

$gSmall.Dispose()
$bmpSmall.Save($outSmall, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmpSmall.Dispose()
$rugCrop.Dispose()
$woodSample.Dispose()
$woodSample2.Dispose()
$woodBottom.Dispose()
$woodBottom2.Dispose()
$bmp.Dispose()
Write-Host "Created Solstice Small and Large"
