import asyncio
import json
import subprocess
import time
import urllib.request
import websockets

pages = [
    "index.html",
    "home-2.html",
    "products.html",
    "product-details.html",
    "about.html",
    "services.html",
    "service-details.html",
    "blog.html",
    "blog-details.html",
    "pricing.html",
    "contact.html",
    "wishlist.html",
    "checkout.html",
    "custom-sizing.html",
    "care-guide.html"
]

viewports = [
    {"name": "Desktop (1400x900)", "width": 1400, "height": 900},
    {"name": "Tablet (768x1024)", "width": 768, "height": 1024},
    {"name": "Mobile (375x812)", "width": 375, "height": 812}
]

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

async def run_audit():
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
        await send_cmd("Emulation.setDeviceMetricsOverride", {
            "width": 1280, "height": 800, "deviceScaleFactor": 1, "mobile": False
        })

        results = []

        for p in pages:
            url = f"http://127.0.0.1:8080/{p}"
            await send_cmd("Page.navigate", {"url": url})
            for _ in range(25):
                await asyncio.sleep(0.1)
                res = await send_cmd("Runtime.evaluate", {"expression": "document.readyState"})
                if res.get("result", {}).get("result", {}).get("value") == "complete":
                    break
            await asyncio.sleep(0.3)

            for vp in viewports:
                await send_cmd("Emulation.setDeviceMetricsOverride", {
                    "width": vp["width"],
                    "height": vp["height"],
                    "deviceScaleFactor": 1,
                    "mobile": vp["width"] < 600
                })
                # scroll top
                await send_cmd("Runtime.evaluate", {"expression": "window.scrollTo(0, 0);"})
                await asyncio.sleep(0.1)
                # scroll down 600
                await send_cmd("Runtime.evaluate", {"expression": "window.scrollTo(0, 600);"})
                await asyncio.sleep(0.2)

                check = await send_cmd("Runtime.evaluate", {
                    "expression": """(() => {
                        const h = document.querySelector('.site-header, header.sticky-top, header');
                        if (!h) return { found: false };
                        const rect = h.getBoundingClientRect();
                        const cs = window.getComputedStyle(h);
                        const sy = window.scrollY;
                        // check ancestors with overflow
                        let el = h.parentElement;
                        let badAncestor = null;
                        while (el && el !== document.documentElement) {
                            const ecs = window.getComputedStyle(el);
                            if (ecs.overflow !== 'visible' || (ecs.overflowX !== 'visible' && ecs.overflowX !== 'clip') || (ecs.overflowY !== 'visible' && ecs.overflowY !== 'clip')) {
                                badAncestor = el.tagName + '.' + el.className + ' (' + ecs.overflow + ')';
                                break;
                            }
                            el = el.parentElement;
                        }
                        return {
                            found: true,
                            scrollY: sy,
                            top: rect.top,
                            bottom: rect.bottom,
                            height: rect.height,
                            position: cs.position,
                            zIndex: cs.zIndex,
                            badAncestor: badAncestor,
                            isStickyOk: (sy > 50 ? (rect.top >= -1 && rect.top <= 2) : true)
                        };
                    })()""",
                    "returnByValue": True
                })

                val = check.get("result", {}).get("result", {}).get("value", {})
                ok = val.get("isStickyOk", False)
                res_str = f"[{'PASS' if ok else 'FAIL'}] {p} @ {vp['name']}: scrollY={val.get('scrollY')}, top={val.get('top')}, pos={val.get('position')}, badAncestor={val.get('badAncestor')}"
                print(res_str)
                results.append((p, vp["name"], ok, val))

if __name__ == "__main__":
    proc = start_chrome()
    try:
        asyncio.run(run_audit())
    finally:
        proc.terminate()
