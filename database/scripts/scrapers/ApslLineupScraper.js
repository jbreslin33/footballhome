const fs = require('fs');
const path = require('path');
const MatchLineupRepository = require('../domain/repositories/MatchLineupRepository');
const ApslLineupParser = require('../infrastructure/parsers/ApslLineupParser');

/**
 * APSL Match Lineup Scraper
 * 
 * Scrapes starter and substitute lineups from cached APSL match event HTML files.
 * Populates: match_lineups table
 * 
 * Follows the same pattern as other APSL scrapers:
 * - Uses cached event HTML files (apsl-event-*.html)
 * - Repository pattern for database operations
 * - Parser for HTML parsing logic
 */
class ApslLineupScraper {
  constructor(client, matchLineupRepo, parser) {
    this.client = client;
    this.matchLineupRepo = matchLineupRepo;
    this.parser = parser;
    this.cacheDir = path.join(__dirname, '../../scraped-html/apsl');
  }
  
  async run() {
    console.log(`\n📋 APSL Match Lineup Scraper`);
    console.log('='.repeat(60));
    
    try {
      // Get all completed matches with external IDs
      const matches = await this.getCompletedMatches();
      console.log(`📋 Found ${matches.length} completed matches to process\n`);
      
      let totalLineups = 0;
      let totalStarters = 0;
      let totalSubs = 0;
      let skipped = 0;
      
      for (const match of matches) {
        const htmlFile = this.findEventHtmlFile(match.external_id);
        
        if (!htmlFile) {
          skipped++;
          continue;
        }
        
        const html = fs.readFileSync(htmlFile, 'utf-8');
        const lineups = this.parser.parse(html);
        
        if (lineups.starters.length === 0 && lineups.substitutes.length === 0) {
          skipped++;
          continue;
        }
        
        // Save lineups to database
        await this.saveLineups(match, lineups);
        
        totalLineups++;
        totalStarters += lineups.starters.length;
        totalSubs += lineups.substitutes.length;
      }
      
      console.log(`\n✅ Scrape completed`);
      console.log(`   Matches processed: ${totalLineups}`);
      console.log(`   Starters: ${totalStarters}`);
      console.log(`   Substitutes: ${totalSubs}`);
      console.log(`   Skipped (no HTML/data): ${skipped}`);
      
    } catch (error) {
      console.error(`\n❌ Scraper error: ${error.message}`);
      console.error(error.stack);
      throw error;
    }
  }
  
  /**
   * Get all completed matches (those with scores)
   */
  async getCompletedMatches() {
    const result = await this.client.query(`
      SELECT id, external_id, home_team_id, away_team_id
      FROM matches
      WHERE source_system_id = 1  -- APSL
        AND home_score IS NOT NULL
        AND away_score IS NOT NULL
      ORDER BY match_date DESC
    `);
    
    return result.rows;
  }
  
  /**
   * Find cached event HTML file for a match
   */
  findEventHtmlFile(externalId) {
    const files = fs.readdirSync(this.cacheDir);
    const pattern = new RegExp(`^apsl-event-${externalId}_[a-f0-9-]+\\.html$`);
    
    const matchingFile = files.find(f => pattern.test(f));
    return matchingFile ? path.join(this.cacheDir, matchingFile) : null;
  }
  
  /**
   * Save lineups to database
   */
  async saveLineups(match, lineups) {
    // Clear existing lineups for this match
    await this.matchLineupRepo.deleteByMatch(match.id);
    
    // Get team IDs
    const homeTeamId = match.home_team_id;
    const awayTeamId = match.away_team_id;
    
    // Get team names for matching
    const homeTeam = await this.getTeam(homeTeamId);
    const awayTeam = await this.getTeam(awayTeamId);
    
    // Process starters
    for (const lineup of lineups.starters) {
      await this.saveLineup(match.id, lineup, homeTeam, awayTeam, true);
    }
    
    // Process substitutes
    for (const lineup of lineups.substitutes) {
      await this.saveLineup(match.id, lineup, homeTeam, awayTeam, false);
    }
  }
  
  /**
   * Save a single lineup entry
   */
  async saveLineup(matchId, lineup, homeTeam, awayTeam, isStarter) {
    // Determine which team this player belongs to
    const teamId = this.matchTeamName(lineup.teamName, homeTeam, awayTeam);
    
    if (!teamId) {
      console.log(`   ⚠️  Could not match team: ${lineup.teamName}`);
      return;
    }
    
    // Look up player by name and team
    const player = await this.findPlayerByName(lineup.playerName, teamId);
    
    if (!player) {
      // Player not in roster - might be a guest player or typo
      // Skip for now, could create as needed in future
      return;
    }
    
    // Create lineup entry
    await this.matchLineupRepo.create({
      matchId,
      playerId: player.id,
      teamId,
      isStarter
    });
  }
  
  /**
   * Get team by ID
   */
  async getTeam(teamId) {
    const result = await this.client.query(
      'SELECT id, name FROM teams WHERE id = $1',
      [teamId]
    );
    
    return result.rows[0];
  }
  
  /**
   * Match team name from HTML to home/away team
   */
  matchTeamName(teamNameFromHtml, homeTeam, awayTeam) {
    const normalized = teamNameFromHtml.toLowerCase().trim();
    const homeName = homeTeam.name.toLowerCase().trim();
    const awayName = awayTeam.name.toLowerCase().trim();
    
    // Exact match
    if (normalized === homeName) return homeTeam.id;
    if (normalized === awayName) return awayTeam.id;
    
    // Partial match
    if (normalized.includes(homeName) || homeName.includes(normalized)) {
      return homeTeam.id;
    }
    if (normalized.includes(awayName) || awayName.includes(normalized)) {
      return awayTeam.id;
    }
    
    return null;
  }
  
  /**
   * Find player by name and team
   */
  async findPlayerByName(playerName, teamId) {
    // Split "LastName, FirstName" format
    const parts = playerName.split(',').map(p => p.trim());
    
    let lastName, firstName;
    if (parts.length === 2) {
      lastName = parts[0];
      firstName = parts[1];
    } else {
      // Try to split by space if not comma-separated
      const spaceParts = playerName.split(' ');
      if (spaceParts.length >= 2) {
        firstName = spaceParts[0];
        lastName = spaceParts.slice(1).join(' ');
      } else {
        lastName = playerName;
        firstName = '';
      }
    }
    
    // Look up player in division_team_players via team
    const result = await this.client.query(`
      SELECT DISTINCT p.id, p.person_id, per.first_name, per.last_name
      FROM players p
      JOIN persons per ON p.person_id = per.id
      JOIN division_team_players dtp ON p.id = dtp.player_id
      JOIN division_teams dt ON dtp.division_team_id = dt.id
      WHERE dt.team_id = $1
        AND (
          (per.last_name ILIKE $2 AND per.first_name ILIKE $3)
          OR (per.last_name ILIKE $2)
        )
      LIMIT 1
    `, [teamId, lastName, firstName]);
    
    return result.rows[0];
  }
}

/**
 * Main entry point
 */
async function main() {
  const { Pool } = require('pg');
  
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASSWORD || 'footballhome_pass',
  });
  
  let client;
  try {
    client = await pool.connect();
    
    const matchLineupRepo = new MatchLineupRepository(client);
    const parser = new ApslLineupParser();
    const scraper = new ApslLineupScraper(client, matchLineupRepo, parser);
    
    await scraper.run();
  } catch (error) {
    console.error('Fatal error:', error);
    process.exit(1);
  } finally {
    if (client) client.release();
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = ApslLineupScraper;
