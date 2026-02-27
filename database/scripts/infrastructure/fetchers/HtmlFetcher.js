const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

/**
 * HTML Fetcher
 * 
 * Fetches HTML from URLs and caches to disk.
 * Uses puppeteer-extra with stealth plugin to bypass bot protection (403s).
 * Falls back to plain fetch for simple requests.
 * 
 * This allows:
 * 1. Scraping from live URLs (with bot protection bypass)
 * 2. Saving HTML for replay/debugging
 * 3. Rebuilding database from cached HTML without re-fetching
 */
class HtmlFetcher {
  constructor(cacheDir = null) {
    // Default cache directory
    this.cacheDir = cacheDir || path.join(__dirname, '../../../scraped-html/apsl');
    this._browser = null;
  }

  /**
   * Get or launch a shared Puppeteer browser instance
   * Uses puppeteer-extra with stealth plugin to avoid bot detection
   */
  async _getBrowser() {
    if (this._browser) return this._browser;

    const puppeteer = require('puppeteer-extra');
    const StealthPlugin = require('puppeteer-extra-plugin-stealth');
    puppeteer.use(StealthPlugin());

    console.log('   🚀 Launching headless browser (stealth mode)...');
    this._browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    return this._browser;
  }

  /**
   * Fetch HTML using Puppeteer headless browser
   * Used when plain fetch returns 403 (bot protection)
   */
  async _fetchWithBrowser(url, timeoutMs = 30000) {
    const browser = await this._getBrowser();
    const page = await browser.newPage();

    try {
      await page.goto(url, { waitUntil: 'networkidle2', timeout: timeoutMs });
      const html = await page.content();
      return html;
    } finally {
      await page.close();
    }
  }

  /**
   * Close the shared browser instance (call when done scraping)
   */
  async closeBrowser() {
    if (this._browser) {
      await this._browser.close();
      this._browser = null;
    }
  }
  
  /**
   * Generate cache filename from URL
   * @param {string} url - Source URL
   * @returns {string} Filename like "standings-abc123.html"
   */
  getCacheFilename(url) {
    // Create short hash of URL for uniqueness
    const hash = crypto.createHash('md5').update(url).digest('hex').substring(0, 8);
    
    // Extract meaningful name from URL
    let baseName = 'page';
    const urlObj = new URL(url);
    const pathParts = urlObj.pathname.split('/').filter(p => p);
    if (pathParts.length > 0) {
      baseName = pathParts[pathParts.length - 1].toLowerCase().replace(/[^a-z0-9]/g, '-');
    }
    
    return `${baseName}-${hash}.html`;
  }
  
