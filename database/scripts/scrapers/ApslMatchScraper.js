const fs = require('fs');
const path = require('path');
const MatchRepository = require('../domain/repositories/MatchRepository');
const ApslMatchParser = require('../infrastructure/parsers/ApslMatchParser');
const Match = require('../domain/models/Match');

/**
 * APSL Match Scraper
 * 
 * Scrapes match schedules from cached APSL team HTML files.
 * Populates: matches, match_divisions
 * 
 * Follows the same pattern as ApslRosterScraper:
 * - Uses cached HTML files
 * - Repository pattern for database operations
 * - Parser for HTML parsing logic
 */
class ApslMatchScraper {
  constructor(client, matchRepo, parser) {
    this.client = client;
    this.matchRepo = matchRepo;
    this.parser = parser;
    this.cacheDir = path.join(__dirname, '../../scraped-html/apsl');
  }
  
  async run() {
    console.log(`\n⚽ APSL Match Scraper`);
    console.log('='.repeat(60));
    
    try {
      // Get all teams with external_ids
      const teams = await this.getTeams();
      console.log(`📋 Found ${teams.length} teams to process\n`);
      
      let totalMatches = 0;
      let totalNew = 0;
      let totalUpdated = 0;
      
      for (const team of teams) {
        const htmlFile = this.findTeamHtmlFile(team.external_id);
        
        if (!htmlFile) {
          console.log(`   ⚠️  No HTML file for team ${team.name} (external_id: ${team.external_id})`);
          continue;
        }
        
        const html = fs.readFileSync(htmlFile, 'utf-8');
        const matches = this.parser.parse(html, team.team_id);
        
        if (matches.length === 0) {
          console.log(`   ⚠️  No matches found for ${team.name}`);
          continue;
        }
        
        console.log(`   ${team.name}: ${matches.length} matches`);
        
        for (const matchData of matches) {
          // Skip if missing required data
          if (!matchData.matchDate) {
            continue;
          }
          
          // Look up opponent team by external_id (parser returns external_id, not internal id)
          let homeTeamId = matchData.homeTeamId;
          let awayTeamId = matchData.awayTeamId;
          
          // If homeTeamId is not the current team, look it up by external_id
          if (homeTeamId !== team.team_id) {
            const opponentResult = await this.client.query(
              'SELECT id FROM teams WHERE source_system_id = 1 AND external_id = $1',
              [homeTeamId.toString()]
            );
            if (opponentResult.rows.length > 0) {
              homeTeamId = opponentResult.rows[0].id;
            } else {
              console.log(`     ⚠️  Skipping match - opponent team ${homeTeamId} not found in database`);
              continue;
            }
          }
          
          // If awayTeamId is not the current team, look it up by external_id
          if (awayTeamId !== team.team_id) {
            const opponentResult = await this.client.query(
              'SELECT id FROM teams WHERE source_system_id = 1 AND external_id = $1',
              [awayTeamId.toString()]
            );
            if (opponentResult.rows.length > 0) {
              awayTeamId = opponentResult.rows[0].id;
            } else {
              console.log(`     ⚠️  Skipping match - opponent team ${awayTeamId} not found in database`);
              continue;
            }
          }
          
          // Now skip if we still don't have both teams
          if (!homeTeamId || !awayTeamId) {
            continue;
          }
          
          // Generate a deterministic external_id for deduplication
          // Format: apsl-{date}-{smaller_team_id}-{larger_team_id}
          // This ensures the same match from both teams' pages gets the same ID
          const [team1, team2] = [homeTeamId, awayTeamId].sort((a, b) => a - b);
          const generatedExternalId = `apsl-${matchData.matchDate}-${team1}-${team2}`;
          
          // Prefer the external_id from the HTML if available, otherwise use generated
          const externalId = matchData.externalId || generatedExternalId;
          
          // Create Match domain model
          const match = new Match({
            matchTypeId: 1, // league match
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
            matchDate: matchData.matchDate,
            matchTime: matchData.matchTime,
            title: matchData.description,
            description: matchData.description,
            matchStatusId: matchData.matchStatusId,
            homeScore: matchData.homeScore,
            awayScore: matchData.awayScore,
            sourceSystemId: 1, // APSL
            externalId: externalId
          });
          
          // Upsert match (will find existing by external_id and update, or create new)
          const result = await this.matchRepo.upsert(match);
          
          // Link match to division
          if (team.division_id) {
            await this.matchRepo.linkToDivision(result.id, team.division_id);
          }
          
          totalMatches++;
          if (result.created_at && this.isRecent(result.created_at)) {
            totalNew++;
          } else {
            totalUpdated++;
          }
        }
      }
      
      console.log(`\n✅ Scrape completed`);
      console.log(`   Total matches processed: ${totalMatches}`);
      console.log(`   New: ${totalNew}`);
      console.log(`   Updated: ${totalUpdated}\n`);
      
    } catch (error) {
      console.error(`\n❌ Scraper error: ${error.message}`);
      console.error(error.stack);
      throw error;
    }
  }
  
  /**
   * Get all teams from database with their divisions
   */
  async getTeams() {
    const result = await this.client.query(`
      SELECT 
        t.id as team_id,
        t.name,
        t.external_id,
        dt.id as division_team_id,
        dt.division_id
      FROM teams t
      JOIN division_teams dt ON t.id = dt.team_id
      WHERE t.source_system_id = 1  -- APSL
        AND t.external_id IS NOT NULL
      ORDER BY t.name
    `);
    
    return result.rows;
  }
  
  /**
   * Find HTML file for a team by external_id
   * Pattern: apsl-team-{external_id}-{hash}.html
   */
  findTeamHtmlFile(externalId) {
    const files = fs.readdirSync(this.cacheDir);
    const pattern = new RegExp(`^apsl-team-${externalId}-[a-f0-9]+\\.html$`);
    const match = files.find(f => pattern.test(f));
    return match ? path.join(this.cacheDir, match) : null;
  }
  
  /**
   * Check if a timestamp is recent (within last 5 seconds)
   */
  isRecent(timestamp) {
    const now = new Date();
    const created = new Date(timestamp);
    return (now - created) < 5000;
  }
}

/**
 * Factory function to create scraper with dependencies
 */
async function createApslMatchScraper(client) {
  const matchRepo = new MatchRepository(client);
  const parser = new ApslMatchParser();
  
  return new ApslMatchScraper(client, matchRepo, parser);
}

/**
 * Main entry point
 */
async function main() {
  const { Pool } = require('pg');
  
  const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'footballhome',
    user: 'footballhome_user',
    password: 'footballhome_pass',
  });
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const matchRepo = new MatchRepository(client);
    const parser = new ApslMatchParser();
    
    const scraper = new ApslMatchScraper(client, matchRepo, parser);
    await scraper.run();
    
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = ApslMatchScraper;
module.exports.create = createApslMatchScraper;
