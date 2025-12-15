const https = require('https');
const DataFetcher = require('../base/DataFetcher');

/**
 * HTTP/HTTPS Fetcher
 * For fetching HTML pages via standard HTTP requests
 */
class HttpFetcher extends DataFetcher {
  constructor(options = {}) {
    super();
    this.timeout = options.timeout || 30000;
    this.maxRetries = options.maxRetries || 3;
    this.retryDelay = options.retryDelay || 1000;
  }

  async fetch(url, attempt = 1) {
    return new Promise((resolve, reject) => {
      const req = https.get(url, { timeout: this.timeout }, (res) => {
        // Handle redirects
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          return resolve(this.fetch(res.headers.location, attempt));
        }

        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(data);
          } else {
            reject(new Error(`HTTP ${res.statusCode}: ${url}`));
          }
        });
      });

      req.on('error', async (error) => {
        if (attempt < this.maxRetries && this.isRetryableError(error)) {
          console.error(`   ⚠ Network error, retrying (${attempt}/${this.maxRetries})...`);
          await this.sleep(this.retryDelay * attempt);
          try {
            const result = await this.fetch(url, attempt + 1);
            resolve(result);
          } catch (retryError) {
            reject(retryError);
          }
        } else {
          reject(error);
        }
      });

      req.on('timeout', () => {
        req.destroy();
        reject(new Error(`Timeout after ${this.timeout}ms: ${url}`));
      });
    });
  }

  isRetryableError(error) {
    return error.code === 'ECONNRESET' || 
           error.code === 'ETIMEDOUT' || 
           error.syscall === 'read';
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

module.exports = HttpFetcher;
