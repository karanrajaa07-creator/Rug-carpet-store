$files = Get-ChildItem -Path . -Recurse -Include *.html,*.js,*.css
foreach ($f in $files) {
    if ($f.FullName -like "*\scratch\*") { continue }
    $m = Select-String -Path $f.FullName -Pattern 'shopping'
    if ($m) {
        foreach ($match in $m) {
            Write-Host "$($f.Name):$($match.LineNumber): $($match.Line.Trim())"
        }
    }
}
