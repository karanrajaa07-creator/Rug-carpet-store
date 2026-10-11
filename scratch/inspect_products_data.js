$root = (Get-Location).Path
$jsPath = Join-Path $root "assets\js\products.js"
$content = [System.IO.File]::ReadAllText($jsPath, [System.Text.Encoding]::UTF8)

# Extract products data using node or powershell regex
# Or run node script to inspect PRODUCTS_DATA
$nodeScript = @"
const fs = require('fs');
const code = fs.readFileSync('assets/js/products.js', 'utf8');

// Mock window
global.window = {};
eval(code);

console.log('Total Products:', window.PRODUCTS_DATA.length);
window.PRODUCTS_DATA.forEach(p => {
    console.log(`Product ${p.id}: ${p.name}`);
    console.log(`  image: ${p.image}`);
    console.log(`  gallery: ${JSON.stringify(p.gallery)}`);
    if (p.sizesData) {
        console.log(`  Small image: ${p.sizesData.small?.image} (exists: ${fs.existsSync(p.sizesData.small?.image)})`);
        console.log(`  Med   image: ${p.sizesData.medium?.image} (exists: ${fs.existsSync(p.sizesData.medium?.image)})`);
        console.log(`  Large image: ${p.sizesData.large?.image} (exists: ${fs.existsSync(p.sizesData.large?.image)})`);
        const allSame = (p.sizesData.small?.image === p.sizesData.medium?.image) && (p.sizesData.medium?.image === p.sizesData.large?.image);
        if (allSame) console.log(`  WARNING: All 3 tiers have the SAME image!`);
    }
});
"@
$nodeScriptPath = Join-Path $root "scratch\inspect_products_data.js"
[System.IO.File]::WriteAllText($nodeScriptPath, $nodeScript, [System.Text.Encoding]::UTF8)
