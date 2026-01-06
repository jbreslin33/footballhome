const fs = require('fs');
const path = require('path');
const MatchEventRepository = require('../domain/repositories/MatchEventRepository');
const ApslMatchEventParser = require('../infrastructure/parsers/ApslMatchEventParser');

/**
 * APSL Match Event Scraper
 * 
 * Scrapes match events (goals, assists, cards, substitutions) from cached APSL match event HTML files.
 * Populates: match_events table
 * 
 * Follows the same pattern as other APSL scrapers:
 * - Uses cached event HTML files (apsl-event-*.html)
 * - Repository pattern for database operations
 * - Parser for HTML parsing logic
 */
class ApslMatchEventScraper {
  constructor(client, matchEventRepo, parser) {
    this.client = client;
    this.matchEventRepo = matchEventRepo;
    this.parser = parser;
    this.cacheDir = path.join(__dirname, '../../scraped-html/apsl');
    this.eventTypeCache = null; // Cache event type lookups
  }
  
  async run() {
    console.log(`\n⚽ APSL Match Event Scraper`);
    console.log('='.repeat(60));
    
    try {
      // Cache event types for lookups
      await this.cacheEventTypes();
      
      // Get all completed matches with external IDs
      const matches = await this.getCompletedMatches();
      console.log(`⚽ Found ${matches.length} completed matches to process\n`);
      
      let totalMatches = 0;
      let totalEvents = 0;
      let skipped = 0;
      const eventCounts = {};
      
      for (const match of matches) {
        const htmlFile = this.findEventHtmlFile(match.external_id);
        
        if (!htmlFile) {
          skipped++;
          continue;
        }
        
        const html = fs.readFileSync(htmlFile, 'utf-8');
        
        // Get team names for parser
        const homeTeam = await this.getTeam(match.home_team_id);
        const awayTeam = await this.getTeam(match.away_team_id);
        
        const events = this.parser.parse(html, homeTeam.name, awayTeam.name);
        
        if (events.length === 0) {
          skipped++;
          continue;
        }
        
        // Save events to database
        const savedCount = await this.saveEvents(match, events, homeTeam, awayTeam);
        
        if (savedCount > 0) {
          totalMatches++;
          totalEvents += savedCount;
          
          // Count by event type
          for (const event of events) {
            eventCounts[event.eventType] = (eventCounts[event.eventType] || 0) + 1;
          }
        }
      }
      
      console.log(`\n✅ Scrape completed`);
      console.log(`   Matches processed: ${totalMatches}`);
      console.log(`   Total events: ${totalEvents}`);
      console.log(`   Skipped (no HTML/data): ${skipped}`);
      
      if (Object.keys(eventCounts).length > 0) {
        console.log(`\n   Event breakdown:`);
        for (const [eventType, count] of Object.entries(eventCounts).sort((a, b) => b[1] - a[1])) {
          console.log(`     ${eventType}: ${count}`);
        }
      }
      
    } catch (error) {
      console.error(`\n❌ Scraper error: ${error.message}`);
      console.error(error.stack);
      throw error;
    }
  }
  
  /**
   * Cache event types for quick lookups
   */
  async cacheEventTypes() {
    const types = await this.matchEventRepo.getAllEventTypes();
    this.eventTypeCache = {};
    
    for (const type of types) {
      this.eventTypeCache[type.name] = type.id;
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
   * Save events to database
   */
  async saveEvents(match, events, homeTeam, awayTeam) {
    // Clear existing events for this match
    await this.matchEventRepo.deleteByMatch(match.id);
    
    let savedCount = 0;
    
    for (const event of events) {
      const saved = await this.saveEvent(match.id, event, homeTeam, awayTeam);
      if (saved) {
        savedCount++;
      }
    }
    
    return savedCount;
  }
  
  /**
   * Save a single event entry
   */
  async saveEvent(matchId, event, homeTeam, awayTeam) {
    // Determine which team this event belongs to
    const teamId = this.matchTeamName(event.teamName, homeTeam, awayTeam);
    
    if (!teamId) {
      console.log(`   ⚠️  Could not match team: ${event.teamName}`);
      return false;
    }
    
    // Look up player by name and team
    const player = await this.findPlayerByName(event.playerName, teamId);
    
    if (!player) {
      // Player not in roster - might be a guest player or typo
      // Skip for now, could create as needed in future
      return false;
    }
    
    // Get event type ID
    const eventTypeId = this.eventTypeCache[event.eventType];
    
    if (!eventTypeId) {
      console.log(`   ⚠️  Unknown event type: ${event.eventType}`);
      return false;
    }
    
    // Handle assisted_by if present
    let assistedByPlayerId = null;
    if (event.assistedByPlayerName) {
      const assistPlayer = await this.findPlayerByName(event.assistedByPlayerName, teamId);
      if (assistPlayer) {
        assistedByPlayerId = assistPlayer.id;
      }
    }
    
    // Create event entry
    await this.matchEventRepo.create({
      matchId,
      playerId: player.id,
      teamId,
      eventTypeId,
      minute: event.minute,
      assistedByPlayerId
    });
    
    return true;
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
      // Try to split by space if no comma
      const spaceParts = playerName.split(' ');
      if (spaceParts.length >= 2) {
        firstName = spaceParts[0];
        lastName = spaceParts.slice(1).join(' ');
      } else {
        lastName = playerName;
        firstName = '';
      }
    }
    
    // Query for player on this team with matching name
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
    
    return result.rows[0] || null;
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
    
    const matchEventRepo = new MatchEventRepository(client);
    const parser = new ApslMatchEventParser();
    const scraper = new ApslMatchEventScraper(client, matchEventRepo, parser);
    
    await scraper.run();
  } catch (error) {
    console.error('Fatal error:', error);
    process.exit(1);
  } finally {
    if (client) {
      client.release();
    }
    await pool.end();
  }
}

// Self-executing script when run directly
if (require.main === module) {
  main();
}

module.exports = ApslMatchEventScraper;
