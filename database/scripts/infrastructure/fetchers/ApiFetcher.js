/**
 * API Fetcher
 * 
 * Generic fetcher for REST APIs.
 * Returns raw JSON data.
 */
class ApiFetcher {
  /**
   * Fetch data from API endpoint
   * @param {string} url - API endpoint URL
   * @returns {Promise<any>} Raw JSON response
   */
  async fetch(url) {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`);
    }
    
    return await response.json();
  }
}

module.exports = ApiFetcher;
