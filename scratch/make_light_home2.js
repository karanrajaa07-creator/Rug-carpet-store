const fs = require('fs');

let html = fs.readFileSync('home-2.html', 'utf8');

// Inject light theme script to guarantee data-theme is 'light'
const lightScript = `
<script>
document.documentElement.setAttribute('data-theme', 'light');
try { localStorage.setItem('rug_store_theme', 'light'); } catch(e){}
</script>
`;

fs.writeFileSync('temp_home2_light.html', html.replace('<head>', '<head>' + lightScript));
console.log('Created temp_home2_light.html');
