import asyncio
import json
import subprocess
import time
import urllib.request
import websockets
import base64

async def capture_theme_scrolled():
    proc = subprocess.Popen([
        r'C:\Program Files\Google\Chrome\Application\chrome.exe',
        '--headless=new', '--remote-debugging-port=9222', '--disable-gpu',
        '--no-first-run', '--no-default-browser-check',
        r'--user-data-dir=C:\Users\Karan\Downloads\Rug & Carpet Store\scratch\chrome_profile_theme'
    ])
    try:
        for _ in range(15):
            try:
                with urllib.request.urlopen('http://127.0.0.1:9222/json') as response:
                    targets = json.loads(response.read().decode())
                    if targets: break
            except: time.sleep(0.5)
        
        target = [t for t in targets if t.get('type') == 'page'][0]
        async with websockets.connect(target['webSocketDebuggerUrl'], max_size=20*1024*1024) as ws:
            msg_id = 1
            async def send_cmd(m, p=None):
                nonlocal msg_id
                msg_id += 1
                c = {'id': msg_id, 'method': m}
                if p: c['params'] = p
                await ws.send(json.dumps(c))
                while True:
                    r = json.loads(await ws.recv())
                    if r.get('id') == msg_id: return r
            
            await send_cmd('Page.enable')
            await send_cmd('Emulation.setDeviceMetricsOverride', {'width': 1280, 'height': 800, 'deviceScaleFactor': 1, 'mobile': False})
            await send_cmd('Page.navigate', {'url': 'http://127.0.0.1:8080/index.html'})
            await asyncio.sleep(1.5)
            
            # Scrolled dark
            await send_cmd('Runtime.evaluate', {'expression': "document.documentElement.setAttribute('data-theme', 'dark'); window.scrollTo(0, 700);"})
            await asyncio.sleep(0.5)
            ss1 = await send_cmd('Page.captureScreenshot', {'format': 'png'})
            with open('scratch/scroll_dark_700.png', 'wb') as f:
                f.write(base64.b64decode(ss1['result']['data']))
            
            # Scrolled light
            await send_cmd('Runtime.evaluate', {'expression': "document.documentElement.setAttribute('data-theme', 'light'); window.scrollTo(0, 700);"})
            await asyncio.sleep(0.5)
            ss2 = await send_cmd('Page.captureScreenshot', {'format': 'png'})
            with open('scratch/scroll_light_700.png', 'wb') as f:
                f.write(base64.b64decode(ss2['result']['data']))
            print('Successfully captured dark and light scroll screenshots!')
    finally:
        proc.terminate()

if __name__ == '__main__':
    asyncio.run(capture_theme_scrolled())
