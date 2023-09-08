const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

function delay(time) {
  return new Promise(function(resolve) { 
      setTimeout(resolve, time)
  });
}

async function run () {
  const browser = await puppeteer.launch(
    {
      'headless': 'new',
    }
  );
  const page = await browser.newPage();
  await page.goto(
    'https://www.youtube.com/@martial_le_toullec',
    {
      waitUntil: "networkidle0"
    }
  );
  await delay(1000);
  await page.screenshot(
    {
      path: 'screenshot/youtube-0.png',
      fullPage: true
    }
  );
  await page.evaluate(() => {
    document.querySelector('form[jsaction="JIbuQc:ldDdv(b3VHJd)"]').submit();
  });
  await page.waitForNavigation(
    {
      waitUntil: 'networkidle0',
    }
  );
  await page.screenshot(
    {
      path: 'screenshot/youtube-1.png',
      fullPage: true
    }
  );
  browser.close();
}
run();