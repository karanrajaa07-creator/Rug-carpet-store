const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const viewports = [
  { name: 'desktop-1920x1080', w: 1920, h: 1080 },
  { name: 'desktop-1440x900',  w: 1440, h: 900 },
  { name: 'desktop-1366x768',  w: 1366, h: 768 },
  { name: 'desktop-1280x800',  w: 1280, h: 800 },
  { name: 'tablet-768x1024',   w: 768,  h: 1024 },
  { name: 'mobile-390x844',    w: 390,  h: 844 },
  { name: 'mobile-375x667',    w: 375,  h: 667 }
];

const pages = [
  { file: 'index.html', heroClass: '.hero-home-1' },
  { file: 'home-2.html', heroClass: '.hero-home-2' }
];

const results = [];

for (const page of pages) {
  const originalHtml = fs.readFileSync(page.file, 'utf8');
  
  const injectScript = `
  <script>
  window.addEventListener('load', () => {
    setTimeout(() => {
      const header = document.querySelector('.site-header');
      const hero = document.querySelector('${page.heroClass}');
      const hRect = header ? header.getBoundingClientRect() : null;
      const heroRect = hero ? hero.getBoundingClientRect() : null;
      const docW = document.documentElement.scrollWidth;
      const winW = window.innerWidth;
      const winH = window.innerHeight;
      
      const title = hero ? (hero.querySelector('.hero-title') || hero.querySelector('h1')) : null;
      const lead = hero ? hero.querySelector('.hero-lead') : null;
      const btnGroup = hero ? (hero.querySelector('.hero-btn-group') || hero.querySelector('.d-flex.flex-wrap')) : null;
      const metrics = hero ? hero.querySelector('.hero-metrics-strip') : null;
      const visual = hero ? (hero.querySelector('.hero-visual-container') || hero.querySelector('.hero-home-2 .col-lg-5')) : null;
      const img = hero ? hero.querySelector('img') : null;

      const info = {
        viewport: { w: winW, h: winH },
        hasHorizontalOverflow: docW > winW,
        header: hRect ? { height: Math.round(hRect.height) } : null,
        hero: heroRect ? {
          top: Math.round(heroRect.top),
          bottom: Math.round(heroRect.bottom),
          height: Math.round(heroRect.height),
          fitsInViewport: heroRect.bottom <= winH,
          overflowAmount: Math.round(heroRect.bottom - winH)
        } : null,
        titleBottom: title ? Math.round(title.getBoundingClientRect().bottom) : null,
        btnGroupBottom: btnGroup ? Math.round(btnGroup.getBoundingClientRect().bottom) : null,
        imgHeight: img ? Math.round(img.getBoundingClientRect().height) : null,
        totalHeaderPlusHero: (hRect && heroRect) ? Math.round(hRect.height + heroRect.height) : null
      };

      const tag = document.createElement('div');
      tag.id = 'DIAGNOSTIC_OUTPUT';
      tag.textContent = JSON.stringify(info);
      document.body.appendChild(tag);
    }, 500);
  });
  </script>
  `;

  const tempHtmlPath = path.resolve('temp_diag.html');
  fs.writeFileSync(tempHtmlPath, originalHtml.replace('</body>', injectScript + '</body>'), 'utf8');

  for (const vp of viewports) {
    const fileUrl = 'file:///' + tempHtmlPath.replace(/\\/g, '/').replace(/ /g, '%20').replace(/&/g, '%26');
    try {
      const output = execSync(`"${edgePath}" --headless=new --dump-dom --window-size=${vp.w},${vp.h} "${fileUrl}"`, {
        maxBuffer: 10 * 1024 * 1024,
        timeout: 15000
      }).toString();

      const match = output.match(/<div id="DIAGNOSTIC_OUTPUT">([\s\S]*?)<\/div>/);
      if (match) {
        const data = JSON.parse(match[1]);
        results.push({ page: page.file, viewport: vp.name, ...data });
      } else {
        results.push({ page: page.file, viewport: vp.name, error: 'No output found' });
      }
    } catch (e) {
      results.push({ page: page.file, viewport: vp.name, error: e.message });
    }
  }

  if (fs.existsSync(tempHtmlPath)) {
    fs.unlinkSync(tempHtmlPath);
  }
}

console.log(JSON.stringify(results, null, 2));
