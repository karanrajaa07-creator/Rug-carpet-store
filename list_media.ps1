Add-Type -AssemblyName System.Drawing
$files = Get-ChildItem 'C:\Users\Karan\.gemini\antigravity-ide\brain\c8de55ca-87ee-4709-885a-19dcd416de20\.tempmediaStorage\*.jpg'
foreach ($f in $files) {
    try {
        $bmp = [System.Drawing.Bitmap]::FromFile($f.FullName)
        [PSCustomObject]@{
            Name = $f.Name
            Width = $bmp.Width
            Height = $bmp.Height
            Bytes = $f.Length
        }
        $bmp.Dispose()
    } catch {}
}
