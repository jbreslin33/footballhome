#!/usr/bin/env node
/**
 * Database Audit Script
 * Shows what data exists and what's missing
 * 
 * Usage: 
 *   Via Docker: podman exec footballhome_db psql -U footballhome_user -d footballhome -f /path/to/audit.sql
 *   Or: node database/scripts/audit-database.js
 */

const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

async function runQuery(sql) {
  const cmd = `podman exec footballhome_db psql -U footballhome_user -d footballhome -t -c "${sql.replace(/"/g, '\\"')}"`;
  const { stdout } = await execAsync(cmd);
  return stdout.trim();
}

async function auditDatabase() {
  console.log('\n📊 FOOTBALL HOME DATABASE AUDIT');
  console.log('='.repeat(80));
  
  try {
    // 1. LEAGUE STRUCTURE (from SQL files)
    console.log('\n🏗️  LEAGUE STRUCTURE (Static - from SQL files):');
    const orgCount = await runQuery('SELECT COUNT(*) FROM organizations');
    const leagueCount = await runQuery('SELECT COUNT(*) FROM leagues');
    const seasonCount = await runQuery('SELECT COUNT(*) FROM seasons');
    const confCount = await runQuery('SELECT COUNT(*) FROM conferences');
    const divCount = await runQuery('SELECT COUNT(*) FROM divisions');
    const teamCount = await runQuery('SELECT COUNT(*) FROM teams');
    
    console.log(`   Organizations: ${orgCount}`);
    console.log(`   Leagues: ${leagueCount}`);
    console.log(`   Seasons: ${seasonCount}`);
    console.log(`   Conferences: ${confCount}`);
    console.log(`   Divisions: ${divCount}`);
    console.log(`   Teams: ${teamCount}`);
    
    // 2. CURRENT SEASON DATA
    console.log('\n📅 CURRENT SEASON (Most Recent) - Dynamic data:');
    const currentSeasonQuery = await runQuery(
      "SELECT id || '|' || name FROM seasons ORDER BY id DESC LIMIT 1"
    );
    
    if (currentSeasonQuery) {
      const [seasonId, seasonName] = currentSeasonQuery.split('|');
      console.log(`   Season: ${seasonName} (id=${seasonId})`);
      
      const divTeams = await runQuery(`
        SELECT COUNT(*) FROM division_teams dt 
        JOIN divisions d ON dt.division_id = d.id 
        WHERE d.season_id = ${seasonId}
      `);
      
      const standings = await runQuery(`SELECT COUNT(*) FROM standings WHERE season_id = ${seasonId}`);
      const allMatches = await runQuery(`SELECT COUNT(*) FROM matches`);
      const withResults = await runQuery(`SELECT COUNT(*) FROM matches WHERE home_score IS NOT NULL`);
      
      console.log(`   Division-Team Assignments: ${divTeams}`);
      console.log(`   Standings Records: ${standings}`);
      console.log(`   Total Matches (all time): ${allMatches}`);
      console.log(`   Matches with Results: ${withResults}`);
      console.log(`   Matches MISSING Results: ${parseInt(allMatches) - parseInt(withResults)}`);
    } else {
      console.log('   ⚠️  No seasons found!');
    }
    
    // 3. WHAT'S MISSING
    console.log('\n🔍 WHAT NEEDS SCRAPING:');
    const { stdout: needsResults } = await execAsync(`
      podman exec footballhome_db psql -U footballhome_user -d footballhome -c "
        SELECT COUNT(*) as missing_results
        FROM matches
        WHERE match_date < CURRENT_DATE
          AND home_score IS NULL
      "
    `);
    
    console.log('   Completed matches without results:');
    console.log(needsResults);
    
    // 4. PLAYERS
    console.log('\n👥 PLAYERS & ROSTERS:');
    const persons = await runQuery('SELECT COUNT(*) FROM persons');
    const players = await runQuery('SELECT COUNT(*) FROM players');
    const rosters = await runQuery('SELECT COUNT(*) FROM division_team_players');
    
    console.log(`   Total Persons: ${persons}`);
    console.log(`   Total Players: ${players}`);
    console.log(`   Roster Assignments: ${rosters}`);
    
    // 5. SCRAPE TARGETS
    console.log('\n🎯 SCRAPE TARGETS:');
    const { stdout: targets } = await execAsync(`
      podman exec footballhome_db psql -U footballhome_user -d footballhome -c "
        SELECT st.id, st.label, st.is_active, 
               COALESCE(sa.name, 'null') as action,
               COALESCE(ss.name, 'null') as status
        FROM scrape_targets st
        LEFT JOIN scrape_actions sa ON st.scrape_action_id = sa.id
        LEFT JOIN scrape_statuses ss ON st.scrape_status_id = ss.id
        ORDER BY st.id
      "
    `);
    console.log(targets);
    
    console.log('\n' + '='.repeat(80));
    console.log('✅ Audit complete!\n');
    
  } catch (error) {
    console.error('❌ Audit failed:', error.message);
    throw error;
  }
}

// Run if called directly
if (require.main === module) {
  auditDatabase().catch(err => {
    console.error(err);
    process.exit(1);
  });
}

module.exports = auditDatabase;
