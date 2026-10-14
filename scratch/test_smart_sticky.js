const fs = require('fs');

// We will create a test HTML file that loads index.html, performs the scroll down & scroll up sequence,
// and records the exact states of the header.

const testHtml = `
<!DOCTYPE html>
<html>
<head><title>Smart Sticky Test</title></head>
<body>
<iframe id="testFrame" src="../index.html" style="width: 1200px; height: 800px; border: none;"></iframe>
<div id="results"></div>
<script>
window.addEventListener('load', async () => {
  const frame = document.getElementById('testFrame');
  const win = frame.contentWindow;
  const doc = frame.contentDocument;

  const wait = ms => new Promise(res => setTimeout(res, ms));

  // Wait for iframe DOMContentLoaded and initialization
  await wait(800);

  const header = doc.querySelector('.site-header');
  const results = [];

  function check(step, expectedHidden, expectedScrolled) {
    const hasHidden = header.classList.contains('is-hidden');
    const hasScrolled = header.classList.contains('is-scrolled');
    const pass = (hasHidden === expectedHidden) && (hasScrolled === expectedScrolled);
    results.push({
      step,
      scrollY: win.scrollY,
      hasHidden,
      hasScrolled,
      expectedHidden,
      expectedScrolled,
      pass
    });
  }

  // 1. Initial State at scrollY = 0
  check('1. Initial Top', false, false);

  // 2. Scroll down to 500px
  win.scrollTo(0, 500);
  win.dispatchEvent(new win.Event('scroll'));
  await wait(300);
  check('2. Scrolled Down to 500px', true, true);

  // 3. Scroll up to 350px (scrolling up by 150px)
  win.scrollTo(0, 350);
  win.dispatchEvent(new win.Event('scroll'));
  await wait(300);
  check('3. Scrolled Up to 350px', false, true);

  // 4. Scroll down again to 600px
  win.scrollTo(0, 600);
  win.dispatchEvent(new win.Event('scroll'));
  await wait(300);
  check('4. Scrolled Down to 600px', true, true);

  // 5. Scroll all the way back to top (0px)
  win.scrollTo(0, 0);
  win.dispatchEvent(new win.Event('scroll'));
  await wait(300);
  check('5. Returned to Top (0px)', false, false);

  const allPassed = results.every(r => r.pass);
  document.getElementById('results').textContent = JSON.stringify({ allPassed, results });
});
</script>
</body>
</html>
`;

fs.writeFileSync('scratch/test_smart_sticky_runner.html', testHtml, 'utf8');
console.log('Created scratch/test_smart_sticky_runner.html');
