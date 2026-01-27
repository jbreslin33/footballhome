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
      
      // Parse CSV without auto-header detection (CASA sheets have metadata rows)
      const allRows = parse(csvData, {
        columns: false,
        skip_empty_lines: true,
        trim: true,
        relax_column_count: true
      });
      
      console.log(`   📋 Found ${allRows.length} total rows`);
      
      if (allRows.length === 0) {
        console.log(`   ⚠️  No data rows - skipping`);
        return 0;
      }
      
      // Extract team name and players from CASA sheet structure
      const { teamName, players } = this.parseCasaRosterSheet(allRows);
      
      if (!teamName) {
        console.log(`   ⚠️  Could not find team name - skipping`);
        return 0;
      }
      
      console.log(`   🏆 Team: ${teamName} (${players.length} players)`);
      
      if (players.length === 0) {
        console.log(`   ⚠️  No players found - skipping`);
        return 0;
      }
      
      // Process roster for this team
      const playersAdded = await this.processTeamRoster(client, teamName, players, target);
      
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
   * Parse CASA roster sheet structure
   * Format:
   *   Row 1-3: Title rows
   *   Row 4: "Team Name:" label in column C (index 2), team name in column D (index 3)
   *   Row 5: Empty
   *   Row 6: "Manager:" label (optional)
   *   Row 7: Empty
   *   Row 8: Headers ("First Name", "Last Name", "Date of Birth", "Headshot", "Date Added", "Jersey #")
   *   Row 9+: Player data
   */
  parseCasaRosterSheet(rows) {
    let teamName = null;
    let headerRowIndex = -1;
    let headers = [];
    
    // Find team name and header row
    for (let i = 0; i < Math.min(rows.length, 20); i++) {
      const row = rows[i];
      
      // Look for "Team Name:" in column C (index 2)
      if (row[2] && row[2].toLowerCase().includes('team name')) {
        teamName = row[3]?.trim() || row[4]?.trim(); // Team name in column D or E
        continue;
      }
      
      // Look for header row (contains "First Name" and "Last Name")
      if (row.some(cell => cell && cell.toLowerCase().includes('first name')) &&
          row.some(cell => cell && cell.toLowerCase().includes('last name'))) {
        headerRowIndex = i;
        headers = row.map(h => h?.trim() || '');
        break;
      }
    }
    
    if (!teamName || headerRowIndex === -1) {
      return { teamName: null, players: [] };
    }
    
    // Parse player rows
    const players = [];
    for (let i = headerRowIndex + 1; i < rows.length; i++) {
      const row = rows[i];
      
      // Skip empty rows or rows without enough data
      if (!row || row.length < 3 || !row[1] || !row[2]) continue;
      
      // Build player object from row
      const jerseyNum = row[0] ? String(row[0]).trim() : '';
      const player = {
        // Column 0 contains the jersey number (CASA uses row numbers as jersey numbers)
        'Jersey #': jerseyNum
      };
      
      for (let j = 1; j < headers.length && j < row.length; j++) {
        if (headers[j] && headers[j] !== 'Jersey #') {  // Skip Jersey # - already set from row[0]
          player[headers[j]] = row[j]?.trim() || '';
        }
      }
      
      players.push(player);
    }
    
    return { teamName, players };
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
      
      // Jersey number (common columns: "Number", "Jersey", "#", "No", "Jersey #")
      const jerseyNumber = playerData.Number || playerData.Jersey || playerData['#'] || 
                           playerData.No || playerData['Jersey #'] || null;
      
      // Find or create person
      const personResult = await this.personRepo.upsert({
        firstName: parsedFirstName,
        lastName: parsedLastName
      });
      
      // Find or create player
      const playerResult = await this.playerRepo.upsert({
        personId: personResult.id,
        sourceSystemId: sourceSystemId
      });
      
      // Check if player already on this division_team roster
      const existingResult = await client.query(
        `SELECT id FROM division_team_players 
         WHERE division_team_id = $1 AND player_id = $2 AND left_at IS NULL`,
        [divisionTeamId, playerResult.id]
      );
      
      if (existingResult.rows.length > 0) {
        return false; // Already exists
      }
      
      // Add to roster
      await client.query(
        `INSERT INTO division_team_players (division_team_id, player_id, jersey_number, joined_at)
         VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
        [divisionTeamId, playerResult.id, jerseyNumber]
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
