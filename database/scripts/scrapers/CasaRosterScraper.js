const https = require('https');
const { parse } = require('csv-parse/sync');
const DivisionTeamRepository = require('../domain/repositories/DivisionTeamRepository');
const DivisionTeamPlayerRepository = require('../domain/repositories/DivisionTeamPlayerRepository');
const PersonRepository = require('../domain/repositories/PersonRepository');
const PlayerRepository = require('../domain/repositories/PlayerRepository');
const { Pool } = require('pg');

/**
 * CASA Roster Scraper - Google Sheets CSV Parser
 * 
 * Fetches and parses CASA rosters from Google Sheets CSV exports
 * Roster URLs from Captain's Corner: https://www.casasoccerleagues.com/captainscorner
 */
class CasaRosterScraper {
  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'footballhome',
      user: process.env.DB_USER || 'footballhome_user',
      password: process.env.DB_PASSWORD || 'footballhome_pass'
    });
  }
  
  /**
   * Main scraping logic
   */
  async scrape() {
    console.log('\n⚽ CASA Roster Scraper (Google Sheets)');
    console.log('============================================================');
    
    const client = await this.pool.connect();
    
    try {
      this.divisionTeamRepo = new DivisionTeamRepository(client);
      this.divisionTeamPlayerRepo = new DivisionTeamPlayerRepository(client);
      this.personRepo = new PersonRepository(client);
      this.playerRepo = new PlayerRepository(client);
      
      // Get all CASA roster scrape targets (type = 4 = team_roster, scraper_type = 2 = google_sheets)
      const targets = await this.getRosterTargets(client);
      console.log(`📋 Found ${targets.length} CASA roster target(s)\n`);
      
      let totalPlayers = 0;
      
      for (const target of targets) {
        const playersAdded = await this.processRosterTarget(client, target);
        totalPlayers += playersAdded;
      }
      
      console.log(`\n✅ Roster scraping completed - ${totalPlayers} total players processed`);
      
    } catch (error) {
      console.error('❌ Error:', error.message);
      console.error(error.stack);
      throw error;
    } finally {
      client.release();
      await this.pool.end();
    }
  }
  
  /**
   * Get all CASA roster scrape targets
   */
  async getRosterTargets(client) {
    const result = await client.query(`
      SELECT 
        st.id,
        st.url,
        st.label,
        st.source_system_id
      FROM scrape_targets st
      WHERE st.source_system_id = 2  -- CASA
        AND st.target_type_id = 4      -- team_roster
        AND st.scraper_type_id = 2     -- google_sheets
        AND st.scrape_action_id IN (1, 4)  -- download_and_parse or force_refresh
      ORDER BY st.id
    `);
    
    return result.rows;
  }
  
  /**
   * Process a single roster target (one Google Sheet = one division's rosters)
   */
  async processRosterTarget(client, target) {
    console.log(`\n📄 ${target.label}`);
    console.log(`   URL: ${target.url}`);
    
    try {
      // Download CSV from Google Sheets
      const csvData = await this.downloadCsv(target.url);
      
      if (!csvData || csvData.trim().length === 0) {
        console.log(`   ⚠️  Empty CSV - skipping`);
        return 0;
      }
      
      // Parse CSV
      const records = parse(csvData, {
        columns: true,
        skip_empty_lines: true,
        trim: true
      });
      
      console.log(`   📋 Found ${records.length} roster entries`);
      
      if (records.length === 0) {
        console.log(`   ⚠️  No data rows - skipping`);
        return 0;
      }
      
      // Group by team
      const teamGroups = this.groupByTeam(records);
      console.log(`   🏆 Teams: ${Object.keys(teamGroups).length}`);
      
      let playersAdded = 0;
      
      for (const [teamName, players] of Object.entries(teamGroups)) {
        const added = await this.processTeamRoster(client, teamName, players, target);
        playersAdded += added;
      }
      
      return playersAdded;
      
    } catch (error) {
      console.error(`   ❌ Error processing ${target.label}: ${error.message}`);
      return 0;
    }
  }
  
  /**
   * Download CSV from Google Sheets URL (follows redirects)
   */
  downloadCsv(url) {
    return new Promise((resolve, reject) => {
      const makeRequest = (requestUrl, redirectCount = 0) => {
        if (redirectCount > 5) {
          return reject(new Error('Too many redirects'));
        }
        
        https.get(requestUrl, (res) => {
          // Handle redirects (Google Sheets uses 307)
          if (res.statusCode === 301 || res.statusCode === 302 || res.statusCode === 307 || res.statusCode === 308) {
            const redirectUrl = res.headers.location;
            if (!redirectUrl) {
              return reject(new Error(`Redirect without location header (${res.statusCode})`));
            }
            return makeRequest(redirectUrl, redirectCount + 1);
          }
          
          if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode}: ${res.statusMessage}`));
          return;
        }
        
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => resolve(data));
      }).on('error', reject);
      };
      
      // Start the request chain
      makeRequest(url);
    });
  }
  
  /**
   * Group roster records by team name
   */
  groupByTeam(records) {
    const groups = {};
    
    for (const record of records) {
      // Common column names in CASA sheets: "Team", "Team Name", "Club"
      const teamName = record.Team || record['Team Name'] || record.Club || 'Unknown Team';
      
      if (!groups[teamName]) {
        groups[teamName] = [];
      }
      
      groups[teamName].push(record);
    }
    
    return groups;
  }
  
  /**
   * Process roster for a single team
   */
  async processTeamRoster(client, teamName, players, target) {
    console.log(`\n      🏃 ${teamName} (${players.length} players)`);
    
    try {
      // Find or create team
      const team = await this.findOrCreateTeam(client, teamName, target.source_system_id);
      
      if (!team) {
        console.log(`      ⚠️  Could not find/create team - skipping`);
        return 0;
      }
      
      // Find division_team entry (we need this to link players)
      const divisionTeam = await this.findDivisionTeam(client, team.id, target.label);
      
      if (!divisionTeam) {
        console.log(`      ⚠️  No division_team entry - skipping`);
        return 0;
      }
      
      // Add each player
      let addedCount = 0;
      
      for (const playerData of players) {
        const added = await this.addPlayer(client, divisionTeam.id, playerData, target.source_system_id);
        if (added) addedCount++;
      }
      
      console.log(`      ✓ Added ${addedCount} players`);
      return addedCount;
      
    } catch (error) {
      console.error(`      ❌ Error processing ${teamName}: ${error.message}`);
      return 0;
    }
  }
  
  /**
   * Find or create team in database
   */
  async findOrCreateTeam(client, teamName, sourceSystemId) {
    // Try exact match first
    let result = await client.query(
      `SELECT id, name FROM teams WHERE name = $1 AND source_system_id = $2`,
      [teamName, sourceSystemId]
    );
    
    if (result.rows.length > 0) {
      return result.rows[0];
    }
    
    // Try case-insensitive match
    result = await client.query(
      `SELECT id, name FROM teams WHERE LOWER(name) = LOWER($1) AND source_system_id = $2`,
      [teamName, sourceSystemId]
    );
    
    if (result.rows.length > 0) {
      return result.rows[0];
    }
    
    // Create new team
    result = await client.query(
      `INSERT INTO teams (name, source_system_id, created_at)
       VALUES ($1, $2, CURRENT_TIMESTAMP)
       RETURNING id, name`,
      [teamName, sourceSystemId]
    );
    
    console.log(`      📝 Created new team: ${teamName}`);
    return result.rows[0];
  }
  
  /**
   * Find division_team entry for a team
   * Uses label to identify which division this roster belongs to
   */
  async findDivisionTeam(client, teamId, targetLabel) {
    // Extract division info from label (e.g., "CASA Select Philadelphia Liga 1 - Rosters")
    const divisionMatch = targetLabel.match(/(Philadelphia|Boston|Lancaster)\s+(Liga\s+\d+)/i);
    
    if (!divisionMatch) {
      console.log(`      ⚠️  Could not parse division from label: ${targetLabel}`);
      return null;
    }
    
    const conference = divisionMatch[1];  // "Philadelphia", "Boston", "Lancaster"
    const division = divisionMatch[2];    // "Liga 1", "Liga 2"
    
    // Find division_team for this team in the current CASA Select season
    const result = await client.query(`
      SELECT dt.id, dt.division_id, d.name as division_name
      FROM division_teams dt
      JOIN divisions d ON dt.division_id = d.id
      JOIN conferences c ON d.conference_id = c.id
      JOIN seasons s ON c.season_id = s.id
      JOIN leagues l ON s.league_id = l.id
      WHERE dt.team_id = $1
        AND l.name = 'CASA Select'
        AND s.name = '2025'
        AND c.name ILIKE $2
        AND d.name ILIKE $3
        AND dt.unregistered_at IS NULL
      LIMIT 1
    `, [teamId, `%${conference}%`, `%${division}%`]);
    
    if (result.rows.length === 0) {
      // Try to create division_team entry if division exists
      const divResult = await client.query(`
        SELECT d.id
        FROM divisions d
        JOIN conferences c ON d.conference_id = c.id
        JOIN seasons s ON c.season_id = s.id
        JOIN leagues l ON s.league_id = l.id
        WHERE l.name = 'CASA Select'
          AND s.name = '2025'
          AND c.name ILIKE $1
          AND d.name ILIKE $2
        LIMIT 1
      `, [`%${conference}%`, `%${division}%`]);
      
      if (divResult.rows.length > 0) {
        const divisionId = divResult.rows[0].id;
        
        const insertResult = await client.query(`
          INSERT INTO division_teams (division_id, team_id, registered_at)
          VALUES ($1, $2, CURRENT_TIMESTAMP)
          RETURNING id, division_id
        `, [divisionId, teamId]);
        
        console.log(`      📝 Created division_team entry`);
        return insertResult.rows[0];
      }
      
      return null;
    }
    
    return result.rows[0];
  }
  
  /**
   * Add a player to division_team roster
   */
  async addPlayer(client, divisionTeamId, playerData, sourceSystemId) {
    try {
      // Extract player name (common column names: "Player", "Player Name", "Name", "First Name"/"Last Name")
      const fullName = playerData.Player || playerData['Player Name'] || playerData.Name;
      const firstName = playerData['First Name'] || playerData.FirstName;
      const lastName = playerData['Last Name'] || playerData.LastName;
      
      let parsedFirstName, parsedLastName;
      
      if (firstName && lastName) {
        parsedFirstName = firstName.trim();
        parsedLastName = lastName.trim();
      } else if (fullName) {
        const parts = fullName.trim().split(/\s+/);
        if (parts.length === 1) {
          parsedFirstName = parts[0];
          parsedLastName = '';
        } else {
          parsedLastName = parts.pop();
          parsedFirstName = parts.join(' ');
        }
      } else {
        return false; // No name data
      }
      
      if (!parsedFirstName && !parsedLastName) {
        return false;
      }
      
      // Jersey number (common columns: "Number", "Jersey", "#", "No")
      const jerseyNumber = playerData.Number || playerData.Jersey || playerData['#'] || playerData.No || null;
      
      // Find or create person
      const person = await this.personRepo.findOrCreate({
        firstName: parsedFirstName,
        lastName: parsedLastName
      });
      
      // Find or create player
      const player = await this.playerRepo.findOrCreate({
        personId: person.id,
        sourceSystemId: sourceSystemId
      });
      
      // Check if player already on this division_team roster
      const existingResult = await client.query(
        `SELECT id FROM division_team_players 
         WHERE division_team_id = $1 AND player_id = $2 AND left_at IS NULL`,
        [divisionTeamId, player.id]
      );
      
      if (existingResult.rows.length > 0) {
        return false; // Already exists
      }
      
      // Add to roster
      await client.query(
        `INSERT INTO division_team_players (division_team_id, player_id, jersey_number, joined_at)
         VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
        [divisionTeamId, player.id, jerseyNumber]
      );
      
      return true;
      
    } catch (error) {
      console.error(`      ⚠️  Error adding player: ${error.message}`);
      return false;
    }
  }
}

// Run if executed directly
if (require.main === module) {
  const scraper = new CasaRosterScraper();
  scraper.scrape()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = CasaRosterScraper;
