const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const path = require('path');

const brainDir = 'C:\\Users\\Karan\\.gemini\\antigravity-ide\\brain\\fba37c94-680c-400d-ada4-0dcd50cb5c9e';
const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

function getJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    }).on('error', reject);
  });
}

async function run() {
  const profileDir = path.join(__dirname, 'edge_cdp_profile');
  if (!fs.existsSync(profileDir)) fs.mkdirSync(profileDir, { recursive: true });

  const proc = spawn(edgePath, [
    '--headless=new',
    '--disable-gpu',
    '--remote-debugging-port=9222',
    `--user-data-dir=${profileDir}`,
    '--window-size=1440,900',
    'about:blank'
  ]);

  await sleep(2500);

  try {
    const targets = await getJson('http://127.0.0.1:9222/json');
    console.log('Targets:', targets.length);
    const pageTarget = targets.find(t => t.type === 'page');
    if (!pageTarget) throw new Error('No page target found');

    const ws = new WebSocket(pageTarget.webSocketDebuggerUrl);

    let id = 1;
    const callbacks = new Map();

    ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      if (msg.id && callbacks.has(msg.id)) {
        const { resolve, reject } = callbacks.get(msg.id);
        callbacks.delete(msg.id);
        if (msg.error) reject(msg.error);
        else resolve(msg.result);
      }
    };

    await new Promise(r => ws.onopen = r);

    function send(method, params = {}) {
      return new Promise((resolve, reject) => {
        const msgId = id++;
        callbacks.set(msgId, { resolve, reject });
        ws.send(JSON.stringify({ id: msgId, method, params }));
      });
    }

    await send('Page.enable');
    await send('DOM.enable');

    async function capturePage(url, viewport, outPath, evalFn) {
      console.log(`Capturing ${url} at ${viewport.width}x${viewport.height}...`);
      await send('Emulation.setDeviceMetricsOverride', {
        width: viewport.width,
        height: viewport.height,
        deviceScaleFactor: 1,
        mobile: viewport.mobile || false
      });
      await send('Page.navigate', { url });
      await sleep(1500);
      if (evalFn) {
        await send('Runtime.evaluate', { expression: evalFn, awaitPromise: true });
        await sleep(500);
      }
      const screenshot = await send('Page.captureScreenshot', { format: 'png' });
      fs.writeFileSync(outPath, Buffer.from(screenshot.data, 'base64'));
      console.log(`Saved screenshot to ${outPath}`);
    }

    // 1. About Page Guiding Values (Section 3 with restored icon)
    await capturePage(
      'http://localhost:3000/about.html#ourGuidingValues',
      { width: 1440, height: 900 },
      path.join(brainDir, 'About_guiding_values_verified.png'),
      `document.getElementById('ourGuidingValues').scrollIntoView({behavior: 'instant'});`
    );

    // 2. Contact Page Hero Text Contrast (Light Theme)
    await capturePage(
      'http://localhost:3000/contact.html',
      { width: 1440, height: 900 },
      path.join(brainDir, 'Contact_hero_contrast_light.png'),
      `document.documentElement.setAttribute('data-theme', 'light');`
    );

    // 3. Contact Page Hero Text Contrast (Dark Theme)
    await capturePage(
      'http://localhost:3000/contact.html',
      { width: 1440, height: 900 },
      path.join(brainDir, 'Contact_hero_contrast_dark.png'),
      `document.documentElement.setAttribute('data-theme', 'dark');`
    );

    // 4. Shop Page Hero Centered (Desktop Light)
    await capturePage(
      'http://localhost:3000/products.html',
      { width: 1440, height: 900 },
      path.join(brainDir, 'Shop_hero_centered_desktop_verified.png'),
      `document.documentElement.setAttribute('data-theme', 'light');`
    );

    // 5. Home 1 Hero Viewport Check (1366x768 laptop)
    await capturePage(
      'http://localhost:3000/index.html',
      { width: 1366, height: 768 },
      path.join(brainDir, 'Home1_hero_1366x768_verified.png'),
      null
    );

    // 6. Home 2 Hero Viewport & Light Contrast Check (1366x768 laptop)
    await capturePage(
      'http://localhost:3000/home-2.html',
      { width: 1366, height: 768 },
      path.join(brainDir, 'Home2_hero_1366x768_verified.png'),
      `document.documentElement.setAttribute('data-theme', 'light');`
    );

    // 7. Check mobile viewport scrollWidth vs clientWidth
    await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 2, mobile: true });
    await send('Page.navigate', { url: 'http://localhost:3000/index.html' });
    await sleep(1500);

    const evalRes = await send('Runtime.evaluate', {
      expression: `
        (() => {
          const sw = document.documentElement.scrollWidth;
          const cw = document.documentElement.clientWidth;
          const badElements = [];
          document.querySelectorAll('*').forEach(el => {
            const rect = el.getBoundingClientRect();
            if (rect.right > cw + 1 || rect.left < -1) {
              badElements.push({ tag: el.tagName, class: el.className, right: rect.right, left: rect.left });
            }
          });
          return { sw, cw, overflow: sw > cw, badElementsCount: badElements.length, sample: badElements.slice(0, 5) };
        })()
      `,
      returnByValue: true
    });
    console.log('Mobile index.html evaluation:', JSON.stringify(evalRes.result.value, null, 2));

    const mobileScreenshot = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(brainDir, 'Home1_hero_mobile_verified.png'), Buffer.from(mobileScreenshot.data, 'base64'));
    console.log('Saved Home1_hero_mobile_verified.png');

    ws.close();
  } finally {
    proc.kill();
  }
}

run().catch(console.error);
