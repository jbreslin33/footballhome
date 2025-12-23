const https = require('https');
const DataFetcher = require('../base/DataFetcher');

/**
 * API Client Fetcher
 * For authenticated REST API calls (e.g., GroupMe, Google Places)
 */
class ApiClient extends DataFetcher {
  constructor(config = {}) {
    super();
    this.apiKey = config.apiKey;
    this.baseUrl = config.baseUrl;
    this.headers = config.headers || {};
    this.insecure = config.insecure || false;
  }

  async fetch(endpoint, options = {}) {
    const url = this.buildUrl(endpoint);
    
    return new Promise((resolve, reject) => {
      const reqOptions = {
        method: options.method || 'GET',
        headers: {
          ...this.headers,
          ...options.headers
        },
        timeout: options.timeout || 30000,
        rejectUnauthorized: !this.insecure
      };

      const req = https.request(url, reqOptions, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            
            // Handle API-specific error formats
            if (this.isError(json, res.statusCode)) {
              reject(new Error(this.getErrorMessage(json)));
            } else {
              resolve(this.extractResponse(json));
            }
          } catch (e) {
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(data); // Non-JSON response
            } else {
              reject(new Error(`HTTP ${res.statusCode}: ${data}`));
            }
          }
        });
      });

      req.on('error', reject);
      req.on('timeout', () => {
        req.destroy();
        reject(new Error(`Request timeout: ${url}`));
      });

      if (options.body) {
        req.write(JSON.stringify(options.body));
      }

      req.end();
    });
  }

  buildUrl(endpoint) {
    const base = this.baseUrl || '';
    const path = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
    const separator = endpoint.includes('?') ? '&' : '?';
    const auth = this.apiKey ? `${separator}token=${this.apiKey}` : '';
    
    return `${base}${path}${auth}`;
  }

  // Override in subclasses for API-specific error handling
  isError(json, statusCode) {
    return statusCode >= 400;
  }

  getErrorMessage(json) {
    return json.error || json.message || 'API request failed';
  }

  extractResponse(json) {
    return json;
  }
}

module.exports = ApiClient;
