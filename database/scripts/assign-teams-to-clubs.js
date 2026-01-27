#!/usr/bin/env node

/**
 * Auto-assign Teams to Clubs
 * 
 * This script attempts to automatically assign teams to clubs based on:
 * - Name matching (exact or fuzzy)
 * - Organization relationships
 * - Manual configuration
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

// Manual mappings for known teams that don't match by name
const MANUAL_MAPPINGS = {
  // Example: 'Team Name': 'Club Name'
  'Lighthouse 1893 SC': 'Lighthouse 1893 SC',
  'Falcons FC': 'Falcons FC',
  // Add more manual mappings as needed
};

function normalizeTeamName(name) {
  return name
    .toLowerCase()
    .replace(/\s+(fc|sc|united|city|athletic|soccer|club)$/i, '')
    .replace(/[^\w\s]/g, '')
    .trim();
}

async function getUnassignedTeams() {
  const result = await pool.query(`
    SELECT 
      t.id,
      t.name,
      t.city,
      ss.name as source_system,
      ss.id as source_system_id
    FROM teams t
    LEFT JOIN source_systems ss ON t.source_system_id = ss.id
    WHERE t.club_id IS NULL
    ORDER BY t.name
  `);
  
  return result.rows;
}

async function getClubs() {
  const result = await pool.query(`
    SELECT 
      c.id,
      c.name,
      c.organization_id,
      o.name as organization_name
    FROM clubs c
    JOIN organizations o ON c.organization_id = o.id
    ORDER BY c.name
  `);
  
  return result.rows;
}

async function findMatchingClub(team, clubs) {
  const teamNameNormalized = normalizeTeamName(team.name);
  
  // Check manual mappings first
  if (MANUAL_MAPPINGS[team.name]) {
    const manualMatch = clubs.find(c => c.name === MANUAL_MAPPINGS[team.name]);
    if (manualMatch) {
      return { club: manualMatch, confidence: 'manual', reason: 'Manual mapping' };
    }
  }
  
  // Try exact name match
  const exactMatch = clubs.find(c => c.name === team.name);
  if (exactMatch) {
    return { club: exactMatch, confidence: 'high', reason: 'Exact name match' };
  }
  
  // Try normalized name match
  for (const club of clubs) {
    const clubNameNormalized = normalizeTeamName(club.name);
    if (teamNameNormalized === clubNameNormalized) {
      return { club, confidence: 'high', reason: 'Normalized name match' };
    }
  }
  
  // Try substring match (team name contains club name or vice versa)
  for (const club of clubs) {
    const clubNameLower = club.name.toLowerCase();
    const teamNameLower = team.name.toLowerCase();
    
    if (teamNameLower.includes(clubNameLower) || clubNameLower.includes(teamNameLower)) {
      return { club, confidence: 'medium', reason: 'Substring match' };
    }
  }
  
  return null;
}

async function createClubForTeam(team, dryRun = true) {
  if (dryRun) {
    console.log(`    ${colors.yellow}[DRY RUN]${colors.reset} Would create club: ${team.name}`);
    return null;
  }
  
  // Determine organization_id based on source_system
  let organizationId;
  if (team.source_system === 'apsl') organizationId = 1;
  else if (team.source_system === 'casa') organizationId = 2;
  else if (team.source_system === 'csl') organizationId = 3;
  else {
    console.log(`    ${colors.red}✗ Unknown source system: ${team.source_system}${colors.reset}`);
    return null;
  }
  
  const result = await pool.query(`
    INSERT INTO clubs (organization_id, name, is_active)
    VALUES ($1, $2, true)
    RETURNING id
  `, [organizationId, team.name]);
  
  console.log(`    ${colors.green}✓ Created club: ${team.name} (ID: ${result.rows[0].id})${colors.reset}`);
  return result.rows[0].id;
}

async function assignTeamToClub(teamId, clubId, dryRun = true) {
  if (dryRun) {
    console.log(`    ${colors.yellow}[DRY RUN]${colors.reset} Would assign team ${teamId} to club ${clubId}`);
    return false;
  }
  
  await pool.query(`
    UPDATE teams
    SET club_id = $1
    WHERE id = $2
  `, [clubId, teamId]);
  
  return true;
}

async function main() {
  const dryRun = process.argv.includes('--dry-run') || !process.argv.includes('--execute');
  
  console.log(`\n${colors.cyan}╔════════════════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.cyan}║        AUTO-ASSIGN TEAMS TO CLUBS                      ║${colors.reset}`);
  console.log(`${colors.cyan}╚════════════════════════════════════════════════════════════╝${colors.reset}\n`);
  
  if (dryRun) {
    console.log(`${colors.yellow}⚠️  DRY RUN MODE - No changes will be made${colors.reset}`);
    console.log(`${colors.yellow}   Run with --execute to apply changes${colors.reset}\n`);
  } else {
    console.log(`${colors.red}⚠️  EXECUTE MODE - Changes will be applied!${colors.reset}\n`);
  }
  
  try {
    const unassignedTeams = await getUnassignedTeams();
    const clubs = await getClubs();
    
    console.log(`${colors.blue}Found:${colors.reset}`);
    console.log(`  • ${unassignedTeams.length} unassigned teams`);
    console.log(`  • ${clubs.length} existing clubs\n`);
    
    if (unassignedTeams.length === 0) {
      console.log(`${colors.green}✓ All teams are already assigned to clubs${colors.reset}\n`);
      return;
    }
    
    let assigned = 0;
    let created = 0;
    let skipped = 0;
    
    console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.cyan}PROCESSING TEAMS${colors.reset}`);
    console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
    
    for (const team of unassignedTeams) {
      console.log(`${colors.blue}Team:${colors.reset} ${team.name} (ID: ${team.id})`);
      console.log(`  Source: ${team.source_system}`);
      
      const match = await findMatchingClub(team, clubs);
      
      if (match) {
        console.log(`  ${colors.green}✓ Found match:${colors.reset} ${match.club.name} (${match.confidence} confidence)`);
        console.log(`    Reason: ${match.reason}`);
        
        const success = await assignTeamToClub(team.id, match.club.id, dryRun);
        if (success || dryRun) {
          assigned++;
        }
      } else {
        console.log(`  ${colors.yellow}⚠️  No matching club found${colors.reset}`);
        console.log(`    ${colors.yellow}Option: Create new club for this team${colors.reset}`);
        
        // For standalone teams, create a club with the same name
        const clubId = await createClubForTeam(team, dryRun);
        if (clubId || dryRun) {
          await assignTeamToClub(team.id, clubId || 0, dryRun);
          created++;
          assigned++;
        } else {
          skipped++;
        }
      }
      
      console.log();
    }
    
    console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.cyan}SUMMARY${colors.reset}`);
    console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
    console.log(`  ${colors.green}✓ Teams assigned:${colors.reset} ${assigned}`);
    console.log(`  ${colors.blue}+ Clubs created:${colors.reset} ${created}`);
    console.log(`  ${colors.yellow}- Teams skipped:${colors.reset} ${skipped}\n`);
    
    if (dryRun && assigned > 0) {
      console.log(`${colors.yellow}Run with --execute to apply these changes${colors.reset}\n`);
    }
    
  } catch (error) {
    console.error(`${colors.red}Error:${colors.reset}`, error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
