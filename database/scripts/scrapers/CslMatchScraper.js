const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');
const CslFixturesParser = require('../infrastructure/parsers/CslFixturesParser');
const DivisionRepository = require('../domain/repositories/DivisionRepository');
const MatchRepository = require('../domain/repositories/MatchRepository');
const ScrapedTeamRepository = require('../domain/repositories/ScrapedTeamRepository');

/**
 * Cosmopolitan Soccer League Match Scraper
 * 
 * Extracts match results from CSL fixtures page
 */
class CslMatchScraper {
  constructor(client) {
    this.client = client;
    this.fetcher = new HtmlFetcher('database/scraped-html/csl');
    this.parser = new CslFixturesParser();
    this.divisionRepo = new DivisionRepository(client);
    this.matchRepo = new MatchRepository(client);
    this.scrapedTeamRepo = new ScrapedTeamRepository(client);
  }
  
  /**
   * Main scraping logic
   */
  async scrape() {
    console.log('\n⚽ CSL Match Scraper');
    console.log('============================================================');
    
    try {
      // Fetch fixtures page
      const url = 'https://www.cosmosoccerleague.com/CSL/Fixtures/';
      const html = await this.fetcher.fetch(url, 'csl-fixtures');
      
      // Parse matches
      const matches = this.parser.parse(html);
      console.log(`📋 Found ${matches.length} matches\n`);
      
      // Get CSL divisions for team lookup
      const divisions = await this.getCslDivisions();
      
      for (const matchData of matches) {
        await this.processMatch(matchData, divisions);
      }
      
      console.log('\n✅ Match scraping completed');
      
    } catch (error) {
      console.error('❌ Error:', error.message);
      throw error;
    }
  }
  
  /**
   * Get all CSL divisions
   */
  async getCslDivisions() {
    const result = await this.client.query(`
      SELECT d.id, d.name
      FROM divisions d
      JOIN conferences c ON d.conference_id = c.id
      JOIN seasons s ON c.season_id = s.id
      JOIN leagues l ON s.league_id = l.id
      WHERE l.name = 'Cosmopolitan Soccer League'
    `);
    
    return result.rows;
  }
  
  /**
   * Process a single match
   */
  async processMatch(matchData, divisions) {
    // Find teams
    const homeTeam = await this.scrapedTeamRepo.findByName(matchData.homeTeam);
    const awayTeam = await this.scrapedTeamRepo.findByName(matchData.awayTeam);
    
    if (!homeTeam || !awayTeam) {
      console.log(`   ⚠️  Teams not found: ${matchData.homeTeam} vs ${matchData.awayTeam}`);
      return;
    }
    
    // Determine division (try to infer from team names)
    const division = divisions[0]; // For now, use first division - TODO: improve logic
    
    // Check if match already exists
    const existing = await this.matchRepo.findByExternalId(matchData.externalId);
    if (existing) {
      return; // Skip existing matches
    }
    
    // Create match
    await this.matchRepo.create({
      divisionId: division.id,
      homeTeamId: homeTeam.id,
      awayTeamId: awayTeam.id,
      homeScore: matchData.homeScore,
      awayScore: matchData.awayScore,
      matchDate: matchData.date ? new Date(matchData.date) : new Date(),
      externalId: matchData.externalId,
      status: matchData.homeScore !== null ? 'completed' : 'scheduled'
    });
    
    console.log(`   ✅ ${matchData.homeTeam} ${matchData.homeScore}-${matchData.awayScore} ${matchData.awayTeam}`);
  }
}

// Run if called directly
async function main() {
  const { Pool } = require('pg');
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASS || 'footballhome_pass',
  });
  
  const client = await pool.connect();
  
  try {
    const scraper = new CslMatchScraper(client);
    await scraper.scrape();
    console.log('CslMatchScraper completed successfully');
  } finally {
    client.release();
    await pool.end();
  }
  process.exit(0);
}

if (require.main === module) {
  main().catch(error => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = CslMatchScraper;
