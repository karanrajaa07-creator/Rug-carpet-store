$widths = @(1280, 1024, 768, 576, 360)
foreach ($w in $widths) {
    Write-Host "================ Width: $w ================"
    $file = "scratch\materials_dom_$w.txt"
    if (Test-Path $file) {
        $text = Get-Content $file -Raw
        if ($text -match '<div id="measureOutput">([\s\S]*?)</div>') {
            $json = $matches[1] | ConvertFrom-Json
            $json | ForEach-Object {
                [PSCustomObject]@{
                    Card = $_.title
                    X = $_.rect.x
                    Y = $_.rect.y
                    W = $_.rect.width
                    H = $_.rect.height
                    ParentX = $_.parentRect.x
                    ParentY = $_.parentRect.y
                    ParentW = $_.parentRect.width
                    ParentH = $_.parentRect.height
                    Classes = $_.parentClasses
                }
            } | Format-Table -AutoSize | Out-String | Write-Host
        } else {
            Write-Host "No measureOutput found in $file"
        }
    } else {
        Write-Host "File $file not found"
    }
}
