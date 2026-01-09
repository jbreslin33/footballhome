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
   * @returns {Promise<string>} Raw HTML content
   */
  async fetch(url, useCache = true) {
    const cacheFile = path.join(this.cacheDir, this.getCacheFilename(url));
    
    // Try to use cached version if requested
    if (useCache) {
      try {
        const cached = await fs.readFile(cacheFile, 'utf-8');
        
        // Validate cached content - reject empty or invalid files
        if (!cached || cached.trim().length === 0) {
          console.log(`   ⚠️  Cached file is empty, re-fetching: ${path.basename(cacheFile)}`);
          // Fall through to fetch from URL
        } else {
          console.log(`   📂 Using cached HTML: ${path.basename(cacheFile)}`);
          return cached;
        }
      } catch (error) {
        // Cache miss - continue to fetch
      }
    }
    
    // Fetch from URL
    console.log(`   🌐 Fetching: ${url}`);
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const html = await response.text();
    
    // Save to cache
    try {
      await fs.mkdir(this.cacheDir, { recursive: true });
      await fs.writeFile(cacheFile, html, 'utf-8');
      console.log(`   💾 Cached to: ${path.basename(cacheFile)}`);
    } catch (error) {
      console.warn(`   ⚠️  Failed to cache HTML: ${error.message}`);
      // Don't fail the scrape if caching fails
    }
    
    return html;
  }
}

module.exports = HtmlFetcher;
