const { Pool } = require('pg');
const ApiFetcher = require('../infrastructure/fetchers/ApiFetcher');
const RestCountriesParser = require('../infrastructure/parsers/RestCountriesParser');
const CountryRepository = require('../domain/repositories/CountryRepository');
const ContinentRepository = require('../domain/repositories/ContinentRepository');

/**
 * Country Scraper V2 - Clean OOP Architecture
 * 
 * Orchestrates the scraping workflow using injected dependencies:
 * 1. Fetcher gets data from API
 * 2. Parser transforms to domain models
 * 3. Repository saves to database
 *
 * Data Source: Hardcoded URL (managed in this file)
 *
 * This is a thin orchestrator - all logic is in reusable components.
 */
class CountryScraperV2 {
  constructor(fetcher, parser, countryRepo, continentRepo) {
    this.apiUrl = 'https://restcountries.com/v3.1/all?fields=cca3,name,fifa,continents';
    this.fetcher = fetcher;
    this.parser = parser;
    this.countryRepo = countryRepo;
    this.continentRepo = continentRepo;
   */
  async run(mode = 'discover') {
    console.log(`\n🌍 Country Scraper V2 (OOP) - ${mode.toUpperCase()} mode`);
    console.log('='.repeat(60));
    
    try {
      if (mode === 'discover') {
        await this.discover();
      } else if (mode === 'sync') {
        await this.sync();
      } else {
        throw new Error(`Unknown mode: ${mode}. Use 'discover' or 'sync'.`);
      }
      
      console.log('\n✅ Scrape completed successfully\n');
    } catch (error) {
      console.error('\n❌ Scrape failed:', error.message);
      throw error;
    }
  }
  
  async discover() {
    await this.scrapeAndSave();
    console.log('✓ Discovery complete');
  }
  
  async sync() {
    await this.scrapeAndSave();
    console.log('✓ Sync complete');
  }
  
  async scrapeAndSave() {
    console.log('📥 Fetching data from API...');
    const rawData = await this.fetcher.fetch(this.apiUrl);
    console.log(`   Received ${rawData.length} countries`);
    
    console.log('🔍 Parsing data into domain models...');
    const countries = this.parser.parse(rawData);
    console.log(`   Validated ${countries.length} countries`);
    
    console.log('🗺️  Loading continent mappings...');
    const continentMap = await this.continentRepo.getContinentMap();
    console.log(`   Loaded ${Object.keys(continentMap).length} continents`);
    
    console.log('💾 Saving to database...');
    const stats = await this.countryRepo.upsertMany(countries, continentMap);
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
    const fetcher = new ApiFetcher();
    const parser = new RestCountriesParser();
    const countryRepo = new CountryRepository(client);
    const continentRepo = new ContinentRepository(client);
    
    // Inject dependencies
    const scraper = new CountryScraperV2(
      fetcher,
      parser,
      countryRepo,
      continentRepo
    );
    
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
  const mode = process.argv[2] || 'discover';
  
  (async () => {
    const scraper = await CountryScraperV2.create();
    
    try {
      await scraper.run(mode);
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    } finally {
      await scraper.cleanup();
    }
  })();
}

module.exports = CountryScraperV2;
