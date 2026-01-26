#!/usr/bin/env node

/**
 * Populate Fall 2025 rosters from cached HTML files
 * This is a ONE-TIME script to pre-populate historical roster data
 * for the winter break period (Fall 2025 rosters used in Spring 2026)
 */

const fs = require('fs').promises;
const path = require('path');
const { Pool } = require('pg');
const ApslRosterParser = require('../infrastructure/parsers/ApslRosterParser');
const PersonRepository = require('../domain/repositories/PersonRepository');
const PlayerRepository = require('../domain/repositories/PlayerRepository');
const DivisionTeamPlayerRepository = require('../domain/repositories/DivisionTeamPlayerRepository');

// Database connection
const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: process.env.PGPORT || 5432,
  database: process.env.PGDATABASE || 'footballhome',
  user: process.env.PGUSER || 'footballhome_user',
  password: process.env.PGPASSWORD || 'footballhome_pass'
});

const parser = new ApslRosterParser();

/**
 * Get or create division_team_id for an APSL team
 * If team exists but not registered in this season's division, creates registration
 */
async function getOrCreateDivisionTeam(client, apslTeamId, seasonName = '2024/2025') {
  // First try to find existing division_team via external_id
  let result = await client.query(`
    SELECT dt.id, t.name as team_name, t.id as team_id, d.name as division_name, d.id as division_id
    FROM division_team_external_ids dtei
    JOIN division_teams dt ON dtei.division_team_id = dt.id
    JOIN teams t ON dt.team_id = t.id
    JOIN divisions d ON dt.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE dtei.source_system_id = 1
      AND dtei.external_id = $1
      AND s.name = $2
      AND dt.unregistered_at IS NULL
    LIMIT 1
  `, [apslTeamId, seasonName]);
  
  if (result.rows[0]) {
    return result.rows[0];
  }
  
  // Not found - try to find the team and infer division
  // Get team by external_id (teams.external_id = APSL team ID)
  const teamResult = await client.query(`
    SELECT id, name FROM teams WHERE source_system_id = 1 AND external_id = $1
  `, [apslTeamId]);
  
  if (teamResult.rows.length === 0) {
    return null; // Team doesn't exist at all
  }
  
  const team = teamResult.rows[0];
  
  // Find a division in this season (pick first one - we'll fix it later if wrong)
  const divisionResult = await client.query(`
    SELECT d.id, d.name
    FROM divisions d
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name = $1 AND s.league_id = 1
    LIMIT 1
  `, [seasonName]);
  
  if (divisionResult.rows.length === 0) {
    console.warn(`  ⚠️  No divisions found for season ${seasonName}`);
    return null;
  }
  
  const division = divisionResult.rows[0];
  
  // Create division_teams entry
  const dtResult = await client.query(`
    INSERT INTO division_teams (division_id, team_id, registered_at)
    VALUES ($1, $2, NOW())
    RETURNING id
  `, [division.id, team.id]);
  
  const divisionTeamId = dtResult.rows[0].id;
  
  // Create external_id mapping
  await client.query(`
    INSERT INTO division_team_external_ids (division_team_id, source_system_id, external_id)
    VALUES ($1, 1, $2)
    ON CONFLICT (source_system_id, external_id) DO NOTHING
  `, [divisionTeamId, apslTeamId]);
  
  console.log(`    ✨ Created division_teams entry for ${team.name} in ${division.name}`);
  
  return {
    id: divisionTeamId,
    team_id: team.id,
    team_name: team.name,
    division_id: division.id,
    division_name: division.name
  };
}

/**
 * Process a single APSL roster HTML file
 */
