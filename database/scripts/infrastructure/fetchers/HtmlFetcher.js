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
  /**
   * @param {string|null} cacheDir - Cache directory path
   * @param {object} opts - Options
   * @param {number} opts.delayMs - Min delay between fetches in ms (default: 3000)
   * @param {number} opts.delayJitterMs - Random jitter added to delay (default: 4000)
   * @param {number} opts.cacheFreshnessDays - Skip re-fetch if cache is newer than N days (default: 7)
   * @param {number} opts.maxFetchesPerSession - Max live fetches per session, 0=unlimited (default: 0)
   */
  constructor(cacheDir = null, opts = {}) {
    // Default cache directory
    this.cacheDir = cacheDir || path.join(__dirname, '../../../scraped-html/apsl');
    this._browser = null;

    // Rate limiting: polite scraping defaults
    this.delayMs = opts.delayMs ?? 3000;           // 3s minimum between requests
    this.delayJitterMs = opts.delayJitterMs ?? 4000; // + 0-4s random jitter (3-7s total)
    this.cacheFreshnessDays = opts.cacheFreshnessDays ?? 7; // Skip if cached < 7 days ago
    this.maxFetchesPerSession = opts.maxFetchesPerSession ?? 0; // 0 = unlimited
    this._fetchCount = 0;
    this._lastFetchTime = 0;
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
   * Check if a cached file is fresh enough to skip re-fetching
   * @param {string} cacheFile - Path to cached file
   * @returns {Promise<boolean>} True if cache is fresh
   */
  async _isCacheFresh(cacheFile) {
    if (this.cacheFreshnessDays <= 0) return false;
    try {
      const stat = await fs.stat(cacheFile);
      const ageMs = Date.now() - stat.mtimeMs;
      const ageDays = ageMs / (1000 * 60 * 60 * 24);
      return ageDays < this.cacheFreshnessDays;
    } catch {
      return false; // File doesn't exist
    }
  }

  /**
   * Enforce rate limiting: sleep between fetches
   */
  async _enforceRateLimit() {
    const elapsed = Date.now() - this._lastFetchTime;
    const requiredDelay = this.delayMs + Math.random() * this.delayJitterMs;
    if (this._lastFetchTime > 0 && elapsed < requiredDelay) {
      const sleepMs = Math.round(requiredDelay - elapsed);
      console.log(`   💤 Rate limit: waiting ${(sleepMs / 1000).toFixed(1)}s...`);
      await new Promise(resolve => setTimeout(resolve, sleepMs));
    }
    this._lastFetchTime = Date.now();
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
          // Cache exists and has content — check freshness
          if (retryAttempt === 0 && await this._isCacheFresh(cacheFile)) {
            const stat = await fs.stat(cacheFile);
            const ageDays = ((Date.now() - stat.mtimeMs) / (1000 * 60 * 60 * 24)).toFixed(1);
            console.log(`   📂 Cache fresh (${ageDays}d old, limit ${this.cacheFreshnessDays}d): ${path.basename(cacheFile)}`);
            return cached;
          }
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

    // Check session fetch limit
    if (this.maxFetchesPerSession > 0 && this._fetchCount >= this.maxFetchesPerSession) {
      console.log(`   🛑 Session limit reached (${this.maxFetchesPerSession} fetches). Using stale cache if available.`);
      try {
        const stale = await fs.readFile(cacheFile, 'utf-8');
        if (stale && stale.trim().length > 0) return stale;
      } catch { /* no cache */ }
      throw new Error(`Session fetch limit (${this.maxFetchesPerSession}) reached and no cache available`);
    }

    // Rate limit before live fetch
    await this._enforceRateLimit();
    this._fetchCount++;
    
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

    // Reject error pages (403 Forbidden, 404 Not Found, etc.)
    // These can be returned as valid HTML by Puppeteer even after stealth bypass
    const lowerHtml = html.toLowerCase();
    if (lowerHtml.includes('403 - forbidden') || lowerHtml.includes('access is denied') ||
        (lowerHtml.includes('server error') && html.length < 2000)) {
      console.log(`   ⚠️  Error page detected (403/access denied) — not caching`);
      throw new Error('Server returned error page (403 Forbidden)');
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
   * Batch fetch multiple URLs — sequential with rate limiting (no parallelism)
   * Concurrency is forced to 1 to respect rate limits and avoid IP bans.
   * @param {Array<{url: string, filename: string}>} requests - Array of requests
   * @param {number} _concurrency - Ignored (always 1 for safety)
   * @param {boolean} useCache - Whether to use cached versions
   * @returns {Promise<Array<{url: string, html: string, error: Error}>>}
   */
  async batchFetch(requests, _concurrency = 1, useCache = true) {
    const results = [];
    let completed = 0;
    let skipped = 0;
    let fetched = 0;
    
    console.log(`   📥 Batch processing ${requests.length} URLs (sequential, ${this.delayMs}-${this.delayMs + this.delayJitterMs}ms delay)`);
    
    for (const request of requests) {
      try {
        const html = await this.fetch(request.url, useCache);
        results.push({ url: request.url, html, error: null });
        // Detect if it was a cache hit (no rate limit sleep = from cache)
        completed++;
      } catch (error) {
        results.push({ url: request.url, html: null, error });
        completed++;
        if (error.message && error.message.includes('Session fetch limit')) {
          console.log(`\n   🛑 Stopping batch — session limit reached after ${fetched} live fetches`);
          // Fill remaining with cache-only attempts
          break;
        }
      }
      if (completed % 10 === 0) {
        process.stdout.write(`\r   Progress: ${completed}/${requests.length}`);
      }
    }
    console.log(`\n   ✓ Batch done: ${completed} processed`);
    
    return results;
  }
}

module.exports = HtmlFetcher;
