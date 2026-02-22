const path = require('path');
const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');
const CslMatchEventParser = require('../infrastructure/parsers/CslMatchEventParser');
const MatchRepository = require('../domain/repositories/MatchRepository');
const MatchEventRepository = require('../domain/repositories/MatchEventRepository');

/**
 * Cosmopolitan Soccer League Match Event Scraper
 * 
 * Extracts player-level statistics from CSL match pages:
 * - Goals per player
 * - Assists per player
 * 
 * Format: Separate tables for home/away teams with aggregated stats
 */
class CslMatchEventScraper {
  constructor(client) {
    this.client = client;
    this.fetcher = new HtmlFetcher(path.join(__dirname, '../../scraped-html/csl'));
    this.parser = new CslMatchEventParser();
    this.matchRepo = new MatchRepository(client);
    this.matchEventRepo = new MatchEventRepository(client);
    
    // Event type cache
    this.eventTypeCache = {};
  }
  
  /**
   * Main scraping logic - now separated into phases
   */
  async scrape() {
    console.log('\n⚽ CSL Match Event Scraper');
    console.log('============================================================');
    
    try {
      // Load event types
      await this.loadEventTypes();
      
      // Get all completed CSL matches
      const matches = await this.getCompletedMatches();
      console.log(`⚽ Found ${matches.length} completed matches to process\n`);
      
      // PHASE 1: Download all HTML files (batch)
      console.log('📥 Phase 1: Downloading HTML files...');
      await this.downloadAllHtml(matches);
      
      // PHASE 2: Parse all cached HTML files and write to database
      console.log('\n📝 Phase 2: Parsing and saving match events...');
      const stats = await this.parseAndSaveAll(matches);
      
      console.log('\n✅ Scrape completed');
      console.log(`   Matches processed: ${stats.processed}`);
      console.log(`   Total events: ${stats.totalEvents}`);
      console.log(`   Skipped: ${stats.skipped}`);
      
    } catch (error) {
      console.error('❌ Error:', error.message);
      throw error;
    }
  }
  
  /**
   * PHASE 1: Download all HTML files for matches
   * Uses caching to skip already-downloaded files
   */
  async downloadAllHtml(matches) {
    let downloaded = 0;
    let cached = 0;
    let failed = 0;
    
    for (const match of matches) {
      const url = `https://www.cosmosoccerleague.com/CSL/Event/${match.external_id}`;
      
      try {
        // Fetch will use cache if available (useCache=true)
        const result = await this.fetcher.fetch(url, true);
        if (result && result.length > 0) {
          cached++;
        }
      } catch (error) {
        console.log(`   ⚠️  Failed to download match ${match.id}: ${error.message}`);
        failed++;
      }
    }
    
    console.log(`   Downloaded/Verified: ${matches.length} files`);
    console.log(`   Failed: ${failed}`);
  }
  
  /**
   * PHASE 2: Parse all cached HTML files and save to database
   */
  async parseAndSaveAll(matches) {
    let processed = 0;
    let skipped = 0;
    let totalEvents = 0;
    
    for (const match of matches) {
      const result = await this.processMatch(match);
      if (result.success) {
        processed++;
        totalEvents += result.eventCount;
      } else {
        skipped++;
      }
    }
    
    return { processed, skipped, totalEvents };
  }
  
  /**
   * Load event types from database
   */
  async loadEventTypes() {
    const result = await this.client.query('SELECT id, name FROM match_event_types');
    for (const row of result.rows) {
      this.eventTypeCache[row.name] = row.id;
    }
  }
  
  /**
   * Get all completed CSL matches that need event scraping
   */
  async getCompletedMatches() {
    const result = await this.client.query(`
      SELECT 
        m.id,
        m.external_id,
        m.home_team_id,
        m.away_team_id,
        m.home_score,
        m.away_score,
        ht.name as home_team_name,
        at.name as away_team_name
      FROM matches m
      JOIN teams ht ON m.home_team_id = ht.id
      JOIN teams at ON m.away_team_id = at.id
      WHERE m.source_system_id = 3  -- CSL source system
        AND m.home_score IS NOT NULL
        AND m.away_score IS NOT NULL
      ORDER BY m.match_date
    `);
    
    return result.rows;
  }
  