async function processRosterFile(filePath, filename) {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // Extract team ID from filename (e.g., "114812-bc27d2da.html" -> "114812")
    const teamId = parser.extractTeamId(filename);
    if (!teamId) {
      console.log(`  ⏭️  Skipping ${filename} (no team ID found)`);
      await client.query('ROLLBACK');
      return { skipped: true, reason: 'no_team_id' };
    }
    
    // Get or create division_team_id for this team
    const divisionTeam = await getOrCreateDivisionTeam(client, teamId);
    if (!divisionTeam) {
      console.log(`  ⏭️  Skipping ${filename} (team ${teamId} not found in database)`);
      await client.query('ROLLBACK');
      return { skipped: true, reason: 'team_not_found' };
    }
    
    // Read and parse HTML
    const html = await fs.readFile(filePath, 'utf-8');
    if (!html || html.trim().length === 0) {
      console.log(`  ⏭️  Skipping ${filename} (empty file)`);
      await client.query('ROLLBACK');
      return { skipped: true, reason: 'empty_file' };
    }
    
    const players = parser.parseRoster(html);
    if (players.length === 0) {
      console.log(`  ⚠️  ${filename}: No players found`);
      await client.query('ROLLBACK');
      return { processed: true, team: divisionTeam.team_name, players: 0 };
    }
    
    console.log(`  📋 ${divisionTeam.team_name} (${divisionTeam.division_name}): ${players.length} players`);
    
    // Create repository instances with this client
    const personRepo = new PersonRepository(client);
    const playerRepo = new PlayerRepository(client);
    const rosterRepo = new DivisionTeamPlayerRepository(client);
    
    let created = 0;
    let existing = 0;
    
    // Process each player
    for (const playerData of players) {
      try {
        // 1. Find or create person
        const personResult = await personRepo.upsert({
          firstName: playerData.firstName,
          lastName: playerData.lastName,
          birthDate: null
        });
        
        // 2. Find or create player
        const playerResult = await playerRepo.upsert({
          personId: personResult.id,
          sourceSystemId: 1, // APSL
          externalId: null // APSL doesn't provide player IDs in roster HTML
        });
        
        // 3. Find or create roster entry
        const rosterResult = await rosterRepo.upsert(
          divisionTeam.id,
          playerResult.id,
          {
            joinedAt: playerData.addedDate || new Date().toISOString(),
            jerseyNumber: null // APSL roster doesn't show jersey numbers
          }
        );
        
        if (rosterResult.inserted) {
          created++;
        } else {
          existing++;
        }
      } catch (error) {
        console.warn(`    ⚠️  Error processing player ${playerData.fullName}:`, error.message);
      }
    }
    
    await client.query('COMMIT');
    return {
      processed: true,
      team: divisionTeam.team_name,
      division: divisionTeam.division_name,
      players: players.length,
      created,
      existing
    };
    
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * Main execution
 */
async function main() {
  console.log('🏈 Populating Fall 2025 Rosters from Cached HTML\n');
  
  const apslDir = path.join(__dirname, '../../scraped-html/apsl');
  
  try {
    // Get all APSL HTML files (team roster pages are 6-digit IDs)
    const files = await fs.readdir(apslDir);
    const rosterFiles = files.filter(f => 
      f.match(/^\d{6}-[a-f0-9]+\.html$/) && // Team roster files (6-digit ID)
      !f.endsWith('.skip') // Skip files marked as skip
    );
    
    console.log(`📁 Found ${rosterFiles.length} APSL roster files\n`);
    
    let totalProcessed = 0;
    let totalSkipped = 0;
    let totalPlayers = 0;
    let totalCreated = 0;
    let totalExisting = 0;
    
    for (const filename of rosterFiles) {
      const filePath = path.join(apslDir, filename);
      
      try {
        const result = await processRosterFile(filePath, filename);
        
        if (result.skipped) {
          totalSkipped++;
        } else if (result.processed) {
          totalProcessed++;
          totalPlayers += result.players || 0;
          totalCreated += result.created || 0;
          totalExisting += result.existing || 0;
        }
      } catch (error) {
        console.error(`  ❌ Error processing ${filename}:`, error.message);
        totalSkipped++;
      }
    }
    
    console.log('\n✅ Roster Population Complete!\n');
    console.log(`📊 Summary:`);
    console.log(`   Teams Processed: ${totalProcessed}`);
    console.log(`   Teams Skipped: ${totalSkipped}`);
    console.log(`   Total Players: ${totalPlayers}`);
    console.log(`   Roster Entries Created: ${totalCreated}`);
    console.log(`   Roster Entries Existing: ${totalExisting}`);
    
  } catch (error) {
    console.error('\n❌ Fatal error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

module.exports = { processRosterFile };
