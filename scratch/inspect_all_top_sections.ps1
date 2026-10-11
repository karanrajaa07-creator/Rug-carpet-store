$root = (Get-Location).Path
$files = @(
    "404.html", "about.html", "blog-details.html", "blog.html", "care-guide.html",
    "checkout.html", "coming-soon.html", "contact.html", "custom-sizing.html",
    "home-2.html", "index.html", "login.html", "maintenance.html", "pricing.html",
    "product-details.html", "products.html", "register.html", "service-details.html",
    "services.html", "wishlist.html"
)

foreach ($fn in $files) {
    $path = Join-Path $root $fn
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    
    # Extract from </header> to the second <section or 20 lines
    $headerIdx = $content.IndexOf("</header>")
    if ($headerIdx -ge 0) {
        $snippet = $content.Substring($headerIdx, [Math]::Min(1200, $content.Length - $headerIdx))
        Write-Output "=================================================="
        Write-Output "PAGE: $fn"
        Write-Output "=================================================="
        # Print first 25 lines of snippet
        $lines = $snippet -split "`r?`n" | Select-Object -First 20
        $lines | ForEach-Object { Write-Output $_ }
    } else {
        # Pages without header (e.g. 404, coming-soon, maintenance, login, register)
        Write-Output "=================================================="
        Write-Output "PAGE: $fn (NO </header>)"
        Write-Output "=================================================="
        $lines = $content -split "`r?`n" | Select-Object -First 25
        $lines | ForEach-Object { Write-Output $_ }
    }
}
