const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const path = require('path');

const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const profileDir = path.join(__dirname, 'edge_cdp_profile_pages');
if (!fs.existsSync(profileDir)) fs.mkdirSync(profileDir, { recursive: true });

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

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
    '--remote-debugging-port=9224',
    `--user-data-dir=${profileDir}`,
    '--window-size=1280,900',
    'about:blank'
  ]);

  await sleep(2000);

  try {
    const targets = await getJson('http://127.0.0.1:9224/json');
    const pageTarget = targets.find(t => t.type === 'page');
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

    const pages = ['home-2.html', 'products.html', 'about.html', 'blog.html', 'contact.html', 'wishlist.html'];

    for (const page of pages) {
      const fileUrl = 'file:///' + path.resolve(page).replace(/\\/g, '/');
      await send('Page.navigate', { url: fileUrl });
      await sleep(1000);

      // Scroll down
      await send('Runtime.evaluate', {
        expression: `(() => { window.scrollTo(0, 500); window.dispatchEvent(new Event('scroll')); })()`
      });
      await sleep(300);

      let downRes = await send('Runtime.evaluate', {
        expression: `(() => {
          const h = document.querySelector('.site-header, header.sticky-top');
          return h ? h.classList.contains('is-hidden') : false;
        })()`,
        returnByValue: true
      });

      // Scroll up
      await send('Runtime.evaluate', {
        expression: `(() => { window.scrollTo(0, 250); window.dispatchEvent(new Event('scroll')); })()`
      });
      await sleep(300);

      let upRes = await send('Runtime.evaluate', {
        expression: `(() => {
          const h = document.querySelector('.site-header, header.sticky-top');
          return h ? !h.classList.contains('is-hidden') : false;
        })()`,
        returnByValue: true
      });

      const pass = downRes.result.value === true && upRes.result.value === true;
      console.log(`PAGE ${page}: Down Hidden=${downRes.result.value}, Up Revealed=${upRes.result.value} -> ${pass ? 'PASS' : 'FAIL'}`);
    }

    ws.close();
  } catch (err) {
    console.error('Error:', err);
  } finally {
    proc.kill();
  }
}

run();
