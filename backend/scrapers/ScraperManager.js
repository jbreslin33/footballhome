const { Pool } = require('pg');
const APSLScraper = require('./APSLScraper');
const CASAScraper = require('./CASAScraper');

/**
 * Scraper Manager
 * Manages and coordinates multiple league scrapers
 */
class ScraperManager {
  constructor(config) {
    this.pool = new Pool({
      user: config.POSTGRES_USER || 'footballhome_user',
      host: config.POSTGRES_HOST || 'localhost', 
      database: config.POSTGRES_DB || 'footballhome',
      password: config.POSTGRES_PASSWORD || 'footballhome_pass',
      port: config.POSTGRES_PORT || 5432,
    });

    this.season = config.season || '2024';
    this.scrapers = new Map();
    
    this.initializeScrapers();
  }

  /**
   * Initialize all available scrapers
   */
  initializeScrapers() {
    // APSL Scraper
    const apslScraper = new APSLScraper({
      pool: this.pool,
      season: this.season
    });
    this.scrapers.set('apsl', apslScraper);

    // CASA Scraper
    const casaScraper = new CASAScraper({
      pool: this.pool,
      season: this.season
    });
    this.scrapers.set('casa', casaScraper);

    console.log(`Initialized ${this.scrapers.size} scrapers: ${Array.from(this.scrapers.keys()).join(', ')}`);
  }

  /**
   * Run specific scraper
   */
  async runScraper(scraperName) {
    const scraper = this.scrapers.get(scraperName.toLowerCase());
    
    if (!scraper) {
      throw new Error(`Scraper '${scraperName}' not found. Available: ${Array.from(this.scrapers.keys()).join(', ')}`);
    }

    console.log(`Running ${scraperName.toUpperCase()} scraper...`);
    
    try {
      await scraper.scrape();
      console.log(`${scraperName.toUpperCase()} scraper completed successfully`);
      return { success: true, scraper: scraperName };
    } catch (error) {
      console.error(`${scraperName.toUpperCase()} scraper failed:`, error);
      return { success: false, scraper: scraperName, error: error.message };
    }
  }

  /**
   * Run all scrapers
   */
  async runAllScrapers() {
    const results = [];
    
    console.log('Starting full scraping session...');
    
    for (const [name, scraper] of this.scrapers) {
      console.log(`\n--- Starting ${name.toUpperCase()} ---`);
      
      try {
        await scraper.scrape();
        results.push({ scraper: name, success: true });
        console.log(`✅ ${name.toUpperCase()} completed`);
      } catch (error) {
        results.push({ scraper: name, success: false, error: error.message });
        console.log(`❌ ${name.toUpperCase()} failed: ${error.message}`);
      }
      
      // Delay between scrapers to be respectful
      if (name !== Array.from(this.scrapers.keys()).pop()) {
        console.log('Waiting 5 seconds before next scraper...');
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }

    console.log('\n=== Scraping Session Complete ===');
    console.log('Results:');
    results.forEach(result => {
      const status = result.success ? '✅ SUCCESS' : '❌ FAILED';
      console.log(`  ${result.scraper.toUpperCase()}: ${status}`);
      if (!result.success) {
        console.log(`    Error: ${result.error}`);
      }
    });

    return results;
  }

  /**
   * Get scraping statistics
   */
  async getStats() {
    const stats = {};

    // Get counts by data source
    const countResult = await this.pool.query(`
      SELECT 
        data_source,
        COUNT(*) as game_count,
        COUNT(CASE WHEN game_status = 'completed' THEN 1 END) as completed_games,
        COUNT(CASE WHEN game_status = 'scheduled' THEN 1 END) as scheduled_games,
        MAX(scraped_at) as last_scraped
      FROM league_games 
      WHERE data_source IN ('scraped_apsl', 'scraped_casa')
      GROUP BY data_source
      ORDER BY data_source
    `);

    stats.bySource = countResult.rows;

    // Get recent activity
    const recentResult = await this.pool.query(`
      SELECT 
        lg.competition_name,
        ht.name as home_team,
        at.name as away_team,
        lg.home_team_score || '-' || lg.away_team_score as score,
        lg.data_source,
        lg.scraped_at
      FROM league_games lg
      LEFT JOIN teams ht ON lg.home_team_id = ht.id
      LEFT JOIN teams at ON lg.away_team_id = at.id
      WHERE lg.data_source IN ('scraped_apsl', 'scraped_casa')
        AND lg.scraped_at IS NOT NULL
      ORDER BY lg.scraped_at DESC
      LIMIT 10
    `);

    stats.recentGames = recentResult.rows;

    // Get total events and player stats
    const eventsResult = await this.pool.query(`
      SELECT 
        COUNT(lme.id) as total_events,
        COUNT(lmps.id) as total_player_stats
      FROM league_games lg
      LEFT JOIN league_match_events lme ON lg.id = lme.league_game_id
      LEFT JOIN league_match_player_stats lmps ON lg.id = lmps.league_game_id
      WHERE lg.data_source IN ('scraped_apsl', 'scraped_casa')
    `);

    stats.totals = eventsResult.rows[0];

    return stats;
  }

  /**
   * Clean up database connection
   */
  async close() {
    await this.pool.end();
  }
}

module.exports = ScraperManager;