#!/usr/bin/env node

/**
 * Data Quality Check Script
 * 
 * Checks for common data quality issues:
 * - Teams without club assignments
 * - Duplicate team names
 * - Players without persons
 * - Division teams without rosters
 * - Orphaned records
 */

const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : 'footballhome_pass',
});

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

async function checkUnassignedTeams() {
  console.log(`\n${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  console.log(`${colors.cyan}📋 TEAMS WITHOUT CLUB ASSIGNMENTS${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  
  const result = await pool.query(`
    SELECT 
      t.id,
      t.name,
      t.city,
      ss.name as source_system,
      COUNT(DISTINCT dt.id) as division_registrations,
      COUNT(DISTINCT dtp.player_id) as total_players
    FROM teams t
    LEFT JOIN source_systems ss ON t.source_system_id = ss.id
    LEFT JOIN division_teams dt ON dt.team_id = t.id
    LEFT JOIN division_team_players dtp ON dtp.division_team_id = dt.id
    WHERE t.club_id IS NULL
    GROUP BY t.id, t.name, t.city, ss.name
    ORDER BY total_players DESC, t.name
  `);
  
  if (result.rows.length === 0) {
    console.log(`${colors.green}✓ All teams are assigned to clubs${colors.reset}`);
    return [];
  }
  
  console.log(`${colors.yellow}⚠️  Found ${result.rows.length} teams without club assignments:${colors.reset}\n`);
  
  for (const row of result.rows) {
    console.log(`  ${colors.yellow}•${colors.reset} ${row.name} (ID: ${row.id})`);
    console.log(`    Source: ${row.source_system || 'Unknown'}`);
    console.log(`    City: ${row.city || 'Unknown'}`);
    console.log(`    Registrations: ${row.division_registrations}, Players: ${row.total_players}`);
  }
  
  return result.rows;
}

async function suggestClubMatches(unassignedTeams) {
  if (unassignedTeams.length === 0) return;
  
  console.log(`\n${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  console.log(`${colors.cyan}🔍 SUGGESTED CLUB MATCHES${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
  
  // Get all clubs with their organizations
  const clubsResult = await pool.query(`
    SELECT 
      c.id,
      c.name,
      o.name as organization_name
    FROM clubs c
    JOIN organizations o ON c.organization_id = o.id
    ORDER BY c.name
  `);
  
  const clubs = clubsResult.rows;
  
  for (const team of unassignedTeams) {
    // Try to find matching club by name similarity
    const teamNameLower = team.name.toLowerCase();
    const matches = clubs.filter(club => {
      const clubNameLower = club.name.toLowerCase();
      // Check if team name contains club name or vice versa
      return teamNameLower.includes(clubNameLower) || 
             clubNameLower.includes(teamNameLower) ||
             // Check for common abbreviations
             teamNameLower.replace(/\s+/g, '') === clubNameLower.replace(/\s+/g, '');
    });
    
    if (matches.length > 0) {
      console.log(`${colors.blue}Team:${colors.reset} ${team.name} (ID: ${team.id})`);
      console.log(`${colors.green}  Possible matches:${colors.reset}`);
      for (const match of matches) {
        console.log(`    → ${match.name} (ID: ${match.id}) under ${match.organization_name}`);
      }
      console.log();
    }
  }
}

async function checkDuplicateTeams() {
  console.log(`\n${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  console.log(`${colors.cyan}🔍 DUPLICATE TEAM NAMES${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  
  const result = await pool.query(`
    SELECT 
      name,
      COUNT(*) as count,
      array_agg(id) as team_ids
    FROM teams
    GROUP BY name
    HAVING COUNT(*) > 1
    ORDER BY count DESC, name
  `);
  
  if (result.rows.length === 0) {
    console.log(`${colors.green}✓ No duplicate team names found${colors.reset}`);
    return;
  }
  
  console.log(`${colors.yellow}⚠️  Found ${result.rows.length} duplicate team names:${colors.reset}\n`);
  
  for (const row of result.rows) {
    console.log(`  ${colors.yellow}•${colors.reset} ${row.name} (${row.count} instances)`);
    console.log(`    IDs: ${row.team_ids.join(', ')}`);
  }
}

async function checkTeamsWithoutRosters() {
  console.log(`\n${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  console.log(`${colors.cyan}📋 DIVISION TEAMS WITHOUT ROSTERS (2025/2026)${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  
  const result = await pool.query(`
    SELECT 
      t.id,
      t.name as team_name,
      d.name as division_name,
      s.name as season_name,
      l.name as league_name,
      COUNT(dtp.id) as player_count
    FROM division_teams dt
    JOIN teams t ON dt.team_id = t.id
    JOIN divisions d ON dt.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    JOIN leagues l ON s.league_id = l.id
    LEFT JOIN division_team_players dtp ON dtp.division_team_id = dt.id
    WHERE s.name = '2025/2026'
      AND dt.unregistered_at IS NULL
    GROUP BY t.id, t.name, d.name, s.name, l.name
    HAVING COUNT(dtp.id) = 0
    ORDER BY l.name, d.name, t.name
  `);
  
  if (result.rows.length === 0) {
    console.log(`${colors.green}✓ All 2025/2026 division teams have rosters${colors.reset}`);
    return;
  }
  
  console.log(`${colors.yellow}⚠️  Found ${result.rows.length} division teams without rosters:${colors.reset}\n`);
  
  let currentLeague = null;
  for (const row of result.rows) {
    if (row.league_name !== currentLeague) {
      console.log(`\n  ${colors.blue}${row.league_name}:${colors.reset}`);
      currentLeague = row.league_name;
    }
    console.log(`    ${colors.yellow}•${colors.reset} ${row.team_name} in ${row.division_name}`);
  }
}

async function checkPlayersWithoutPersons() {
  console.log(`\n${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  console.log(`${colors.cyan}👤 DATA INTEGRITY CHECKS${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  
  // Check for players without persons (should be impossible with FK constraint)
  const orphanedPlayers = await pool.query(`
    SELECT COUNT(*) as count
    FROM players p
    LEFT JOIN persons per ON p.person_id = per.id
    WHERE per.id IS NULL
  `);
  
  if (orphanedPlayers.rows[0].count > 0) {
    console.log(`${colors.red}✗ Found ${orphanedPlayers.rows[0].count} players without person records${colors.reset}`);
  } else {
    console.log(`${colors.green}✓ All players have valid person records${colors.reset}`);
  }
  
  // Check for persons without names
  const personsWithoutNames = await pool.query(`
    SELECT COUNT(*) as count
    FROM persons
    WHERE first_name IS NULL OR last_name IS NULL OR 
          TRIM(first_name) = '' OR TRIM(last_name) = ''
  `);
  
  if (personsWithoutNames.rows[0].count > 0) {
    console.log(`${colors.red}✗ Found ${personsWithoutNames.rows[0].count} persons without proper names${colors.reset}`);
  } else {
    console.log(`${colors.green}✓ All persons have first and last names${colors.reset}`);
  }
  
  // Check for matches without dates
  const matchesWithoutDates = await pool.query(`
    SELECT COUNT(*) as count
    FROM matches
    WHERE match_date IS NULL
  `);
  
  if (matchesWithoutDates.rows[0].count > 0) {
    console.log(`${colors.red}✗ Found ${matchesWithoutDates.rows[0].count} matches without dates${colors.reset}`);
  } else {
    console.log(`${colors.green}✓ All matches have dates${colors.reset}`);
  }
}

async function generateStats() {
  console.log(`\n${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
  console.log(`${colors.cyan}📊 DATABASE STATISTICS${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
  
  const stats = await pool.query(`
    SELECT 
      'Organizations' as entity,
      COUNT(*) as count
    FROM organizations
    UNION ALL
    SELECT 'Clubs', COUNT(*) FROM clubs
    UNION ALL
    SELECT 'Teams', COUNT(*) FROM teams
    UNION ALL
    SELECT 'Teams with Clubs', COUNT(*) FROM teams WHERE club_id IS NOT NULL
    UNION ALL
    SELECT 'Teams without Clubs', COUNT(*) FROM teams WHERE club_id IS NULL
    UNION ALL
    SELECT 'Persons', COUNT(*) FROM persons
    UNION ALL
    SELECT 'Players', COUNT(*) FROM players
    UNION ALL
    SELECT 'Users', COUNT(*) FROM users
    UNION ALL
    SELECT 'Seasons (2025/2026)', COUNT(*) FROM seasons WHERE name = '2025/2026'
    UNION ALL
    SELECT 'Divisions (2025/2026)', COUNT(*) 
    FROM divisions d 
    JOIN seasons s ON d.season_id = s.id 
    WHERE s.name = '2025/2026'
    UNION ALL
    SELECT 'Division Teams (2025/2026)', COUNT(*) 
    FROM division_teams dt
    JOIN divisions d ON dt.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name = '2025/2026' AND dt.unregistered_at IS NULL
    UNION ALL
    SELECT 'Roster Entries (2025/2026)', COUNT(*) 
    FROM division_team_players dtp
    JOIN division_teams dt ON dtp.division_team_id = dt.id
    JOIN divisions d ON dt.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name = '2025/2026' AND dtp.left_at IS NULL
    UNION ALL
    SELECT 'Matches (2025/2026)', COUNT(*)
    FROM matches m
    JOIN match_divisions md ON md.match_id = m.id
    JOIN divisions d ON md.division_id = d.id
    JOIN seasons s ON d.season_id = s.id
    WHERE s.name = '2025/2026'
  `);
  
  for (const row of stats.rows) {
    const label = row.entity.padEnd(30);
    console.log(`  ${label} ${colors.blue}${row.count}${colors.reset}`);
  }
}

async function main() {
  console.log(`\n${colors.cyan}╔════════════════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.cyan}║          FOOTBALL HOME - DATA QUALITY CHECK            ║${colors.reset}`);
  console.log(`${colors.cyan}╚════════════════════════════════════════════════════════════╝${colors.reset}`);
  
  try {
    // Run all checks
    const unassignedTeams = await checkUnassignedTeams();
    await suggestClubMatches(unassignedTeams);
    await checkDuplicateTeams();
    await checkTeamsWithoutRosters();
    await checkPlayersWithoutPersons();
    await generateStats();
    
    console.log(`\n${colors.green}✓ Data quality check complete${colors.reset}\n`);
    
  } catch (error) {
    console.error(`${colors.red}Error during data quality check:${colors.reset}`, error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
