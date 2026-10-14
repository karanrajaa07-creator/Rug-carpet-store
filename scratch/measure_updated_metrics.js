const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';

const viewports = [
  { name: 'desktop_1920x1080', w: 1920, h: 1080 },
  { name: 'desktop_1440x900',  w: 1440, h: 900 },
  { name: 'desktop_1366x768',  w: 1366, h: 768 },
  { name: 'desktop_1280x800',  w: 1280, h: 800 },
  { name: 'tablet_768x1024',   w: 768,  h: 1024 },
  { name: 'mobile_390x844',    w: 390,  h: 844 },
  { name: 'mobile_375x667',    w: 375,  h: 667 }
];

const pages = [
  { file: 'index.html', heroClass: '.hero-home-1' },
  { file: 'home-2.html', heroClass: '.hero-home-2' }
];

const results = [];

for (const page of pages) {
  const originalHtml = fs.readFileSync(page.file, 'utf8');
  
  // Inject sync evaluation script before </body>
  const injectScript = `
  <script>
    (function() {
      const header = document.querySelector('.site-header');
      const hero = document.querySelector('${page.heroClass}');
      const hRect = header ? header.getBoundingClientRect() : null;
      const heroRect = hero ? hero.getBoundingClientRect() : null;
      const docW = document.documentElement.scrollWidth;
      const winW = window.innerWidth;
      const winH = window.innerHeight;
      
      const title = hero ? (hero.querySelector('.hero-title') || hero.querySelector('.hero-title-h2') || hero.querySelector('h1')) : null;
      const tRect = title ? title.getBoundingClientRect() : null;
      const lead = hero ? hero.querySelector('.hero-lead') : null;
      const lRect = lead ? lead.getBoundingClientRect() : null;
      const btnGroup = hero ? (hero.querySelector('.hero-btn-group') || hero.querySelector('.d-flex.flex-wrap')) : null;
      const bRect = btnGroup ? btnGroup.getBoundingClientRect() : null;
      const metrics = hero ? hero.querySelector('.hero-metrics-strip') : null;
      const mRect = metrics ? metrics.getBoundingClientRect() : null;
      const img = hero ? hero.querySelector('img') : null;
      const iRect = img ? img.getBoundingClientRect() : null;

      const heroPaddingTop = hero ? parseFloat(window.getComputedStyle(hero).paddingTop) : 0;
      const heroPaddingBottom = hero ? parseFloat(window.getComputedStyle(hero).paddingBottom) : 0;

      const info = {
        viewportW: winW,
        viewportH: winH,
        hasHorizontalOverflow: docW > winW,
        scrollWidth: docW,
        headerHeight: hRect ? Math.round(hRect.height) : 0,
        hero: heroRect ? {
          top: Math.round(heroRect.top),
          bottom: Math.round(heroRect.bottom),
          height: Math.round(heroRect.height),
          paddingTop: Math.round(heroPaddingTop),
          paddingBottom: Math.round(heroPaddingBottom),
          fitsInInitialViewport: heroRect.bottom <= winH,
          overflowBeyondViewport: Math.round(heroRect.bottom - winH)
        } : null,
        titleBottom: tRect ? Math.round(tRect.bottom) : null,
        leadBottom: lRect ? Math.round(lRect.bottom) : null,
        buttonsBottom: bRect ? Math.round(bRect.bottom) : null,
        buttonsFitsInViewport: bRect ? bRect.bottom <= winH : true,
        metricsBottom: mRect ? Math.round(mRect.bottom) : null,
        imgHeight: iRect ? Math.round(iRect.height) : null
      };

      const out = document.createElement('div');
      out.id = 'DIAGNOSTIC_METRICS';
      out.setAttribute('data-results', JSON.stringify(info));
      document.body.appendChild(out);
    })();
  </script>
  `;

  // Write to a temporary file in user directory to avoid path ampersand issue in Edge CLI
  const tempHtmlPath = 'C:\\Users\\Karan\\temp_measure.html';
  fs.writeFileSync(tempHtmlPath, originalHtml.replace('</body>', injectScript + '</body>'), 'utf8');
  const fileUrl = 'file:///C:/Users/Karan/temp_measure.html';

  for (const vp of viewports) {
    try {
      const output = execSync(`"${edgePath}" --headless=new --dump-dom --window-size=${vp.w},${vp.h} "${fileUrl}"`, {
        maxBuffer: 10 * 1024 * 1024,
        timeout: 15000
      }).toString();

      const match = output.match(/id="DIAGNOSTIC_METRICS"\s+data-results='([^']+)'/) || output.match(/id="DIAGNOSTIC_METRICS"\s+data-results="([^"]+)"/);
      if (match) {
        const unescaped = match[1].replace(/&quot;/g, '"');
        const data = JSON.parse(unescaped);
        results.push({ page: page.file, viewport: vp.name, ...data });
      } else {
        results.push({ page: page.file, viewport: vp.name, error: 'Tag not found' });
      }
    } catch (e) {
      results.push({ page: page.file, viewport: vp.name, error: e.message });
    }
  }

  if (fs.existsSync(tempHtmlPath)) {
    fs.unlinkSync(tempHtmlPath);
  }
}

fs.writeFileSync('scratch/updated_metrics.json', JSON.stringify(results, null, 2), 'utf8');
console.log('Saved metrics to scratch/updated_metrics.json');
results.forEach(r => {
  if (r.hero) {
    console.log(`${r.page.padEnd(12)} ${(r.viewport || '').padEnd(20)}: Header=${r.headerHeight}px, HeroH=${r.hero.height}px, HeroBottom=${r.hero.bottom}px, ViewportH=${r.viewportH}px, Fits=${r.hero.fitsInInitialViewport}, Overflow=${r.hero.overflowBeyondViewport}px, BtnsFit=${r.buttonsFitsInViewport}`);
  } else {
    console.log(`${r.page} ${r.viewport}: ERROR ${r.error}`);
  }
});
