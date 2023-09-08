const {puppeteer} = require('./../src/puppeteer.js');

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
    'https://www.letoullec.fr',
    {
      waitUntil: "networkidle0"
    }
  );
  await page.screenshot(
    {
      path: 'screenshot/letoullec.png',
      fullPage: true
    }
  );
  browser.close();
}
run();