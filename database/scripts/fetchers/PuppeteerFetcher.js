const DataFetcher = require('../base/DataFetcher');
const puppeteer = require('puppeteer');

/**
 * Puppeteer Fetcher
 * Fetches fully rendered HTML using a headless browser
 * Reuses browser instance for better performance
 */
class PuppeteerFetcher extends DataFetcher {
  constructor(options = {}) {
    super();
    this.timeout = options.timeout || 30000;
    this.browser = null;
  }

  async fetch(url) {
    // Launch browser only once and reuse it
    if (!this.browser) {
      this.browser = await puppeteer.launch({ 
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox'] // Better for Docker/server environments
      });
    }
    
    const page = await this.browser.newPage();
    await page.goto(url, { waitUntil: 'networkidle2', timeout: this.timeout });
    // Wait for Angular root or main content to load
    await page.waitForSelector('sm-root, body');
    const html = await page.content();
    await page.close();
    return html;
  }
  
  async close() {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
    }
  }
}

module.exports = PuppeteerFetcher;
