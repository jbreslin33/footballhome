const fs = require('fs').promises;

/**
 * File Fetcher
 * 
 * Fetches data from local HTML files (for testing with cached pages).
 * Returns raw HTML content.
 */
class FileFetcher {
  /**
   * Fetch data from local file
   * @param {string} filePath - Absolute path to file
   * @returns {Promise<string>} Raw HTML content
   */
  async fetch(filePath) {
    try {
      const content = await fs.readFile(filePath, 'utf-8');
      return content;
    } catch (error) {
      throw new Error(`Failed to read file ${filePath}: ${error.message}`);
    }
  }
}

module.exports = FileFetcher;
