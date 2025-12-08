#!/usr/bin/env node

/**
 * Find Duplicates - Data Quality Analysis
 * 
 * Queries the database to find potential duplicate users and data quality issues
 * Run after a full rebuild to identify problems
 * 
 * Usage: node database/scripts/find-duplicates.js
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Database connection
const client = new Client({
  host: 'localhost',
  port: 5432,
  database: 'footballhome',
  user: 'footballhome_user',
  password: 'footballhome_pass'
});

const REPORTS_DIR = path.join(__dirname, '..', 'reports');
const timestamp = new Date().toISOString().split('T')[0];
const reportFile = path.join(REPORTS_DIR, `duplicates-${timestamp}.txt`);

let report = [];

function log(message) {
  console.log(message);
  report.push(message);
}

async function findDuplicateNames() {
  log('\n========================================');
  log('DUPLICATE USER NAMES');
  log('========================================\n');
  
  const result = await client.query(`
    SELECT 
      first_name, 
      last_name, 
      COUNT(*) as count,
      STRING_AGG(id::text, ', ') as user_ids,
      STRING_AGG(
        COALESCE(
          (SELECT provider FROM user_external_identities WHERE user_id = users.id LIMIT 1), 
          'manual'
        ), 
        ', '
      ) as sources
    FROM users
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
    ORDER BY count DESC, last_name, first_name
  `);
  
  if (result.rows.length === 0) {
    log('✓ No duplicate names found\n');
  } else {
    log(`Found ${result.rows.length} duplicate name(s):\n`);
    result.rows.forEach(row => {
      log(`  ${row.first_name} ${row.last_name} (${row.count} times)`);
      log(`    Sources: ${row.sources}`);
      log(`    User IDs: ${row.user_ids}`);
      log('');
    });
  }
}

async function findCorruptedNames() {
  log('========================================');
  log('CORRUPTED/INVALID NAMES');
  log('========================================\n');
  
  const result = await client.query(`
    SELECT 
      id,
      first_name, 
      last_name,
      (SELECT provider FROM user_external_identities WHERE user_id = users.id LIMIT 1) as source
    FROM users
    WHERE 
      first_name ~ '[^\x20-\x7E]' OR  -- Non-ASCII characters
      last_name ~ '[^\x20-\x7E]' OR
      first_name ~ '\\ufffd' OR       -- Replacement character
      last_name ~ '\\ufffd' OR
      LENGTH(first_name) > 50 OR      -- Suspiciously long
      LENGTH(last_name) > 50
    ORDER BY last_name, first_name
  `);
  
  if (result.rows.length === 0) {
    log('✓ No corrupted names found\n');
  } else {
    log(`Found ${result.rows.length} corrupted name(s):\n`);
    result.rows.forEach(row => {
      log(`  ${row.first_name} ${row.last_name}`);
      log(`    Source: ${row.source || 'manual'}`);
      log(`    User ID: ${row.id}`);
      log('');
    });
  }
}

async function findDuplicateRosters() {
  log('========================================');
  log('DUPLICATE ROSTER ENTRIES');
  log('========================================\n');
  
  const result = await client.query(`
    SELECT 
      t.name as team_name,
      u.first_name,
      u.last_name,
      COUNT(*) as times_on_roster
    FROM team_players tp
    JOIN teams t ON tp.team_id = t.id
    JOIN players p ON tp.player_id = p.id
    JOIN users u ON p.id = u.id
    WHERE tp.is_active = true
    GROUP BY t.name, u.first_name, u.last_name, tp.player_id
    HAVING COUNT(*) > 1
    ORDER BY times_on_roster DESC, team_name
  `);
  
  if (result.rows.length === 0) {
    log('✓ No duplicate roster entries found\n');
  } else {
    log(`Found ${result.rows.length} duplicate roster entry(ies):\n`);
    result.rows.forEach(row => {
      log(`  ${row.first_name} ${row.last_name} on ${row.team_name} (${row.times_on_roster} times)`);
    });
    log('');
  }
}

async function findUsersWithoutExternalIds() {
  log('========================================');
  log('USERS WITHOUT EXTERNAL IDENTITIES');
  log('========================================\n');
  
  const result = await client.query(`
    SELECT 
      u.id,
      u.first_name,
      u.last_name,
      u.date_of_birth,
      COUNT(tp.id) as team_count
    FROM users u
    LEFT JOIN user_external_identities uei ON u.id = uei.user_id
    LEFT JOIN players p ON u.id = p.id
    LEFT JOIN team_players tp ON p.id = tp.player_id AND tp.is_active = true
    WHERE uei.id IS NULL
    GROUP BY u.id, u.first_name, u.last_name, u.date_of_birth
    ORDER BY team_count DESC, u.last_name, u.first_name
    LIMIT 20
  `);
  
  if (result.rows.length === 0) {
    log('✓ All users have external identities\n');
  } else {
    log(`Found ${result.rows.length} user(s) without external identities (showing top 20):\n`);
    result.rows.forEach(row => {
      log(`  ${row.first_name} ${row.last_name} (DOB: ${row.date_of_birth || 'unknown'}, Teams: ${row.team_count})`);
      log(`    User ID: ${row.id}`);
    });
    log('');
  }
}

async function findTeamsWithTooManyPlayers() {
  log('========================================');
  log('TEAMS WITH UNUSUAL ROSTER SIZES');
  log('========================================\n');
  
  const result = await client.query(`
    SELECT 
      t.name as team_name,
      COUNT(DISTINCT tp.player_id) as player_count
    FROM teams t
    JOIN team_players tp ON t.id = tp.team_id
    WHERE tp.is_active = true
    GROUP BY t.id, t.name
    HAVING COUNT(DISTINCT tp.player_id) > 50 OR COUNT(DISTINCT tp.player_id) < 10
    ORDER BY player_count DESC
  `);
  
  if (result.rows.length === 0) {
    log('✓ All team roster sizes look reasonable\n');
  } else {
    log(`Found ${result.rows.length} team(s) with unusual roster sizes:\n`);
    result.rows.forEach(row => {
      log(`  ${row.team_name}: ${row.player_count} players`);
    });
    log('');
  }
}

async function generateSummary() {
  log('========================================');
  log('SUMMARY');
  log('========================================\n');
  
  const stats = await client.query(`
    SELECT 
      (SELECT COUNT(*) FROM users) as total_users,
      (SELECT COUNT(*) FROM user_external_identities) as total_external_ids,
      (SELECT COUNT(*) FROM teams) as total_teams,
      (SELECT COUNT(*) FROM team_players WHERE is_active = true) as total_roster_entries,
      (SELECT COUNT(DISTINCT provider) FROM user_external_identities) as providers_count
  `);
  
  const row = stats.rows[0];
  log(`Total Users: ${row.total_users}`);
  log(`External Identities: ${row.total_external_ids}`);
  log(`Active Teams: ${row.total_teams}`);
  log(`Active Roster Entries: ${row.total_roster_entries}`);
  log(`Data Providers: ${row.providers_count}`);
  log('');
  
  const providers = await client.query(`
    SELECT provider, COUNT(*) as count
    FROM user_external_identities
    GROUP BY provider
    ORDER BY count DESC
  `);
  
  log('External Identity Breakdown:');
  providers.rows.forEach(p => {
    log(`  ${p.provider}: ${p.count}`);
  });
  log('');
}

async function main() {
  try {
    console.log('Connecting to database...');
    await client.connect();
    
    log('========================================');
    log('DATA QUALITY REPORT');
    log(`Generated: ${new Date().toISOString()}`);
    log('========================================');
    
    await generateSummary();
    await findDuplicateNames();
    await findCorruptedNames();
    await findDuplicateRosters();
    await findUsersWithoutExternalIds();
    await findTeamsWithTooManyPlayers();
    
    log('========================================');
    log('NEXT STEPS');
    log('========================================\n');
    log('1. Review issues above');
    log('2. Add fixes to database/data/ZZ-01-user-merges.sql');
    log('3. Add corrections to database/data/ZZ-02-data-corrections.sql');
    log('4. Rebuild: ./dev.sh --apsl --casa --groupme');
    log('');
    
    // Write report to file
    fs.writeFileSync(reportFile, report.join('\n'));
    console.log(`\n✓ Report saved to: ${reportFile}`);
    
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();
