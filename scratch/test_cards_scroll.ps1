$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url = "file:///c:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/scratch/test_size_switch.html"
$outPng = "C:\Users\Karan\.gemini\antigravity-ide\brain\1238d468-beab-4358-a7b9-a2f6826e8741\three_cards_rendered.png"

$proc = Start-Process -FilePath $edgePath -ArgumentList "--headless=new", "--screenshot=$outPng", "--window-size=1280,1000", $url -NoNewWindow -PassThru
$proc.WaitForExit(10000)

Write-Host "Screenshot saved: $(Test-Path $outPng)"
