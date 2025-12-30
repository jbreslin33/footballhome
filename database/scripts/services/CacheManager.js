const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

/**
 * CacheManager - Manages file-based caching of fetched HTML content
 * 
 * Stores rendered HTML in git-committed cache files to avoid:
 * - Bot detection issues
 * - Slow repeated scraping
 * - Unnecessary load on source websites
 * 
 * Cache files are stored in database/scraped-html/ and committed to git.
 */
class CacheManager {
    /**
     * @param {string} cacheDir - Root directory for cache files (e.g., 'database/scraped-html/apsl')
     * @param {Object} fetcher - Fetcher instance (Puppeteer or Axios) to use for initial fetch
     * @param {number} ttlHours - Cache TTL in hours (default: 24)
     */
    constructor(cacheDir, fetcher, ttlHours = 24) {
        this.cacheDir = cacheDir;
        this.fetcher = fetcher;
        this.ttlMs = ttlHours * 60 * 60 * 1000;
        
        // Ensure cache directory exists
        if (!fs.existsSync(cacheDir)) {
            fs.mkdirSync(cacheDir, { recursive: true });
        }
    }

    /**
     * Generate cache filename from URL
     * Uses hash of URL to avoid filename issues with special characters
     * 
     * @param {string} url - URL to generate cache key for
     * @returns {string} - Cache filename (e.g., 'team-1001-a3b5c7d9.html')
     */
    getCacheFilename(url) {
        // Extract readable part from URL (e.g., 'team-1001' from '/Team/1001')
        const urlPath = new URL(url).pathname;
        const readable = urlPath
            .replace(/^\//, '')
            .replace(/\//g, '-')
            .toLowerCase()
            .substring(0, 30);
        
        // Add hash suffix to ensure uniqueness
        const hash = crypto
            .createHash('md5')
            .update(url)
            .digest('hex')
            .substring(0, 8);
        
        return `${readable}-${hash}.html`;
    }

    /**
     * Get full cache file path for URL
     * 
     * @param {string} url - URL to get cache path for
     * @returns {string} - Absolute path to cache file
     */
    getCachePath(url) {
        return path.join(this.cacheDir, this.getCacheFilename(url));
    }

    /**
     * Check if cached file exists and is fresh
     * 
     * @param {string} url - URL to check cache for
     * @param {boolean} forceRefresh - If true, ignore cache
     * @returns {boolean} - True if cache exists and is fresh
     */
    isCached(url, forceRefresh = false) {
        if (forceRefresh) {
            return false;
        }

        const cachePath = this.getCachePath(url);
        
        if (!fs.existsSync(cachePath)) {
            return false;
        }

        // Check if cache is still fresh
        const stats = fs.statSync(cachePath);
        const age = Date.now() - stats.mtimeMs;
        
        return age < this.ttlMs;
    }

    /**
     * Read cached HTML from file
     * 
     * @param {string} url - URL to read cache for
     * @returns {string|null} - Cached HTML or null if not found
     */
    readCache(url) {
        const cachePath = this.getCachePath(url);
        
        if (!fs.existsSync(cachePath)) {
            return null;
        }

        console.log(`  ✓ Reading from cache: ${path.basename(cachePath)}`);
        return fs.readFileSync(cachePath, 'utf8');
    }

    /**
     * Write HTML to cache file
     * 
     * @param {string} url - URL to cache
     * @param {string} html - HTML content to cache
     */
    writeCache(url, html) {
        const cachePath = this.getCachePath(url);
        
        fs.writeFileSync(cachePath, html, 'utf8');
        console.log(`  ✓ Wrote to cache: ${path.basename(cachePath)} (${(html.length / 1024).toFixed(1)} KB)`);
    }

    /**
     * Fetch HTML with caching
     * 
     * Strategy:
     * 1. Check if cached file exists and is fresh
     * 2. If yes, read from cache (instant)
     * 3. If no, fetch from source, save to cache, return
     * 
     * @param {string} url - URL to fetch
     * @param {boolean} forceRefresh - If true, bypass cache and re-fetch
     * @returns {Promise<string>} - HTML content
     */
    async fetch(url, forceRefresh = false) {
        // Check cache first
        if (this.isCached(url, forceRefresh)) {
            return this.readCache(url);
        }

        // Fetch from source
        console.log(`  → Fetching from source: ${url}`);
        const html = await this.fetcher.fetch(url);
        
        // Save to cache
        this.writeCache(url, html);
        
        return html;
    }

    /**
     * Clear all cached files
     * Useful for testing or forced refresh
     */
    clearCache() {
        const files = fs.readdirSync(this.cacheDir);
        
        for (const file of files) {
            if (file.endsWith('.html')) {
                fs.unlinkSync(path.join(this.cacheDir, file));
            }
        }
        
        console.log(`  ✓ Cleared ${files.length} cached files`);
    }

    /**
     * Get cache statistics
     * 
     * @returns {Object} - Cache stats (count, total size, oldest/newest)
     */
    getStats() {
        const files = fs.readdirSync(this.cacheDir)
            .filter(f => f.endsWith('.html'))
            .map(f => {
                const fullPath = path.join(this.cacheDir, f);
                const stats = fs.statSync(fullPath);
                return {
                    name: f,
                    size: stats.size,
                    mtime: stats.mtimeMs
                };
            });

        if (files.length === 0) {
            return { count: 0, totalSize: 0, oldest: null, newest: null };
        }

        const totalSize = files.reduce((sum, f) => sum + f.size, 0);
        const oldest = new Date(Math.min(...files.map(f => f.mtime)));
        const newest = new Date(Math.max(...files.map(f => f.mtime)));

        return {
            count: files.length,
            totalSize,
            totalSizeMB: (totalSize / 1024 / 1024).toFixed(2),
            oldest,
            newest
        };
    }
}

module.exports = CacheManager;
