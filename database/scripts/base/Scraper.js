const DataRegistry = require('../services/DataRegistry');
const ClubManager = require('../services/ClubManager');
const SportDivisionManager = require('../services/SportDivisionManager');
const TeamLinker = require('../services/TeamLinker');
const SqlFileWriter = require('../services/SqlFileWriter');
const DataLoader = require('../services/DataLoader');

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
    
    // Legacy data structure (for backward compatibility)
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
      coaches: new Map(),
      teamCoaches: new Map(),
      events: new Map(),
      matches: new Map(),
      externalIdentities: new Map()
    };
    
    // New OOP services
    this.registry = new DataRegistry();
    this.clubManager = new ClubManager(this.registry, this);
    this.sportDivisionManager = new SportDivisionManager(this.registry, this);
    this.teamLinker = new TeamLinker(this.registry, this.clubManager, this.sportDivisionManager, this);
    this.sqlWriter = new SqlFileWriter(this);
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
   * Link teams to clubs and sport_divisions
   * Should be called in transformData() after all teams are loaded
   * 
   * @param {number} sourceSystemId - Source system ID
   * @param {string} leagueName - League name for context
   */
  async linkTeamsToClubs(sourceSystemId, leagueName) {
    this.log(`\n🔗 Linking teams to clubs and sport_divisions...`);
    
    // Load existing clubs/sport_divisions from SQL files first
    const dataLoader = new DataLoader(this.registry, this);
    dataLoader.loadAllExistingData();
    
    // Now link teams
    this.teamLinker.linkAllTeams(sourceSystemId, leagueName);
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
