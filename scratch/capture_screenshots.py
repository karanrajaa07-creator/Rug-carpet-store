import asyncio
import json
import subprocess
import time
import urllib.request
import websockets
import base64

def start_chrome():
    chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    proc = subprocess.Popen([
        chrome_path,
        "--headless=new",
        "--remote-debugging-port=9222",
        "--disable-gpu",
        "--no-first-run",
        "--no-default-browser-check",
        "--user-data-dir=C:\\Users\\Karan\\Downloads\\Rug & Carpet Store\\scratch\\chrome_profile_ss"
    ])
    return proc

async def capture_scroll_screenshots():
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
        await send_cmd("Emulation.setDeviceMetricsOverride", {
            "width": 1280, "height": 800, "deviceScaleFactor": 1, "mobile": False
        })
        await send_cmd("Page.navigate", {"url": "http://127.0.0.1:8080/index.html"})
        for _ in range(25):
            await asyncio.sleep(0.1)
            res = await send_cmd("Runtime.evaluate", {"expression": "document.readyState"})
            if res.get("result", {}).get("result", {}).get("value") == "complete":
                break
        await asyncio.sleep(0.5)

        for scroll_y in [0, 200, 800, 1500]:
            await send_cmd("Runtime.evaluate", {"expression": f"window.scrollTo(0, {scroll_y});"})
            await asyncio.sleep(0.5)
            ss = await send_cmd("Page.captureScreenshot", {"format": "png"})
            img_data = base64.b64decode(ss["result"]["data"])
            path = f"C:\\Users\\Karan\\Downloads\\Rug & Carpet Store\\scratch\\scroll_{scroll_y}.png"
            with open(path, "wb") as f:
                f.write(img_data)
            print(f"Captured {path}")

if __name__ == "__main__":
    proc = start_chrome()
    try:
        asyncio.run(capture_scroll_screenshots())
    finally:
        proc.terminate()
