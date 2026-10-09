$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

$script = @"
(() => {
  const docWidth = document.documentElement.clientWidth;
  const overflowing = [];
  document.querySelectorAll('*').forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.right > docWidth + 1 || rect.width > docWidth + 1) {
      overflowing.push({
        tag: el.tagName,
        id: el.id,
        className: el.className,
        rectRight: Math.round(rect.right),
        rectWidth: Math.round(rect.width),
        docWidth: docWidth
      });
    }
  });
  console.log('OVERFLOW_RESULT:' + JSON.stringify(overflowing.slice(0, 20)));
})();
"@

$htmlWithCheck = @"
<!DOCTYPE html>
<html>
<body>
<iframe id="testFrame" src="file:///C:/Users/Karan/Downloads/Rug%20%26%20Carpet%20Store/index.html" style="width: 360px; height: 800px; border: 0;"></iframe>
<script>
window.onload = () => {
  setTimeout(() => {
    const doc = document.getElementById('testFrame').contentDocument;
    const docWidth = doc.documentElement.clientWidth;
    const scrollWidth = doc.documentElement.scrollWidth;
    console.log('SCROLL_WIDTH: ' + scrollWidth + ' vs CLIENT_WIDTH: ' + docWidth);
    const overflowing = [];
    doc.querySelectorAll('*').forEach(el => {
      const rect = el.getBoundingClientRect();
      if (rect.right > docWidth + 1) {
        overflowing.push({
          tag: el.tagName,
          id: el.id,
          class: el.className ? el.className.toString() : '',
          right: Math.round(rect.right),
          width: Math.round(rect.width)
        });
      }
    });
    console.log('OVERFLOW_ELEMENTS: ' + JSON.stringify(overflowing.slice(0, 15)));
  }, 1000);
};
</script>
</body>
</html>
"@

Set-Content -Path "C:\Users\Karan\test_overflow.html" -Value $htmlWithCheck
Start-Process -FilePath $edge -ArgumentList @(
    '--headless=new',
    '--virtual-time-budget=3000',
    '--window-size=360,800',
    '--enable-logging=stderr',
    'file:///C:/Users/Karan/test_overflow.html'
) -NoNewWindow -Wait
