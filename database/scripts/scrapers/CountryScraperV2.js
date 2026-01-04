const { Pool } = require('pg');
const ApiFetcher = require('../infrastructure/fetchers/ApiFetcher');
const RestCountriesParser = require('../infrastructure/parsers/RestCountriesParser');
const CountryRepository = require('../domain/repositories/CountryRepository');
const ContinentRepository = require('../domain/repositories/ContinentRepository');
const ScrapeTargetService = require('../application/services/ScrapeTargetService');

/**
 * Country Scraper V2 - Clean OOP Architecture
 * 
 * Orchestrates the scraping workflow using injected dependencies:
 * 1. Fetcher gets data from API
 * 2. Parser transforms to domain models
 * 3. Repository saves to database
 * 4. Service tracks scrape state
 * 
 * This is a thin orchestrator - all logic is in reusable components.
 */
class CountryScraperV2 {
  constructor(fetcher, parser, countryRepo, continentRepo, targetService) {
    this.fetcher = fetcher;
    this.parser = parser;
    this.countryRepo = countryRepo;
    this.continentRepo = continentRepo;
    this.targetService = targetService;
  }
  
  /**
   * Main entry point
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
    console.log('📋 Getting/creating scrape target...');
    const target = await this.targetService.getOrCreate({
      sourceSystemId: 6,  // REST Countries API (we'll add this to source_systems)
      scraperTypeId: 3,   // api_client
      targetTypeId: 17,   // countries (we'll add this to scrape_target_types)
      url: 'https://restcountries.com/v3.1/all?fields=cca3,name,fifa,continents',
      label: 'REST Countries API - All Countries'
    });
    console.log(`   Target ID: ${target.id}, URL: ${target.url}`);
    
    await this.scrapeAndSave(target);
    
    console.log('✓ Marking target as initialized...');
    await this.targetService.markInitialized(target.id);
  }
  
  async sync() {
    console.log('📋 Getting scrape target...');
    const target = await this.targetService.getTarget(6, 17);
    
    if (!target) {
      throw new Error('Scrape target not found. Run discover mode first.');
    }
    
    console.log(`   Target ID: ${target.id}, Last synced: ${target.last_synced_at}`);
    
    await this.scrapeAndSave(target);
    
    console.log('✓ Updating sync timestamp...');
    await this.targetService.updateSyncTime(target.id);
  }
  
  async scrapeAndSave(target) {
    console.log('📥 Fetching data from API...');
    const rawData = await this.fetcher.fetch(target.url);
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
    const targetService = new ScrapeTargetService(client);
    
    // Inject dependencies
    const scraper = new CountryScraperV2(
      fetcher,
      parser,
      countryRepo,
      continentRepo,
      targetService
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
