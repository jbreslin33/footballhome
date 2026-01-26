#!/usr/bin/env node
/**
 * Complete Database Snapshot Exporter
 * 
 * Exports ALL entities with explicit IDs for reproducible builds:
 * - Clubs (teams reference these)
 * - Teams (all teams, not just static ones)
 * - Division teams (team registrations)
 * - Division team players (rosters)
 * - Historical matches (2022-2024)
 * - Match events
 * - Match divisions
 * - Standings (optional)
 * 
 * This ensures ./build.sh creates identical database state every time.
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const client = new Client({
  host: 'localhost',
  port: 5432,
  database: 'footballhome',
  user: 'footballhome_user',
  password: 'footballhome_pass'
});

const DATA_DIR = path.join(__dirname, '../../data');

async function exportOrganizations() {
  console.log('🏢 Exporting organizations...');
  
  const result = await client.query(`
    SELECT o.id, o.name, o.short_name, o.website_url, o.logo_url, o.description, o.is_active
    FROM organizations o
    WHERE o.id > 3
    ORDER BY o.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ℹ️  No additional organizations found (only default 1-3)');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '030a-organizations-scraped.sql');
  let sql = `-- Organizations (scraped from leagues)
-- Generated: ${new Date().toISOString()}
-- Total Organizations: ${result.rows.length}
--
-- Note: IDs 1-3 are in 030-organizations.sql (APSL, CASA, CSL league operators)
-- IDs 4+ are team clubs discovered by scrapers

INSERT INTO organizations (id, name, short_name, website_url, logo_url, description, is_active) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${client.escapeLiteral(row.name)}, ${row.short_name ? client.escapeLiteral(row.short_name) : 'NULL'}, ${row.website_url ? client.escapeLiteral(row.website_url) : 'NULL'}, ${row.logo_url ? client.escapeLiteral(row.logo_url) : 'NULL'}, ${row.description ? client.escapeLiteral(row.description) : 'NULL'}, ${row.is_active})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} organizations to ${path.basename(sqlFile)}`);
}

async function exportClubs() {
  console.log('📦 Exporting clubs...');
  
  const result = await client.query(`
    SELECT c.id, c.organization_id, c.name, c.sport_id, c.logo_url, c.website, c.is_active
    FROM clubs c
    ORDER BY c.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ⚠️  No clubs found');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '035-clubs.sql');
  let sql = `-- Clubs (organizations own clubs)
-- Generated: ${new Date().toISOString()}
-- Total Clubs: ${result.rows.length}

INSERT INTO clubs (id, organization_id, name, sport_id, logo_url, website, is_active) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${row.organization_id}, ${client.escapeLiteral(row.name)}, ${row.sport_id}, ${row.logo_url ? client.escapeLiteral(row.logo_url) : 'NULL'}, ${row.website ? client.escapeLiteral(row.website) : 'NULL'}, ${row.is_active})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('clubs_id_seq', (SELECT MAX(id) FROM clubs));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} clubs to ${path.basename(sqlFile)}`);
}

async function exportAllTeams() {
  console.log('⚽ Exporting ALL teams...');
  
  const result = await client.query(`
    SELECT t.id, t.club_id, t.name, t.city, t.logo_url, t.source_system_id, t.external_id
    FROM teams t
    ORDER BY t.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ⚠️  No teams found');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '042-teams-complete.sql');
  let sql = `-- Complete Teams Export (ALL teams with explicit IDs)
-- Generated: ${new Date().toISOString()}
-- Total Teams: ${result.rows.length}
--
-- This file contains ALL teams (APSL, CSL, CASA, custom) with explicit IDs
-- to ensure reproducible builds. Historical matches reference these IDs.

INSERT INTO teams (id, club_id, name, city, logo_url, source_system_id, external_id) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${row.club_id || 'NULL'}, ${client.escapeLiteral(row.name)}, ${row.city ? client.escapeLiteral(row.city) : 'NULL'}, ${row.logo_url ? client.escapeLiteral(row.logo_url) : 'NULL'}, ${row.source_system_id || 'NULL'}, ${row.external_id ? client.escapeLiteral(row.external_id) : 'NULL'})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('teams_id_seq', (SELECT MAX(id) FROM teams));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} teams to ${path.basename(sqlFile)}`);
}

async function exportDivisionTeams() {
  console.log('📋 Exporting division team registrations...');
  
  const result = await client.query(`
    SELECT dt.id, dt.division_id, dt.team_id, dt.registered_at, dt.unregistered_at
    FROM division_teams dt
    JOIN divisions d ON dt.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name NOT LIKE '%2025%' AND s.name NOT LIKE '%2026%'
    ORDER BY dt.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ⚠️  No historical division teams found');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '045-division-teams.sql');
  let sql = `-- Historical Division Team Registrations
-- Generated: ${new Date().toISOString()}
-- Total Registrations: ${result.rows.length}
--
-- Team registrations in divisions for historical seasons (2022-2024).
-- Current season registrations are managed dynamically by scrapers.

INSERT INTO division_teams (id, division_id, team_id, registered_at, unregistered_at) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${row.division_id}, ${row.team_id}, '${row.registered_at.toISOString()}', ${row.unregistered_at ? `'${row.unregistered_at.toISOString()}'` : 'NULL'})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('division_teams_id_seq', (SELECT MAX(id) FROM division_teams));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} division team registrations to ${path.basename(sqlFile)}`);
}

async function exportMatches() {
  console.log('🏟️  Exporting historical matches...');
  
  const result = await client.query(`
    SELECT 
      m.id, m.match_type_id, m.home_team_id, m.away_team_id,
      m.match_date, m.match_time, m.venue_id, m.title, m.description,
      m.match_status_id, m.home_score, m.away_score,
      m.round_name, m.bracket_position, m.next_match_id, m.loser_next_match_id,
      m.seed_home, m.seed_away,
      m.source_system_id, m.external_id, m.scrape_target_id,
      m.created_by_user_id, m.created_at,
      s.name as season_name, l.name as league_name
    FROM matches m
    JOIN match_divisions md ON m.id = md.match_id
    JOIN divisions d ON md.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    JOIN leagues l ON s.league_id = l.id
    WHERE s.name NOT LIKE '%2025%' AND s.name NOT LIKE '%2026%'
    ORDER BY l.name, s.name, m.match_date, m.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ℹ️  No historical matches to export');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '051-matches.sql');
  let sql = `-- ============================================================================
-- HISTORICAL MATCHES EXPORT
-- ============================================================================
-- Generated: ${new Date().toISOString()}
-- Total Matches: ${result.rows.length}
-- 
-- Historical matches from completed seasons (2022-2024).
-- Current season matches (2025/2026) remain dynamic via scrapers.
-- ============================================================================

INSERT INTO matches (
  id, match_type_id, home_team_id, away_team_id,
  match_date, match_time, venue_id, title, description,
  match_status_id, home_score, away_score,
  round_name, bracket_position, next_match_id, loser_next_match_id,
  seed_home, seed_away,
  source_system_id, external_id, scrape_target_id,
  created_by_user_id, created_at
) VALUES\n`;
  
  const values = result.rows.map(row => {
    const fields = [
      row.id,
      row.match_type_id,
      row.home_team_id || 'NULL',
      row.away_team_id || 'NULL',
      `'${row.match_date.toISOString().split('T')[0]}'`,
      row.match_time ? `'${row.match_time}'` : 'NULL',
      row.venue_id || 'NULL',
      row.title ? client.escapeLiteral(row.title) : 'NULL',
      row.description ? client.escapeLiteral(row.description) : 'NULL',
      row.match_status_id || 'NULL',
      row.home_score !== null ? row.home_score : 'NULL',
      row.away_score !== null ? row.away_score : 'NULL',
      row.round_name ? client.escapeLiteral(row.round_name) : 'NULL',
      row.bracket_position ? client.escapeLiteral(row.bracket_position) : 'NULL',
      row.next_match_id || 'NULL',
      row.loser_next_match_id || 'NULL',
      row.seed_home || 'NULL',
      row.seed_away || 'NULL',
      row.source_system_id || 'NULL',
      row.external_id ? client.escapeLiteral(row.external_id) : 'NULL',
      row.scrape_target_id || 'NULL',
      row.created_by_user_id || 'NULL',
      `'${row.created_at.toISOString()}'`
    ];
    return `  (${fields.join(', ')})`;
  });
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('matches_id_seq', (SELECT MAX(id) FROM matches));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} matches to ${path.basename(sqlFile)}`);
}

async function exportMatchDivisions() {
  console.log('🔗 Exporting match-division associations...');
  
  const result = await client.query(`
    SELECT md.match_id, md.division_id, md.counts_for_standings
    FROM match_divisions md
    JOIN matches m ON md.match_id = m.id
    JOIN divisions d ON md.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name NOT LIKE '%2025%' AND s.name NOT LIKE '%2026%'
    ORDER BY md.match_id, md.division_id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ℹ️  No historical match divisions to export');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '052b-match-divisions.sql');
  let sql = `-- Match-Division Associations (Historical)
-- Generated: ${new Date().toISOString()}
-- Total Associations: ${result.rows.length}

INSERT INTO match_divisions (match_id, division_id, counts_for_standings) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.match_id}, ${row.division_id}, ${row.counts_for_standings})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (match_id, division_id) DO NOTHING;\n';
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} match-division associations to ${path.basename(sqlFile)}`);
}

async function exportMatchEvents() {
  console.log('📊 Exporting match events...');
  
  const result = await client.query(`
    SELECT 
      me.id, me.match_id, me.player_id, me.team_id, me.event_type_id,
      me.minute, me.assisted_by_player_id, me.created_at
    FROM match_events me
    JOIN matches m ON me.match_id = m.id
    JOIN match_divisions md ON m.id = md.match_id
    JOIN divisions d ON md.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name NOT LIKE '%2025%' AND s.name NOT LIKE '%2026%'
    ORDER BY me.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ℹ️  No historical match events to export');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '052-match-events.sql');
  let sql = `-- Match Events (Historical)
-- Generated: ${new Date().toISOString()}
-- Total Events: ${result.rows.length}

INSERT INTO match_events (
  id, match_id, player_id, team_id, event_type_id,
  minute, assisted_by_player_id, created_at
) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${row.match_id}, ${row.player_id}, ${row.team_id}, ${row.event_type_id}, ${row.minute}, ${row.assisted_by_player_id || 'NULL'}, '${row.created_at.toISOString()}')`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('match_events_id_seq', (SELECT MAX(id) FROM match_events));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} match events to ${path.basename(sqlFile)}`);
}

async function exportStandings() {
  console.log('🏆 Exporting standings...');
  
  const result = await client.query(`
    SELECT 
      st.id, st.competition_id, st.season_id, st.team_id,
      st.position, st.played, st.wins, st.draws, st.losses,
      st.goals_for, st.goals_against, st.goal_diff, st.points,
      st.fetched_at, st.source, st.created_at
    FROM standings st
    JOIN seasons s ON st.season_id = s.id
    WHERE s.name NOT LIKE '%2025%' AND s.name NOT LIKE '%2026%'
    ORDER BY st.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ℹ️  No historical standings to export');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '050-standings.sql');
  let sql = `-- Standings (Historical Snapshot)
-- Generated: ${new Date().toISOString()}
-- Total Standings: ${result.rows.length}

INSERT INTO standings (
  id, competition_id, season_id, team_id,
  position, played, wins, draws, losses,
  goals_for, goals_against, goal_diff, points,
  fetched_at, source, created_at
) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${row.competition_id}, ${row.season_id}, ${row.team_id}, ${row.position || 'NULL'}, ${row.played || 'NULL'}, ${row.wins || 'NULL'}, ${row.draws || 'NULL'}, ${row.losses || 'NULL'}, ${row.goals_for || 'NULL'}, ${row.goals_against || 'NULL'}, ${row.goal_diff || 'NULL'}, ${row.points || 'NULL'}, '${row.fetched_at.toISOString()}', ${row.source ? client.escapeLiteral(row.source) : 'NULL'}, '${row.created_at.toISOString()}')`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('standings_id_seq', (SELECT MAX(id) FROM standings));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} standings to ${path.basename(sqlFile)}`);
}

async function exportPersons() {
  console.log('👤 Exporting persons...');
  
  const result = await client.query(`
    SELECT p.id, p.first_name, p.last_name, p.birth_date
    FROM persons p
    ORDER BY p.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ⚠️  No persons found');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '020-persons.sql');
  let sql = `-- Persons (Core Identity)
-- Generated: ${new Date().toISOString()}
-- Total Persons: ${result.rows.length}

INSERT INTO persons (id, first_name, last_name, birth_date) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${client.escapeLiteral(row.first_name)}, ${client.escapeLiteral(row.last_name)}, ${row.birth_date ? `'${row.birth_date.toISOString().split('T')[0]}'` : 'NULL'})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('persons_id_seq', (SELECT MAX(id) FROM persons));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} persons to ${path.basename(sqlFile)}`);
}

async function exportPlayers() {
  console.log('⚽ Exporting players...');
  
  const result = await client.query(`
    SELECT p.id, p.person_id, p.height_cm, p.nationality, p.photo_url, 
           p.scrape_target_id, p.source_system_id, p.external_id
    FROM players p
    ORDER BY p.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ⚠️  No players found');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '021-players-complete.sql');
  let sql = `-- Players (Complete Export)
-- Generated: ${new Date().toISOString()}
-- Total Players: ${result.rows.length}
-- Note: Must load AFTER 020-persons.sql and BEFORE match events (052-*)

INSERT INTO players (id, person_id, height_cm, nationality, photo_url, scrape_target_id, source_system_id, external_id) VALUES\n`;
  
  const values = result.rows.map(row => 
    `  (${row.id}, ${row.person_id}, ${row.height_cm || 'NULL'}, ${row.nationality ? client.escapeLiteral(row.nationality) : 'NULL'}, ${row.photo_url ? client.escapeLiteral(row.photo_url) : 'NULL'}, ${row.scrape_target_id || 'NULL'}, ${row.source_system_id || 'NULL'}, ${row.external_id ? client.escapeLiteral(row.external_id) : 'NULL'})`
  );
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
  sql += `SELECT setval('players_id_seq', (SELECT MAX(id) FROM players));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} players to ${path.basename(sqlFile)}`);
}

async function exportDivisionTeamPlayers() {
  console.log('👥 Exporting division team players (rosters)...');
  
  const result = await client.query(`
    SELECT dtp.id, dtp.division_team_id, dtp.player_id, 
           dtp.joined_at, dtp.left_at, dtp.jersey_number
    FROM division_team_players dtp
    JOIN division_teams dt ON dtp.division_team_id = dt.id
    JOIN divisions d ON dt.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name NOT LIKE '%2026%'
    ORDER BY dtp.id
  `);
  
  if (result.rows.length === 0) {
    console.log('  ℹ️  No historical rosters to export (all rosters are current season)');
    return;
  }
  
  const sqlFile = path.join(DATA_DIR, '046-division-team-players.sql');
  let sql = `-- ============================================================================
-- DIVISION TEAM PLAYERS (ROSTERS) - HISTORICAL EXPORT
-- ============================================================================
-- Generated: ${new Date().toISOString()}
-- Total Roster Entries: ${result.rows.length}
-- 
-- Historical rosters from completed seasons (2022-2025 Fall).
-- Spring 2026 and future rosters remain dynamic via scrapers.
-- ============================================================================

INSERT INTO division_team_players (
  id, division_team_id, player_id, joined_at, left_at, jersey_number
) VALUES\n`;
  
  const values = result.rows.map(row => {
    const fields = [
      row.id,
      row.division_team_id,
      row.player_id,
      `'${row.joined_at.toISOString()}'`,
      row.left_at ? `'${row.left_at.toISOString()}'` : 'NULL',
      row.jersey_number ? client.escapeLiteral(row.jersey_number) : 'NULL'
    ];
    return `  (${fields.join(', ')})`;
  });
  
  sql += values.join(',\n');
  sql += '\nON CONFLICT (division_team_id, player_id, joined_at) DO NOTHING;\n\n';
  sql += `SELECT setval('division_team_players_id_seq', (SELECT MAX(id) FROM division_team_players));\n`;
  
  fs.writeFileSync(sqlFile, sql);
  console.log(`  ✓ Exported ${result.rows.length} roster entries to ${path.basename(sqlFile)}`);
}

async function main() {
  try {
    console.log('🚀 Starting complete database snapshot export...\n');
    await client.connect();
    console.log('✓ Connected to database\n');
    
    // Export in dependency order
    await exportOrganizations();
    await exportClubs();
    await exportAllTeams();
    await exportDivisionTeams();
    await exportPersons();  // Must come before players
    await exportPlayers();  // Must come before match events
    await exportDivisionTeamPlayers();  // Rosters (after players and division_teams)
    await exportMatches();
    await exportMatchDivisions();
    await exportMatchEvents();
    await exportStandings();
    
    console.log('\n✅ Complete snapshot export finished!');
    console.log('\n📝 Next steps:');
    console.log('   1. Delete old static files (040, 041) if desired');
    console.log('   2. Run ./build.sh to rebuild with new snapshot');
    console.log('   3. All historical data will load with consistent IDs');
    
  } catch (error) {
    console.error('❌ Export failed:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();
