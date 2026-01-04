const { Pool } = require('pg');
const UsStatesParser = require('../infrastructure/parsers/UsStatesParser');
const StateRepository = require('../domain/repositories/StateRepository');
const CountryRepository = require('../domain/repositories/CountryRepository');

/**
 * US States Scraper
 * 
 * Populates US states (all 50 + DC) into the database.
 * Links to USA country via FK.
 */
class UsStatesScraper {
  constructor(parser, stateRepo, countryRepo) {
    this.parser = parser;
    this.stateRepo = stateRepo;
    this.countryRepo = countryRepo;
  }
  
  /**
   * Main entry point
   */
  async run() {
    console.log(`\n🗺️  US States Scraper`);
    console.log('='.repeat(60));
    
    try {
      await this.scrapeAndSave();
      console.log('\n✅ Scrape completed successfully\n');
    } catch (error) {
      console.error('\n❌ Scrape failed:', error.message);
      throw error;
    }
  }
  
  async scrapeAndSave() {
    console.log('🔍 Parsing US states data...');
    const states = this.parser.parse();
    console.log(`   ✓ Parsed ${states.length} states`);
    
    console.log('🔍 Looking up USA country...');
    const usa = await this.countryRepo.findByCode('USA');
    
    if (!usa) {
      throw new Error('USA country not found. Run CountryScraperV2 first.');
    }
    
    console.log(`   ✓ Found USA (id=${usa.id})`);
    
    // Link all states to USA
    for (const state of states) {
      state.countryId = usa.id;
    }
    
    console.log('💾 Saving to database...');
    const stats = await this.stateRepo.upsertMany(states);
    console.log(`   ✓ Inserted: ${stats.totalInserted}, Updated: ${stats.totalUpdated}`);
  }
  
  /**
   * Factory method to create scraper with all dependencies
   */
  static async create() {
    const pool = new Pool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'footballhome',
      user: process.env.DB_USER || 'footballhome_user',
      password: process.env.DB_PASSWORD || 'footballhome_pass',
    });
    
    const client = await pool.connect();
    
    // Create all dependencies
    const parser = new UsStatesParser();
    const stateRepo = new StateRepository(client);
    const countryRepo = new CountryRepository(client);
    
    // Inject dependencies
    const scraper = new UsStatesScraper(parser, stateRepo, countryRepo);
    
    // Store pool and client for cleanup
    scraper._pool = pool;
    scraper._client = client;
    
    return scraper;
  }
  
  async cleanup() {
    if (this._client) {
      this._client.release();
    }
    if (this._pool) {
      await this._pool.end();
    }
  }
}

// CLI execution
if (require.main === module) {
  (async () => {
    const scraper = await UsStatesScraper.create();
    
    try {
      await scraper.run();
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    } finally {
      await scraper.cleanup();
    }
  })();
}

module.exports = UsStatesScraper;
