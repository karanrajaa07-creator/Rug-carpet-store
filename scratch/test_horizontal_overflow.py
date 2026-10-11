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
        "--user-data-dir=C:\\Users\\Karan\\Downloads\\Rug & Carpet Store\\scratch\\chrome_profile_overflow"
    ])
    return proc

async def check_horizontal_overflow():
    for _ in range(15):
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

    async with websockets.connect(ws_url, max_size=20*1024*1024) as ws:
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

        pages = ["index.html", "products.html", "about.html", "contact.html"]
        for p in pages:
            await send_cmd("Page.navigate", {"url": f"http://127.0.0.1:8080/{p}"})
            for _ in range(20):
                await asyncio.sleep(0.1)
                res = await send_cmd("Runtime.evaluate", {"expression": "document.readyState"})
                if res.get("result", {}).get("result", {}).get("value") == "complete":
                    break

            res = await send_cmd("Runtime.evaluate", {
                "expression": """(() => {
                    const docWidth = document.documentElement.scrollWidth;
                    const winWidth = window.innerWidth;
                    const diff = docWidth - winWidth;
                    let offenders = [];
                    if (diff > 1) {
                        for (const el of document.querySelectorAll('*')) {
                            const rect = el.getBoundingClientRect();
                            if (rect.right > winWidth + 2) {
                                offenders.push(el.tagName + '.' + el.className + ' right=' + rect.right);
                            }
                        }
                    }
                    return { docWidth, winWidth, diff, offenders: offenders.slice(0, 5) };
                })()""",
                "returnByValue": True
            })
            print(p, res.get("result", {}).get("result", {}).get("value"))

if __name__ == "__main__":
    proc = start_chrome()
    try:
        asyncio.run(check_horizontal_overflow())
    finally:
        proc.terminate()
