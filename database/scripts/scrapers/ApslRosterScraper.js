const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const PersonRepository = require('../domain/repositories/PersonRepository');
const PlayerRepository = require('../domain/repositories/PlayerRepository');
const DivisionTeamPlayerRepository = require('../domain/repositories/DivisionTeamPlayerRepository');

/**
 * APSL Roster Scraper
 * 
 * Scrapes player rosters from cached APSL team HTML files.
 * Populates: persons → players → division_team_players
 */
class ApslRosterScraper {
  constructor(client, personRepo, playerRepo, rosterRepo) {
    this.client = client;
    this.personRepo = personRepo;
    this.playerRepo = playerRepo;
    this.rosterRepo = rosterRepo;
    this.cacheDir = path.join(__dirname, '../../scraped-html/apsl');
  }
  
  async run() {
    console.log(`\n⚽ APSL Roster Scraper`);
    console.log('='.repeat(60));
    
    try {
      // Get all teams with external_ids
      const teams = await this.getTeams();
      console.log(`📋 Found ${teams.length} teams to process\n`);
      
      let totalPlayers = 0;
      let totalRosters = 0;
      
      for (const team of teams) {
        const htmlFile = this.findTeamHtmlFile(team.external_id);
        
        if (!htmlFile) {
          console.log(`   ⚠️  No HTML file for team ${team.name} (external_id: ${team.external_id})`);
          continue;
        }
        
        const html = fs.readFileSync(htmlFile, 'utf-8');
        const roster = this.parseRoster(html);
        
        if (roster.length === 0) {
          console.log(`   ⚠️  No roster found for ${team.name}`);
          continue;
        }
        
        console.log(`   ${team.name}: ${roster.length} players`);
        
        for (const playerData of roster) {
          // 1. Create/find person
          const personResult = await this.personRepo.upsert({
            firstName: playerData.firstName,
            lastName: playerData.lastName
          });
          
          // 2. Create/find player
          // NOTE: APSL does not provide unique player IDs, so we leave external_id as NULL
          const playerResult = await this.playerRepo.upsert({
            personId: personResult.id,
            photoUrl: playerData.photoUrl,
            sourceSystemId: 1, // APSL
            externalId: null  // APSL doesn't provide player IDs
          });
          
          // 3. Create roster entry (division_team_players)
          await this.rosterRepo.upsert(team.division_team_id, playerResult.id, {
            jerseyNumber: playerData.jerseyNumber,
            isActive: true
          });
          
          totalPlayers++;
          totalRosters++;
        }
      }
      
      console.log(`\n✅ Scrape completed`);
      console.log(`   Players: ${totalPlayers}`);
      console.log(`   Roster entries: ${totalRosters}\n`);
      
    } catch (error) {
      console.error(`\n❌ Scraper error: ${error.message}`);
      throw error;
    }
  }
  
  /**
   * Get all teams from database
   */
  async getTeams() {
    const result = await this.client.query(`
      SELECT 
        t.id as team_id,
        t.name,
        t.external_id,
        dt.id as division_team_id
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
   */
  findTeamHtmlFile(externalId) {
    const files = fs.readdirSync(this.cacheDir);
    const pattern = new RegExp(`^apsl-team-${externalId}-[a-f0-9]+\\.html$`);
    const match = files.find(f => pattern.test(f));
    return match ? path.join(this.cacheDir, match) : null;
  }
  
  /**
   * Parse roster from HTML
   */
  parseRoster(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    const roster = [];
    
    // Find the roster table
    const tables = document.querySelectorAll('table');
    let rosterTable = null;
    
    for (const table of tables) {
      if (table.textContent.includes('added:')) {
        rosterTable = table;
        break;
      }
    }
    
    if (!rosterTable) return roster;
    
    // Parse rows
    const rows = rosterTable.querySelectorAll('tr');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 2) continue;
      if (!row.textContent.includes('added:')) continue;
      
      // Cell 0: Photo
      const photoImg = cells[0]?.querySelector('img');
      let photoUrl = null;
      if (photoImg) {
        const src = photoImg.getAttribute('src');
        if (src && src.includes('/mediacontent/')) {
          photoUrl = src.startsWith('http') ? src : 'https://app.teampass.com' + src;
        }
      }
      
      // Cell 1: Player name
      const nameDiv = cells[1]?.querySelector('div[style*="font-size:12px"]');
      const fullName = nameDiv?.textContent.trim();
      
      // Cell 2: Jersey number
      const jerseyNum = cells[2]?.textContent.trim() || null;
      
      if (!fullName || fullName.toLowerCase() === 'player') continue;
      
      // Split name
      const { firstName, lastName } = this.splitName(fullName);
      
      roster.push({
        firstName,
        lastName,
        jerseyNumber: jerseyNum,
        photoUrl
      });
    }
    
    return roster;
  }
  
  /**
   * Split player name into first/last
   */
  splitName(fullName) {
    const parts = fullName.trim().split(/\s+/);
    if (parts.length === 1) {
      return { firstName: parts[0], lastName: parts[0] };
    }
    const lastName = parts.pop();
    const firstName = parts.join(' ');
    return { firstName, lastName };
  }
}

/**
 * Main entry point
 */
async function main() {
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
    
    const personRepo = new PersonRepository(client);
    const playerRepo = new PlayerRepository(client);
    const rosterRepo = new DivisionTeamPlayerRepository(client);
    
    const scraper = new ApslRosterScraper(client, personRepo, playerRepo, rosterRepo);
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

module.exports = ApslRosterScraper;
