foreach ($w in @(1440, 1280, 1024, 992, 768, 576, 375)) {
    Write-Host "=== WIDTH $w ==="
    $f = "scratch\root_res_$w.txt"
    if (Test-Path $f) {
        $t = Get-Content $f -Raw
        if ($t -match '<div id="ROOT_MEASURE_RES">([\s\S]*?)</div>') {
            $matches[1] | ConvertFrom-Json | Format-Table -AutoSize | Out-String | Write-Host
        } else {
            Write-Host "No ROOT_MEASURE_RES"
        }
    } else {
        Write-Host "File not found"
    }
}
