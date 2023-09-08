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
    'https://bot.sannysoft.com',
    {
      waitUntil: "networkidle0"
    }
  );
  await page.screenshot(
    {
      path: 'screenshot/antibot.png',
      fullPage: true
    }
  );
  browser.close();
  console.log(`All done, check the screenshot. ✨`)
}
run();