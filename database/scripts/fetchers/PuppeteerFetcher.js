const DataFetcher = require('../base/DataFetcher');
const puppeteer = require('puppeteer');

/**
 * Puppeteer Fetcher
 * Fetches fully rendered HTML using a headless browser
 */
class PuppeteerFetcher extends DataFetcher {
  constructor(options = {}) {
    super();
    this.timeout = options.timeout || 30000;
  }

  async fetch(url) {
    const browser = await puppeteer.launch({ headless: 'new' });
    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'networkidle2', timeout: this.timeout });
    // Wait for Angular root or main content to load
    await page.waitForSelector('sm-root, body');
    const html = await page.content();
    await browser.close();
    return html;
  }
}

module.exports = PuppeteerFetcher;