  /**
   * Process a single match - reads from cached HTML file
   */
  async processMatch(match) {
    // Find cached HTML file
    const htmlFile = this.findEventHtmlFile(match.external_id);
    
    if (!htmlFile) {
      return { success: false, eventCount: 0 };
    }
    
    // Read from cache
    const fs = require('fs');
    const html = fs.readFileSync(htmlFile, 'utf-8');
    
    // Validate HTML
    if (!html || html.trim().length === 0) {
      return { success: false, eventCount: 0 };
    }
    
    // Parse player stats
    const stats = this.parser.parse(html, match.home_team_name, match.away_team_name);
    
    let totalGoals = 0;
    let totalAssists = 0;
    
    // Process home team stats
    for (const playerStat of stats.homeTeam) {
      await this.recordPlayerEvents(match.id, match.home_team_id, playerStat);
      totalGoals += playerStat.goals;
      totalAssists += playerStat.assists;
    }
    
    // Process away team stats
    for (const playerStat of stats.awayTeam) {
      await this.recordPlayerEvents(match.id, match.away_team_id, playerStat);
      totalGoals += playerStat.goals;
      totalAssists += playerStat.assists;
    }
    
    return { success: true, eventCount: totalGoals + totalAssists };
  }
  
  /**
   * Find HTML file for match event using HtmlFetcher's cache naming convention
   */
  findEventHtmlFile(externalId) {
    const fs = require('fs');
    const path = require('path');
    const crypto = require('crypto');
    
    try {
      // Replicate HtmlFetcher.getCacheFilename() logic:
      // URL: https://www.cosmosoccerleague.com/CSL/Event/{externalId}
      // Last path segment = externalId, lowercased, non-alphanumeric replaced with '-'
      // Then append '-' + MD5(url).substring(0,8) + '.html'
      const url = `https://www.cosmosoccerleague.com/CSL/Event/${externalId}`;
      const hash = crypto.createHash('md5').update(url).digest('hex').substring(0, 8);
      const baseName = externalId.toLowerCase().replace(/[^a-z0-9]/g, '-');
      const expectedFilename = `${baseName}-${hash}.html`;
      
      const fullPath = path.join(this.fetcher.cacheDir, expectedFilename);
      if (fs.existsSync(fullPath)) {
        return fullPath;
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }
  
  /**
   * Record player events (goals and assists)
   */
  async recordPlayerEvents(matchId, teamId, playerStat) {
    // Find player
    const player = await this.findPlayerByName(playerStat.playerName, teamId);
    if (!player) {
      console.log(`   ⚠️  Player not found: "${playerStat.playerName}" for team ${teamId}`);
      return;
    }
    
    // Record goals
    for (let i = 0; i < playerStat.goals; i++) {
      await this.matchEventRepo.create({
        matchId,
        playerId: player.id,
        teamId,
        eventTypeId: this.eventTypeCache['goal'],
        minute: 0, // CSL doesn't provide minute-by-minute data (0 = unknown)
        assistedByPlayerId: null
      });
    }
    
    // Note: Assists are tracked but not recorded as separate events
    // They're metadata that would link to goals if we had that detail
  }
  
  /**
   * Find player by name in team roster (with fuzzy fallback)
   */
  async findPlayerByName(playerName, teamId) {
    // Parse name (format: "Last, First" or "First Last")
    let firstName = '';
    let lastName = '';
    
    if (playerName.includes(',')) {
      const parts = playerName.split(',');
      lastName = parts[0].trim();
      firstName = parts[1] ? parts[1].trim() : '';
    } else {
      const spaceParts = playerName.split(' ');
      if (spaceParts.length >= 2) {
        firstName = spaceParts[0];
        lastName = spaceParts.slice(1).join(' ');
      } else {
        lastName = playerName;
      }
    }
    
    // First try: Find player in team's roster
    let result = await this.client.query(`
      SELECT DISTINCT p.id, per.first_name, per.last_name
      FROM players p
      JOIN persons per ON p.person_id = per.id
      JOIN rosters r ON p.id = r.player_id
      WHERE r.team_id = $1
        AND (r.left_at IS NULL OR r.left_at > NOW())
        AND (
          (per.last_name ILIKE $2 AND per.first_name ILIKE $3)
          OR (per.last_name ILIKE $2)
        )
      LIMIT 1
    `, [teamId, lastName, firstName]);
    
    if (result.rows[0]) {
      return result.rows[0];
    }
    
    // Second try: Fuzzy match any CSL player by last name (player ID range 20000-30000)
    result = await this.client.query(`
      SELECT DISTINCT p.id, per.first_name, per.last_name
      FROM players p
      JOIN persons per ON p.person_id = per.id
      WHERE p.id BETWEEN 20000 AND 30000
        AND per.last_name ILIKE $1
        AND (per.first_name ILIKE $2 OR $2 = '')
      LIMIT 1
    `, [lastName, firstName]);
    
    return result.rows[0] || null;
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
    const scraper = new CslMatchEventScraper(client);
    await scraper.scrape();
    console.log('CslMatchEventScraper completed successfully');
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

module.exports = CslMatchEventScraper;
