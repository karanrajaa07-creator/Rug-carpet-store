$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$dir = 'C:\Users\Karan\.gemini\antigravity-ide\brain\fba37c94-680c-400d-ada4-0dcd50cb5c9e'

& $edge --headless --window-size=390,844 "--screenshot=$dir\Home1_mobile_390x844.png" --dump-dom 'http://localhost:3000/index.html' | Out-Null
& $edge --headless --window-size=390,844 "--screenshot=$dir\Home2_mobile_390x844.png" --dump-dom 'http://localhost:3000/home-2.html' | Out-Null
& $edge --headless --window-size=375,667 "--screenshot=$dir\Home1_mobile_375x667.png" --dump-dom 'http://localhost:3000/index.html' | Out-Null
& $edge --headless --window-size=375,667 "--screenshot=$dir\Home2_mobile_375x667.png" --dump-dom 'http://localhost:3000/home-2.html' | Out-Null

Write-Host "Mobile captures finished."
