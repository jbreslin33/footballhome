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
    this.timeout = options.timeout || 0; // 0 = no timeout, wait indefinitely
    this.browser = null;
  }

  async fetch(url) {
    console.log(`🌐 Fetching: ${url}`);
    console.log(`⏳ Waiting for page to load...`);
    
    // Launch browser only once and reuse it
    if (!this.browser) {
      console.log(`🚀 Launching browser...`);
      this.browser = await puppeteer.launch({ 
        headless: 'new',
        args: [
          '--no-sandbox', 
          '--disable-setuid-sandbox',
          '--disable-blink-features=AutomationControlled', // Hide automation
          '--disable-features=IsolateOrigins,site-per-process'
        ]
      });
    }
    
    const page = await this.browser.newPage();
    
    // Spoof user agent to look like real Chrome
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36');
    
    // Remove webdriver flag (bot detection)
    await page.evaluateOnNewDocument(() => {
      Object.defineProperty(navigator, 'webdriver', {
        get: () => false,
      });
    });
    
    try {
      await page.goto(url, { 
        waitUntil: 'networkidle2', 
        timeout: this.timeout 
      });
      console.log(`✓ Page loaded successfully`);
      
      // Wait for Angular root or main content to load
      await page.waitForSelector('sm-root, body');
      const html = await page.content();
      await page.close();
      return html;
    } catch (error) {
      console.log(`❌ Failed to load: ${error.message}`);
      await page.close();
      throw error;
    }
  }
  
  async close() {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
    }
  }
}

module.exports = PuppeteerFetcher;
