const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');
const CslRosterParser = require('../infrastructure/parsers/CslRosterParser');
const DivisionTeamRepository = require('../domain/repositories/DivisionTeamRepository');
const DivisionTeamPlayerRepository = require('../domain/repositories/DivisionTeamPlayerRepository');
const PersonRepository = require('../domain/repositories/PersonRepository');

/**
 * Cosmopolitan Soccer League Roster Scraper
 * 
 * Extracts player rosters for each team from CSL team pages
 */
class CslRosterScraper {
  constructor(client) {
    this.client = client;
    this.fetcher = new HtmlFetcher('database/scraped-html/csl');
    this.parser = new CslRosterParser();
    this.divisionTeamRepo = new DivisionTeamRepository(client);
    this.divisionTeamPlayerRepo = new DivisionTeamPlayerRepository(client);
    this.personRepo = new PersonRepository(client);
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
      SELECT 
        st.id as scraped_team_id,
        st.name as team_name,
        st.external_id,
        dt.id as division_team_id
      FROM scraped_teams st
      JOIN division_teams dt ON st.id = dt.scraped_team_id
      JOIN divisions d ON dt.division_id = d.id
      JOIN conferences c ON d.conference_id = c.id
      JOIN seasons s ON c.season_id = s.id
      JOIN leagues l ON s.league_id = l.id
      WHERE l.slug = 'cosmopolitan-soccer-league'
        AND st.is_active = true
      ORDER BY st.name
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
    
    // Fetch roster HTML
    const url = `https://www.cosmosoccerleague.com/CSL/Team/${team.external_id}`;
    const filename = `csl-roster-${team.external_id}`;
    
    let html;
    try {
      html = await this.fetcher.fetch(url, filename);
    } catch (error) {
      console.log(`   ⚠️  Could not fetch roster: ${error.message}`);
      return;
    }
    
    // Parse players
    const players = this.parser.parse(html);
    console.log(`   👥 Found ${players.length} players`);
    
    // Add players to database
    for (const playerData of players) {
      await this.addPlayer(team.division_team_id, playerData);
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
    
    // Find or create person
    let person = await this.personRepo.findByName(firstName, lastName);
    
    if (!person) {
      person = await this.personRepo.create({
        firstName,
        lastName,
        isActive: true
      });
    }
    
    // Link to division team
    const existing = await this.divisionTeamPlayerRepo.findByDivisionTeamAndPerson(
      divisionTeamId,
      person.id
    );
    
    if (!existing) {
      await this.divisionTeamPlayerRepo.create({
        divisionTeamId,
        personId: person.id,
        jerseyNumber: playerData.number
      });
    }
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
