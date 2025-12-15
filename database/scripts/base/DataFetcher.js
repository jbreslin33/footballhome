/**
 * Abstract DataFetcher Base Class
 * Strategy pattern for different data fetching methods
 */
class DataFetcher {
  async fetch(url) {
    throw new Error(`${this.constructor.name} must implement fetch()`);
  }
}

module.exports = DataFetcher;
