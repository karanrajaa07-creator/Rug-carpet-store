$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$brainDir = "C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e"
$tempUserData = "C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e\edge_temp"

if (-not (Test-Path $tempUserData)) {
    New-Item -ItemType Directory -Path $tempUserData -Force | Out-Null
}

function Take-Screenshot($url, $file, $width, $height) {
    Write-Host "Capturing $file from $url at ${width}x${height}..."
    & $edge --headless --disable-gpu --user-data-dir="$tempUserData" --window-size="$width,$height" --screenshot="$brainDir\$file" "$url"
    Start-Sleep -Milliseconds 800
    Write-Host "Done: $file"
}

Take-Screenshot "http://localhost:3000/scratch/verify_values.html" "About_values_restored_icon.png" 1440 800
Take-Screenshot "http://localhost:3000/contact.html" "Contact_hero_light_verified.png" 1440 800
Take-Screenshot "http://localhost:3000/products.html" "Shop_hero_centered_desktop.png" 1440 800
Take-Screenshot "http://localhost:3000/index.html" "Home1_hero_1366x768.png" 1366 768
Take-Screenshot "http://localhost:3000/home-2.html" "Home2_hero_1366x768.png" 1366 768

Write-Host "All verified screenshots completed!"
