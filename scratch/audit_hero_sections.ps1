$root = (Get-Location).Path
$files = Get-ChildItem -Path $root -Filter *.html | Where-Object { $_.Name -ne 'test_runner.html' }

$report = @()

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    
    # Look for hero or page-hero-banner sections
    $heroSection = ""
    $heroClass = ""
    $heroTag = ""
    
    # Regex for section or div after header
    if ($content -match '(?si)(<(section|div)[^>]*?(hero|page-hero|banner|page-title)[^>]*?>.*?</\2>)') {
        $heroTag = $matches[1]
        if ($heroTag -match 'class=["'']([^"'']+)["'']') {
            $heroClass = $matches[1]
        }
    } elseif ($content -match '(?si)(<header[^>]*?class=["''][^"'']*?hero[^"'']*?["''][^>]*?>.*?</header>)') {
        $heroTag = $matches[1]
        if ($heroTag -match 'class=["'']([^"'']+)["'']') {
            $heroClass = $matches[1]
        }
    }
    
    # Also check first section after header
    $firstSection = ""
    if ($content -match '(?si)</header>\s*(<(section|div)[^>]*?>)') {
        $firstSection = $matches[1]
    }
    
    $report += [PSCustomObject]@{
        File = $f.Name
        HeroClass = $heroClass
        FirstSectionAfterHeader = $firstSection
        HasExplicitHero = ($heroClass -ne "")
    }
}

$report | Format-Table -AutoSize | Out-String | Write-Output