  /**
   * Fetch HTML from URL and cache to disk
   * @param {string} url - URL to fetch
   * @param {boolean} useCache - If true, use cached version if available
   * @param {number} retryAttempt - Current retry attempt (0 = first try)
   * @returns {Promise<string>} Raw HTML content
   */
  async fetch(url, useCache = true, retryAttempt = 0) {
    const cacheFile = path.join(this.cacheDir, this.getCacheFilename(url));
    const skipMarker = cacheFile + '.skip';
    
    // Check if this URL is marked as skip (known bad URL)
    if (useCache && retryAttempt === 0) {
      try {
        await fs.access(skipMarker);
        // Skip marker exists - don't try to fetch on first attempt
        return '';
      } catch {
        // No skip marker - continue
      }
    }
    
    // Try to use cached version if requested
    if (useCache) {
      try {
        const cached = await fs.readFile(cacheFile, 'utf-8');
        
        // Validate cached content - reject empty or invalid files
        if (!cached || cached.trim().length === 0) {
          // Empty cache file - mark for retry at end
          if (retryAttempt === 0) {
            console.log(`   ⏭️  Skipping empty file (will retry later): ${path.basename(cacheFile)}`);
            throw new Error('EMPTY_CACHE'); // Signal to retry later
          } else {
            console.log(`   🔄 Retry #${retryAttempt}: ${path.basename(cacheFile)}`);
          }
        } else {
          if (retryAttempt === 0) {
            console.log(`   📂 Using cached HTML: ${path.basename(cacheFile)}`);
          }
          return cached;
        }
      } catch (error) {
        if (error.message === 'EMPTY_CACHE') {
          throw error; // Re-throw to handle in batch retry
        }
        // Cache miss - continue to fetch
      }
    }
    
    // Fetch from URL with timeout
    const timeoutMs = retryAttempt > 0 ? 15000 : 30000;
    
    if (retryAttempt === 0) {
      console.log(`   🌐 Fetching: ${url}`);
    }
    
    let html;
    
    // Try plain fetch first, fall back to Puppeteer on 403
    const controller = new AbortController();
    const plainTimeoutId = setTimeout(() => controller.abort(), 10000);
    
    try {
      const response = await fetch(url, { 
        signal: controller.signal,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
        }
      });
      clearTimeout(plainTimeoutId);
      
      if (response.status === 403) {
        // Bot protection detected — use Puppeteer with stealth
        console.log(`   🛡️  403 detected, using headless browser...`);
        html = await this._fetchWithBrowser(url, timeoutMs);
      } else if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      } else {
        html = await response.text();
        // Some sites return 200 with empty body (JS-rendered pages) — fall back to browser
        if (!html || html.trim().length === 0) {
          console.log(`   📭 Empty 200 response, using headless browser...`);
          html = await this._fetchWithBrowser(url, timeoutMs);
        }
      }
    } catch (error) {
      clearTimeout(plainTimeoutId);
      if (error.name === 'AbortError') {
        // Plain fetch timed out — try Puppeteer
        console.log(`   ⏱️  Plain fetch timed out, using headless browser...`);
        html = await this._fetchWithBrowser(url, timeoutMs);
      } else if (error.message && error.message.includes('403')) {
        console.log(`   🛡️  403 detected, using headless browser...`);
        html = await this._fetchWithBrowser(url, timeoutMs);
      } else {
        throw error;
      }
    }
      
    // Validate response
    if (!html || html.trim().length === 0) {
      // Empty response - only create skip marker on final retry
      if (retryAttempt >= 2) {
        await fs.mkdir(this.cacheDir, { recursive: true });
        await fs.writeFile(skipMarker, `Empty response after ${retryAttempt + 1} attempts at ${new Date().toISOString()}`, 'utf-8');
      }
      throw new Error('Empty response from server');
    }
    
    // Save to cache
    try {
      await fs.mkdir(this.cacheDir, { recursive: true });
      await fs.writeFile(cacheFile, html, 'utf-8');
      
      // Remove skip marker if it exists (successful fetch)
      try {
        await fs.unlink(skipMarker);
      } catch {
        // Ignore if skip marker doesn't exist
      }
      
      const sizeKB = (html.length / 1024).toFixed(1);
      if (retryAttempt === 0) {
        console.log(`   💾 Cached: ${path.basename(cacheFile)} (${sizeKB} KB)`);
      } else {
        console.log(`   ✅ Retry #${retryAttempt} succeeded: ${path.basename(cacheFile)} (${sizeKB} KB)`);
      }
    } catch (error) {
      console.warn(`   ⚠️  Failed to cache HTML: ${error.message}`);
    }
    
    return html;
  }
  
  /**
   * Batch fetch with retry logic
   * First pass: Try all URLs, skip failures
   * Second pass: Retry failed URLs
   * Third pass: Final retry, then use git version as fallback
   */
  async fetchWithRetry(url, useCache = true) {
    const failures = [];
    
    // First attempt
    try {
      return await this.fetch(url, useCache, 0);
    } catch (error) {
      if (error.message === 'EMPTY_CACHE') {
        failures.push({ url, error });
        return null; // Will retry later
      }
      throw error;
    }
  }
  
  /**
   * Retry failed fetches
   * @param {Array<{url: string}>} failedUrls - URLs that failed
   * @param {number} attempt - Retry attempt number
   * @returns {Promise<Array<{url: string, success: boolean}>>}
   */
  async retryFailed(failedUrls, attempt = 1) {
    if (failedUrls.length === 0) return [];
    
    console.log(`\n   🔄 Retrying ${failedUrls.length} failed URLs (attempt #${attempt})...`);
    
    const results = [];
    for (const { url } of failedUrls) {
      try {
        await this.fetch(url, false, attempt); // Don't use cache on retry
        results.push({ url, success: true });
      } catch (error) {
        results.push({ url, success: false, error });
      }
    }
    
    const succeeded = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;
    console.log(`   ✅ Succeeded: ${succeeded}, ❌ Still failing: ${failed}`);
    
    return results;
  }
  
  /**
   * Batch fetch multiple URLs with concurrency limit
   * @param {Array<{url: string, filename: string}>} requests - Array of requests
   * @param {number} concurrency - Max concurrent requests (default: 5)
   * @param {boolean} useCache - Whether to use cached versions
   * @returns {Promise<Array<{url: string, html: string, error: Error}>>}
   */
  async batchFetch(requests, concurrency = 5, useCache = true) {
    const results = [];
    const queue = [...requests];
    let completed = 0;
    
    console.log(`   📥 Batch downloading ${requests.length} files (concurrency: ${concurrency})`);
    
    const workers = Array(concurrency).fill(null).map(async () => {
      while (queue.length > 0) {
        const request = queue.shift();
        if (!request) break;
        
        try {
          const html = await this.fetch(request.url, useCache);
          results.push({ url: request.url, html, error: null });
          completed++;
          process.stdout.write(`\r   Progress: ${completed}/${requests.length} (${Math.round(completed/requests.length*100)}%)`);
        } catch (error) {
          results.push({ url: request.url, html: null, error });
          completed++;
          process.stdout.write(`\r   Progress: ${completed}/${requests.length} (${Math.round(completed/requests.length*100)}%) - ${error.message}`);
        }
      }
    });
    
    await Promise.all(workers);
    console.log(''); // New line after progress
    
    return results;
  }
}

module.exports = HtmlFetcher;
