const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const path = require('path');

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const profileDir = path.join(__dirname, 'edge_cdp_profile_sticky');
if (!fs.existsSync(profileDir)) fs.mkdirSync(profileDir, { recursive: true });

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
  const proc = spawn(edgePath, [
    '--headless=new',
    '--disable-gpu',
    '--remote-debugging-port=9223',
    `--user-data-dir=${profileDir}`,
    '--window-size=1280,900',
    'about:blank'
  ]);

  await sleep(2000);

  try {
    const targets = await getJson('http://127.0.0.1:9223/json');
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
    await send('Runtime.enable');

    const fileUrl = 'file:///' + path.resolve('index.html').replace(/\\/g, '/');
    console.log('Navigating to:', fileUrl);
    await send('Page.navigate', { url: fileUrl });
    await sleep(2000);

    // Step 1: Initial state (scrollY = 0)
    let evalRes = await send('Runtime.evaluate', {
      expression: `(() => {
        const h = document.querySelector('.site-header');
        return {
          scrollY: window.scrollY,
          isHidden: h.classList.contains('is-hidden'),
          isScrolled: h.classList.contains('is-scrolled'),
          transform: window.getComputedStyle(h).transform
        };
      })()`,
      returnByValue: true
    });
    console.log('STEP 1 (Initial Top):', evalRes.result.value);

    // Take screenshot 1
    const shot1 = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync('scratch/sticky_step1_top.png', Buffer.from(shot1.data, 'base64'));

    // Step 2: Scroll down to 600px
    await send('Runtime.evaluate', {
      expression: `(() => {
        window.scrollTo(0, 600);
        window.dispatchEvent(new Event('scroll'));
      })()`
    });
    await sleep(600);

    evalRes = await send('Runtime.evaluate', {
      expression: `(() => {
        const h = document.querySelector('.site-header');
        return {
          scrollY: window.scrollY,
          isHidden: h.classList.contains('is-hidden'),
          isScrolled: h.classList.contains('is-scrolled'),
          transform: window.getComputedStyle(h).transform
        };
      })()`,
      returnByValue: true
    });
    console.log('STEP 2 (Scrolled Down to 600px):', evalRes.result.value);

    // Take screenshot 2
    const shot2 = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync('scratch/sticky_step2_scrolldown_hidden.png', Buffer.from(shot2.data, 'base64'));

    // Step 3: Scroll up to 350px
    await send('Runtime.evaluate', {
      expression: `(() => {
        window.scrollTo(0, 350);
        window.dispatchEvent(new Event('scroll'));
      })()`
    });
    await sleep(600);

    evalRes = await send('Runtime.evaluate', {
      expression: `(() => {
        const h = document.querySelector('.site-header');
        return {
          scrollY: window.scrollY,
          isHidden: h.classList.contains('is-hidden'),
          isScrolled: h.classList.contains('is-scrolled'),
          transform: window.getComputedStyle(h).transform
        };
      })()`,
      returnByValue: true
    });
    console.log('STEP 3 (Scrolled Up to 350px):', evalRes.result.value);

    // Take screenshot 3
    const shot3 = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync('scratch/sticky_step3_scrollup_revealed.png', Buffer.from(shot3.data, 'base64'));

    // Step 4: Scroll back to 0px
    await send('Runtime.evaluate', {
      expression: `(() => {
        window.scrollTo(0, 0);
        window.dispatchEvent(new Event('scroll'));
      })()`
    });
    await sleep(600);

    evalRes = await send('Runtime.evaluate', {
      expression: `(() => {
        const h = document.querySelector('.site-header');
        return {
          scrollY: window.scrollY,
          isHidden: h.classList.contains('is-hidden'),
          isScrolled: h.classList.contains('is-scrolled'),
          transform: window.getComputedStyle(h).transform
        };
      })()`,
      returnByValue: true
    });
    console.log('STEP 4 (Back at 0px):', evalRes.result.value);

    ws.close();
  } catch (err) {
    console.error('Error during test:', err);
  } finally {
    proc.kill();
  }
}

run();
