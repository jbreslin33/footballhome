const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

/**
 * HTML Fetcher
 * 
 * Fetches HTML from URLs and caches to disk.
 * This allows:
 * 1. Scraping from live URLs
 * 2. Saving HTML for replay/debugging
 * 3. Rebuilding database from cached HTML without re-fetching
 */
class HtmlFetcher {
  constructor(cacheDir = null) {
    // Default cache directory
    this.cacheDir = cacheDir || path.join(__dirname, '../../../scraped-html/apsl');
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
    const timeoutMs = retryAttempt > 0 ? 5000 : 10000; // Shorter timeout on retries
    
    if (retryAttempt === 0) {
      console.log(`   🌐 Fetching: ${url}`);
    }
    
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
    
    try {
      const response = await fetch(url, { 
        signal: controller.signal,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
      });
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const html = await response.text();
      
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
    } catch (error) {
      clearTimeout(timeoutId);
      
      // On final retry, create skip marker
      if (retryAttempt >= 2) {
        try {
          await fs.mkdir(this.cacheDir, { recursive: true });
          await fs.writeFile(skipMarker, `Failed after ${retryAttempt + 1} attempts: ${error.message} at ${new Date().toISOString()}`, 'utf-8');
        } catch {
          // Ignore skip marker write errors
        }
      }
      
      if (error.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeoutMs/1000}s`);
      }
      throw error;
    }
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
