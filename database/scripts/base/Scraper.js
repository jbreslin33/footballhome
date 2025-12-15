/**
 * Abstract Base Scraper Class
 * 
 * Template method pattern - defines the scraping workflow that all scrapers follow.
 * Subclasses implement specific steps for their data source.
 */
class Scraper {
  constructor(config) {
    this.config = config;
    this.mode = config.mode || 'full';
    this.teamFilter = config.teamFilter || null; // Filter teams by name substring
    this.data = {
      leagues: new Map(),
      conferences: new Map(),
      divisions: new Map(),
      clubs: new Map(),
      sportDivisions: new Map(),
      teams: new Map(),
      users: new Map(),
      players: new Map(),
      teamPlayers: new Map(),
      events: new Map(),
      matches: new Map(),
      externalIdentities: new Map()
    };
  }

  /**
   * Main template method - defines the scraping workflow
   * This is the public API that clients call
   */
  async scrape() {
    try {
      console.error(`\n🏆 ${this.config.name} Scraper`);
      console.error('='.repeat(this.config.name.length + 11));
      console.error(`Mode: ${this.mode}\n`);

      await this.initialize();
      await this.authenticate();
      await this.fetchData();
      await this.transformData();
      await this.generateOutput();
      await this.cleanup();

      console.error('\n✅ Scraping complete\n');
    } catch (error) {
      console.error(`\n❌ Fatal error: ${error.message}`);
      if (error.stack) console.error(error.stack);
      process.exit(1);
    }
  }

  /**
   * Abstract methods that subclasses MUST implement
   */
  async initialize() {
    throw new Error(`${this.constructor.name} must implement initialize()`);
  }

  async fetchData() {
    throw new Error(`${this.constructor.name} must implement fetchData()`);
  }

  async transformData() {
    throw new Error(`${this.constructor.name} must implement transformData()`);
  }

  async generateOutput() {
    throw new Error(`${this.constructor.name} must implement generateOutput()`);
  }

  /**
   * Optional methods that subclasses CAN override
   */
  async authenticate() {
    // Default: no authentication needed
    // Override if your scraper needs authentication
  }

  async cleanup() {
    // Default: no cleanup needed
    // Override if your scraper needs cleanup (e.g., close browser)
  }

  /**
   * Helper methods available to all subclasses
   */
  shouldScrapeTeams() {
    return !['structure'].includes(this.mode);
  }

  shouldScrapePlayers() {
    return ['players', 'full'].includes(this.mode);
  }

  shouldScrapeSchedules() {
    return this.config.includeSchedules === true;
  }

  /**
   * Check if we should filter teams by name
   */
  hasTeamFilter() {
    return this.teamFilter !== null;
  }

  /**
   * Check if a team name matches the filter
   */
  matchesTeamFilter(teamName) {
    if (!this.hasTeamFilter()) return true;
    return teamName.toLowerCase().includes(this.teamFilter.toLowerCase());
  }

  isFullMode() {
    return this.mode === 'full' || this.mode === 'players';
  }

  log(message) {
    console.error(message);
  }

  logError(message, error) {
    console.error(`❌ ${message}`);
    if (error) console.error(`   ${error.message}`);
  }

  logSuccess(message) {
    console.error(`✓ ${message}`);
  }

  logWarning(message) {
    console.error(`⚠ ${message}`);
  }
}

module.exports = Scraper;
