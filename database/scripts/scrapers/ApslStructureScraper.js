const { Pool } = require('pg');
const FileFetcher = require('../infrastructure/fetchers/FileFetcher');
const ApslStandingsParser = require('../infrastructure/parsers/ApslStandingsParser');
const OrganizationRepository = require('../domain/repositories/OrganizationRepository');
const LeagueRepository = require('../domain/repositories/LeagueRepository');
const SeasonRepository = require('../domain/repositories/SeasonRepository');
const ConferenceRepository = require('../domain/repositories/ConferenceRepository');

/**
 * APSL Structure Scraper
 * 
 * Extracts soccer hierarchy from APSL standings page:
 * Organization → League → Season → Conferences
 * 
 * This is a thin orchestrator - all logic is in reusable components.
 */
class ApslStructureScraper {
  constructor(fetcher, parser, orgRepo, leagueRepo, seasonRepo, conferenceRepo) {
    this.fetcher = fetcher;
    this.parser = parser;
    this.orgRepo = orgRepo;
    this.leagueRepo = leagueRepo;
    this.seasonRepo = seasonRepo;
    this.conferenceRepo = conferenceRepo;
  }
  
  /**
   * Main entry point
   */
  async run() {
    console.log(`\n⚽ APSL Structure Scraper - Simple Test`);
    console.log('='.repeat(60));
    
    try {
      await this.scrapeAndSave();
      console.log('\n✅ Scrape completed successfully\n');
    } catch (error) {
      console.error('\n❌ Scrape failed:', error.message);
      console.error(error.stack);
      throw error;
    }
  }
  
  async scrapeAndSave() {
    // Use local HTML file for testing
    const filePath = '/home/jbreslin/sandbox/github/footballhome/database/scraped-html/apsl/standings-fa7d5bab.html';
    
    console.log('📄 Reading from local file...');
    console.log(`   ${filePath}`);
    const html = await this.fetcher.fetch(filePath);
    console.log(`   ✓ Read ${html.length} bytes`);
    
    console.log('🔍 Parsing HTML into domain models...');
    const { organization, league, season, conferences } = this.parser.parse(html);
    console.log(`   ✓ Found: ${organization.name}`);
    console.log(`   ✓ League: ${league.name}`);
    console.log(`   ✓ Season: ${season.name}`);
    console.log(`   ✓ Conferences: ${conferences.length}`);
    
    console.log('💾 Saving to database...');
    
    // 1. Upsert organization
    const orgResult = await this.orgRepo.upsert(organization);
    console.log(`   ✓ Organization: ${orgResult.inserted ? 'inserted' : 'updated'} (id=${orgResult.id})`);
    
    // 2. Upsert league (link to organization)
    league.organizationId = orgResult.id;
    const leagueResult = await this.leagueRepo.upsert(league);
    console.log(`   ✓ League: ${leagueResult.inserted ? 'inserted' : 'updated'} (id=${leagueResult.id})`);
    
    // 3. Upsert season (link to league)
    season.leagueId = leagueResult.id;
    const seasonResult = await this.seasonRepo.upsert(season);
    console.log(`   ✓ Season: ${seasonResult.inserted ? 'inserted' : 'updated'} (id=${seasonResult.id})`);
    
    // 4. Upsert conferences (link to season)
    for (const conference of conferences) {
      conference.seasonId = seasonResult.id;
    }
    const confResult = await this.conferenceRepo.upsertMany(conferences);
    console.log(`   ✓ Conferences: ${confResult.totalInserted} inserted, ${confResult.totalUpdated} updated`);
    
    // Print conference details
    for (const conference of conferences) {
      console.log(`     - ${conference.name} (external_id=${conference.externalId})`);
    }
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
    const fetcher = new FileFetcher();
    const parser = new ApslStandingsParser();
    const orgRepo = new OrganizationRepository(client);
    const leagueRepo = new LeagueRepository(client);
    const seasonRepo = new SeasonRepository(client);
    const conferenceRepo = new ConferenceRepository(client);
    
    // Inject dependencies
    const scraper = new ApslStructureScraper(
      fetcher,
      parser,
      orgRepo,
      leagueRepo,
      seasonRepo,
      conferenceRepo
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
  (async () => {
    const scraper = await ApslStructureScraper.create();
    
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

module.exports = ApslStructureScraper;
