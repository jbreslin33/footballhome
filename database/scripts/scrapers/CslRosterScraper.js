const fs = require('fs');
const path = require('path');
const CslRosterParser = require('../infrastructure/parsers/CslRosterParser');
const DivisionTeamRepository = require('../domain/repositories/DivisionTeamRepository');
const DivisionTeamPlayerRepository = require('../domain/repositories/DivisionTeamPlayerRepository');
const PersonRepository = require('../domain/repositories/PersonRepository');
const PlayerRepository = require('../domain/repositories/PlayerRepository');

/**
 * Cosmopolitan Soccer League Roster Scraper
 * 
 * Extracts player rosters for each team from cached CSL team HTML pages
 * Mirrors APSL roster scraper pattern for consistency
 */
class CslRosterScraper {
  constructor(client) {
    this.client = client;
    this.cacheDir = path.join(__dirname, '../../scraped-html/csl');
    this.parser = new CslRosterParser();
    this.divisionTeamRepo = new DivisionTeamRepository(client);
    this.divisionTeamPlayerRepo = new DivisionTeamPlayerRepository(client);
    this.personRepo = new PersonRepository(client);
    this.playerRepo = new PlayerRepository(client);
  }
  
  /**
   * Main scraping logic
   */
  async scrape() {
    console.log('\n⚽ CSL Roster Scraper');
    console.log('============================================================');
    
    try {
      // Get all CSL teams
      const teams = await this.getCslTeams();
      console.log(`📋 Found ${teams.length} CSL teams\n`);
      
      for (const team of teams) {
        await this.processTeamRoster(team);
      }
      
      console.log('\n✅ Roster scraping completed');
      
    } catch (error) {
      console.error('❌ Error:', error.message);
      throw error;
    }
  }
  
  /**
   * Get all CSL teams that need roster scraping
   */
  async getCslTeams() {
    const result = await this.client.query(`
      SELECT DISTINCT ON (t.id)
        t.id as team_id,
        t.name as team_name,
        t.external_id,
        dt.id as division_team_id
      FROM teams t
      JOIN division_teams dt ON t.id = dt.team_id
      JOIN divisions d ON dt.division_id = d.id
      JOIN conferences c ON d.conference_id = c.id
      JOIN seasons s ON c.season_id = s.id
      JOIN leagues l ON s.league_id = l.id
      WHERE l.name = 'Cosmopolitan Soccer League'
        AND dt.is_active = true
      ORDER BY t.id, t.name
    `);
    
    return result.rows;
  }
  
  /**
   * Process roster for a single team
   */
  async processTeamRoster(team) {
    console.log(`\n   📋 ${team.team_name}`);
    
    if (!team.external_id) {
      console.log(`   ⚠️  No external ID - skipping`);
      return;
    }
    
    // Find cached HTML file (like APSL pattern)
    const htmlFile = this.findTeamHtmlFile(team.external_id);
    
    if (!htmlFile) {
      console.log(`   ⚠️  No HTML file found for external_id: ${team.external_id}`);
      return;
    }
    
    // Read HTML from cache
    const html = fs.readFileSync(htmlFile, 'utf-8');
    
    // Parse players
    const players = this.parser.parse(html);
    console.log(`   👥 Found ${players.length} players`);
    
    // Add players to database
    for (const playerData of players) {
      await this.addPlayer(team.division_team_id, playerData);
    }
  }
  
  /**
   * Find HTML file for team (mirrors APSL pattern)
   */
  findTeamHtmlFile(externalId) {
    try {
      const files = fs.readdirSync(this.cacheDir);
      // Look for files starting with external_id followed by dash
      const pattern = new RegExp(`^${externalId}-[a-f0-9]+\\.html$`);
      const match = files.find(f => pattern.test(f));
      return match ? path.join(this.cacheDir, match) : null;
    } catch (error) {
      return null;
    }
  }
  
  /**
   * Add player to database
   */
  async addPlayer(divisionTeamId, playerData) {
    // Parse name (format: "LastName, FirstName")
    const parts = playerData.name.split(',').map(p => p.trim());
    const lastName = parts[0] || '';
    const firstName = parts[1] || '';
    
    if (!lastName) {
      console.log(`   ⚠️  Invalid player name: "${playerData.name}"`);
      return;
    }
    
    // Step 1: Find or create person using upsert
    const personResult = await this.personRepo.upsert({
      firstName,
      lastName,
      isActive: true
    });
    
    // Step 2: Find or create player linked to person
    const playerResult = await this.playerRepo.upsert({
      personId: personResult.id
    });
    
    // Step 3: Link player to division team (roster entry)
    await this.divisionTeamPlayerRepo.upsert(divisionTeamId, playerResult.id, {
      jerseyNumber: playerData.number,
      isActive: true
    });
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
    const scraper = new CslRosterScraper(client);
    await scraper.scrape();
    console.log('CslRosterScraper completed successfully');
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

module.exports = CslRosterScraper;
