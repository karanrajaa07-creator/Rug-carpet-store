import asyncio
import json
import subprocess
import time
import urllib.request
import websockets

def start_chrome():
    chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    proc = subprocess.Popen([
        chrome_path,
        "--headless=new",
        "--remote-debugging-port=9222",
        "--disable-gpu",
        "--no-first-run",
        "--no-default-browser-check",
        "--user-data-dir=C:\\Users\\Karan\\Downloads\\Rug & Carpet Store\\scratch\\chrome_profile"
    ])
    return proc

async def run_test():
    # Wait for Chrome to start
    for _ in range(10):
        try:
            with urllib.request.urlopen("http://127.0.0.1:9222/json") as response:
                targets = json.loads(response.read().decode())
                if targets:
                    break
        except Exception:
            time.sleep(0.5)

    page_targets = [t for t in targets if t.get("type") == "page"]
    target = page_targets[0] if page_targets else targets[0]
    ws_url = target["webSocketDebuggerUrl"]
    async with websockets.connect(ws_url) as ws:
        msg_id = 1
        async def send_cmd(method, params=None):
            nonlocal msg_id
            msg_id += 1
            cmd = {"id": msg_id, "method": method}
            if params:
                cmd["params"] = params
            await ws.send(json.dumps(cmd))
            while True:
                resp = json.loads(await ws.recv())
                if resp.get("id") == msg_id:
                    return resp

        await send_cmd("Page.enable")
        await send_cmd("Page.navigate", {"url": "http://127.0.0.1:8080/index.html"})
        # wait for load
        for _ in range(30):
            await asyncio.sleep(0.2)
            res = await send_cmd("Runtime.evaluate", {"expression": "document.readyState"})
            if res.get("result", {}).get("result", {}).get("value") == "complete":
                break
        await asyncio.sleep(0.5)

        title_res = await send_cmd("Runtime.evaluate", {"expression": "document.title + ' | ' + location.href"})
        print("Page loaded:", title_res.get("result", {}).get("result", {}).get("value"))

        # Evaluate initial position
        eval1 = await send_cmd("Runtime.evaluate", {
            "expression": """(() => {
                const h = document.querySelector('.site-header');
                const rect = h ? h.getBoundingClientRect() : null;
                const cs = h ? window.getComputedStyle(h) : null;
                return JSON.stringify({
                    scrollY: window.scrollY,
                    rectTop: rect ? rect.top : null,
                    rectBottom: rect ? rect.bottom : null,
                    position: cs ? cs.position : null,
                    top: cs ? cs.top : null,
                    zIndex: cs ? cs.zIndex : null
                });
            })()"""
        })
        print("Initial:", eval1["result"]["result"]["value"])

        # Scroll down by 800px
        eval_scroll = await send_cmd("Runtime.evaluate", {
            "expression": """(() => {
                window.scrollTo(0, 800);
                return window.scrollY;
            })()"""
        })
        await asyncio.sleep(1)

        eval2 = await send_cmd("Runtime.evaluate", {
            "expression": """(() => {
                const h = document.querySelector('.site-header');
                const rect = h ? h.getBoundingClientRect() : null;
                const cs = h ? window.getComputedStyle(h) : null;
                return JSON.stringify({
                    scrollY: window.scrollY,
                    rectTop: rect ? rect.top : null,
                    rectBottom: rect ? rect.bottom : null,
                    position: cs ? cs.position : null,
                    top: cs ? cs.top : null,
                    isScrolled: h ? h.classList.contains('is-scrolled') : false
                });
            })()"""
        })
        print("After scroll 800px:", eval2["result"]["result"]["value"])

if __name__ == "__main__":
    proc = start_chrome()
    try:
        asyncio.run(run_test())
    finally:
        proc.terminate()
