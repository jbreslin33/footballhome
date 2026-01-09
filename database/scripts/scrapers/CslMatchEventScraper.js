const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');
const CslMatchEventParser = require('../infrastructure/parsers/CslMatchEventParser');
const MatchRepository = require('../domain/repositories/MatchRepository');
const MatchEventRepository = require('../domain/repositories/MatchEventRepository');
const DivisionTeamPlayerRepository = require('../domain/repositories/DivisionTeamPlayerRepository');

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
    this.fetcher = new HtmlFetcher('database/scraped-html/csl');
    this.parser = new CslMatchEventParser();
    this.matchRepo = new MatchRepository(client);
    this.matchEventRepo = new MatchEventRepository(client);
    this.divisionTeamPlayerRepo = new DivisionTeamPlayerRepository(client);
    
    // Event type cache
    this.eventTypeCache = {};
  }
  
  /**
   * Main scraping logic
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
      
      for (const match of matches) {
        await this.processMatch(match);
      }
      
      console.log('\n✅ Scrape completed');
      console.log(`   Matches processed: ${matches.length}`);
      
    } catch (error) {
      console.error('❌ Error:', error.message);
      throw error;
    }
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
      WHERE m.source_system_id = 8  -- CSL source system
        AND m.home_score IS NOT NULL
        AND m.away_score IS NOT NULL
      ORDER BY m.match_date
    `);
    
    return result.rows;
  }
  
  /**
   * Process a single match
   */
  async processMatch(match) {
    console.log(`\n   📋 Match ${match.id}: ${match.home_team_name} ${match.home_score}-${match.away_score} ${match.away_team_name}`);
    
    // Fetch HTML
    const url = `https://www.cosmosoccerleague.com/CSL/Event/${match.external_id}`;
    const filename = `csl-event-${match.external_id}`;
    
    let html;
    try {
      html = await this.fetcher.fetch(url, filename);
    } catch (error) {
      console.log(`   ⚠️  Could not fetch HTML: ${error.message}`);
      return;
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
    
    console.log(`   ⚽ ${totalGoals} goals, ${totalAssists} assists recorded`);
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
   * Find player by name in team roster
   */
  async findPlayerByName(playerName, teamId) {
    // Try exact match first
    const result = await this.client.query(`
      SELECT DISTINCT p.id, p.first_name, p.last_name
      FROM persons p
      JOIN players pl ON p.id = pl.person_id
      JOIN division_team_players dtp ON pl.id = dtp.player_id
      JOIN division_teams dt ON dtp.division_team_id = dt.id
      WHERE dt.team_id = $1
        AND CONCAT(p.last_name, ', ', p.first_name) = $2
    `, [teamId, playerName]);
    
    if (result.rows.length > 0) {
      return result.rows[0];
    }
    
    // Try fuzzy match (last name match)
    const lastName = playerName.split(',')[0].trim();
    const fuzzyResult = await this.client.query(`
      SELECT DISTINCT p.id, p.first_name, p.last_name
      FROM persons p
      JOIN players pl ON p.id = pl.person_id
      JOIN division_team_players dtp ON pl.id = dtp.player_id
      JOIN division_teams dt ON dtp.division_team_id = dt.id
      WHERE dt.team_id = $1
        AND p.last_name = $2
      LIMIT 1
    `, [teamId, lastName]);
    
    return fuzzyResult.rows[0] || null;
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
