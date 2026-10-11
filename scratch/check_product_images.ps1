$root = (Get-Location).Path
$jsPath = Join-Path $root "assets\js\products.js"
$content = [System.IO.File]::ReadAllText($jsPath, [System.Text.Encoding]::UTF8)

$galleryMatches = [regex]::Matches($content, "gallery:\s*\[([\s\S]*?)\]")
$missingCount = 0
$totalCount = 0

foreach ($gm in $galleryMatches) {
    $lines = $gm.Groups[1].Value -split "\n"
    foreach ($l in $lines) {
        $clean = $l.Trim().Trim(',').Trim('"').Trim("'")
        if ($clean.Length -gt 0) {
            $totalCount++
            $fullPath = Join-Path $root ($clean.Replace('/', '\'))
            if (-not (Test-Path $fullPath)) {
                Write-Host "MISSING IMAGE: $clean"
                $missingCount++
            } else {
                Write-Host "FOUND: $clean"
            }
        }
    }
}

Write-Host "Total images checked: $totalCount, Missing: $missingCount"
