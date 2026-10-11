$files = Get-ChildItem -Path "assets\images\products" -Filter "*.jpg"
$hashes = @{}
foreach ($f in $files) {
    $h = (Get-FileHash $f.FullName).Hash
    $hashes[$f.Name] = $h
}

$content = Get-Content "assets\js\products.js" -Raw
$pattern = 'id:\s*(\d+).*?name:\s*[\x27"]([^\x27"]+)[\x27"].*?image:\s*[\x27"]([^\x27"]+)[\x27"].*?gallery:\s*\[\s*[\x27"]([^\x27"]+)[\x27"],\s*[\x27"]([^\x27"]+)[\x27"],\s*[\x27"]([^\x27"]+)[\x27"]\s*\]'
$regex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$matches = $regex.Matches($content)

Write-Host "Found $($matches.Count) products in products.js regex"
foreach ($m in $matches) {
    $id = $m.Groups[1].Value
    $name = $m.Groups[2].Value
    $img = $m.Groups[3].Value
    $g0 = $m.Groups[4].Value
    $g1 = $m.Groups[5].Value
    $g2 = $m.Groups[6].Value

    $f0 = Split-Path $g0 -Leaf
    $f1 = Split-Path $g1 -Leaf
    $f2 = Split-Path $g2 -Leaf

    $h0 = $hashes[$f0]
    $h1 = $hashes[$f1]
    $h2 = $hashes[$f2]

    $same01 = ($h0 -eq $h1)
    $same02 = ($h0 -eq $h2)
    $same12 = ($h1 -eq $h2)

    Write-Host "Product ${id} - ${name}"
    Write-Host "  g0: $f0"
    Write-Host "  g1: $f1"
    Write-Host "  g2: $f2"
    if ($same01 -or $same02 -or $same12) {
        Write-Host "  IDENTICAL HASHES: same01=$same01, same02=$same02, same12=$same12"
    }
}
