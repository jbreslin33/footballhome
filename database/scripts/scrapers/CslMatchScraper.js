const fs = require('fs');
const path = require('path');
const MatchRepository = require('../domain/repositories/MatchRepository');
const CslMatchParser = require('../infrastructure/parsers/CslMatchParser');
const Match = require('../domain/models/Match');

/**
 * Cosmopolitan Soccer League Match Scraper
 * 
 * Scrapes match schedules from cached CSL team HTML files.
 * Follows same pattern as ApslMatchScraper:
 * - Uses cached HTML files from team pages
 * - Repository pattern for database operations
 * - Parser for HTML parsing logic
 */
class CslMatchScraper {
  constructor(client, matchRepo, parser) {
    this.client = client;
    this.matchRepo = matchRepo || new MatchRepository(client);
    this.parser = parser || new CslMatchParser();
    this.cacheDir = path.join(__dirname, '../../scraped-html/csl');
  }
  
  async run() {
    console.log(`\n⚽ CSL Match Scraper`);
    console.log('='.repeat(60));
    
    try {
      // Get all CSL teams with external_ids
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
          
          // Look up opponent team by external_id
          let homeTeamId = matchData.homeTeamId;
          let awayTeamId = matchData.awayTeamId;
          
          // If homeTeamId is not the current team, look it up by external_id
          if (homeTeamId !== team.team_id) {
            const opponentResult = await this.client.query(
              'SELECT id FROM teams WHERE source_system_id = 8 AND external_id = $1',
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
              'SELECT id FROM teams WHERE source_system_id = 8 AND external_id = $1',
              [awayTeamId.toString()]
            );
            if (opponentResult.rows.length > 0) {
              awayTeamId = opponentResult.rows[0].id;
            } else {
              console.log(`     ⚠️  Skipping match - opponent team ${awayTeamId} not found in database`);
              continue;
            }
          }
          
          // Skip if we still don't have both teams
          if (!homeTeamId || !awayTeamId) {
            continue;
          }
          
          // Generate a deterministic external_id for deduplication
          const [team1, team2] = [homeTeamId, awayTeamId].sort((a, b) => a - b);
          const generatedExternalId = `csl-${matchData.matchDate}-${team1}-${team2}`;
          
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
            venueId: null,
            sourceSystemId: 3,
            externalId: externalId
          });
          
          // Check if match exists
          const existing = await this.matchRepo.findByExternalId(3, externalId);
          
          if (existing) {
            // Update if scores changed
            if (existing.home_score !== match.homeScore || existing.away_score !== match.awayScore) {
              await this.matchRepo.update(existing.id, match);
              totalUpdated++;
            }
          } else {
            await this.matchRepo.create(match);
            totalNew++;
          }
          
          totalMatches++;
        }
      }
      
      console.log(`\n📊 Summary:`);
      console.log(`   Total matches: ${totalMatches}`);
      console.log(`   New: ${totalNew}`);
      console.log(`   Updated: ${totalUpdated}`);
      console.log(`\n✅ Match scraping completed`);
      
    } catch (error) {
      console.error('❌ Error:', error.message);
      throw error;
    }
  }
  
  /**
   * Get all CSL teams with their team_id and external_id
   */
  async getTeams() {
    const result = await this.client.query(`
      SELECT DISTINCT ON (t.id)
        t.id as team_id,
        t.external_id,
        t.name
      FROM teams t
      WHERE t.source_system_id = 8 
        AND t.external_id IS NOT NULL
      ORDER BY t.id
    `);
    
    return result.rows;
  }
  
  /**
   * Find the HTML file for a team by external_id
   */
  findTeamHtmlFile(externalId) {
    const files = fs.readdirSync(this.cacheDir);
    const pattern = new RegExp(`^${externalId}-[a-f0-9]+\\.html$`);
    
    const match = files.find(file => pattern.test(file));
    return match ? path.join(this.cacheDir, match) : null;
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
    await scraper.run();
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
