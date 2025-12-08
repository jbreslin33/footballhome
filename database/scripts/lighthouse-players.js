#!/usr/bin/env node
/**
 * Lighthouse Players Report
 * 
 * Shows all players associated with Lighthouse 1893 SC across all teams,
 * including their external identities and current team assignments
 * 
 * Usage: node database/scripts/lighthouse-players.js [--active-only]
 */

const { Client } = require('pg');

const dbConfig = {
  host: 'localhost',
  port: 5432,
  database: 'footballhome',
  user: 'footballhome_user',
  password: 'footballhome_pass'
};

const ACTIVE_ONLY = process.argv.includes('--active-only');
const LIGHTHOUSE_SLUG = 'lighthouse-1893-sc';

async function getLighthousePlayers() {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    console.log('🔌 Connected to database\n');
    
    // Get all Lighthouse players with their team assignments
    const query = `
      WITH lighthouse_division AS (
        SELECT sd.id as division_id, sd.name, c.name as club_name
        FROM sport_divisions sd
        JOIN clubs c ON sd.club_id = c.id
        WHERE c.slug = $1
        LIMIT 1
      ),
      player_teams AS (
        SELECT 
          tp.player_id,
          STRING_AGG(t.name, ', ' ORDER BY t.name) as teams,
          COUNT(*) as team_count,
          BOOL_OR(tp.is_active) as on_any_active_team
        FROM team_players tp
        JOIN teams t ON tp.team_id = t.id
        JOIN lighthouse_division ld ON t.division_id = ld.division_id
        ${ACTIVE_ONLY ? 'WHERE tp.is_active = true' : ''}
        GROUP BY tp.player_id
      )
      SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone,
        u.date_of_birth,
        u.date_of_birth::date - CURRENT_DATE as age_days,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.date_of_birth::date)) as age_years,
        pt.teams,
        pt.team_count,
        pt.on_any_active_team,
        COALESCE(
          STRING_AGG(DISTINCT uei.provider || ':' || uei.external_id, ', '),
          'none'
        ) as external_ids,
        COALESCE(
          STRING_AGG(DISTINCT uei.provider, ', '),
          'manual'
        ) as data_sources
      FROM users u
      JOIN players p ON u.id = p.id
      LEFT JOIN player_teams pt ON p.id = pt.player_id
      LEFT JOIN user_external_identities uei ON u.id = uei.user_id
      WHERE pt.player_id IS NOT NULL  -- Has team assignment in Lighthouse
      GROUP BY u.id, u.first_name, u.last_name, u.email, u.phone, u.date_of_birth, 
               pt.teams, pt.team_count, pt.on_any_active_team
      ORDER BY u.last_name, u.first_name;
    `;
    
    const result = await client.query(query, [LIGHTHOUSE_SLUG]);
    
    console.log('========================================');
    console.log('LIGHTHOUSE 1893 SC - PLAYER ROSTER');
    console.log('========================================\n');
    
    console.log(`Total Players: ${result.rows.length}`);
    console.log(`Active Filter: ${ACTIVE_ONLY ? 'YES - showing only active players' : 'NO - showing all players'}\n`);
    
    // Group by data source
    const bySource = {};
    result.rows.forEach(row => {
      const sources = row.data_sources.split(', ');
      sources.forEach(source => {
        bySource[source] = (bySource[source] || 0) + 1;
      });
    });
    
    console.log('Players by Data Source:');
    Object.entries(bySource).sort((a, b) => b[1] - a[1]).forEach(([source, count]) => {
      console.log(`  ${source}: ${count}`);
    });
    console.log('');
    
    // Show all players
    console.log('========================================');
    console.log('PLAYER DETAILS');
    console.log('========================================\n');
    
    result.rows.forEach((row, idx) => {
      const age = row.age_years ? `${row.age_years} years` : 'unknown';
      const status = row.on_any_active_team ? '✅ Active' : '⏸️  Inactive';
      
      console.log(`${idx + 1}. ${row.first_name} ${row.last_name} (${age})`);
      console.log(`   Status: ${status}`);
      if (row.email) console.log(`   Email: ${row.email}`);
      if (row.phone) console.log(`   Phone: ${row.phone}`);
      console.log(`   Teams: ${row.teams || 'None'} (${row.team_count || 0} team(s))`);
      console.log(`   Data Sources: ${row.data_sources}`);
      if (row.external_ids !== 'none') {
        console.log(`   External IDs: ${row.external_ids}`);
      }
      console.log('');
    });
    
    // Find players without external IDs (manually entered only)
    const manualOnly = result.rows.filter(r => r.data_sources === 'manual');
    if (manualOnly.length > 0) {
      console.log('========================================');
      console.log('PLAYERS WITHOUT EXTERNAL DATA SOURCES');
      console.log('(Manually entered - may need enrichment)');
      console.log('========================================\n');
      
      manualOnly.forEach(row => {
        console.log(`- ${row.first_name} ${row.last_name}`);
        console.log(`  Teams: ${row.teams || 'None'}`);
        console.log(`  ID: ${row.id}\n`);
      });
    }
    
    // Find potential duplicates (same last name)
    console.log('========================================');
    console.log('POTENTIAL DUPLICATES (Same Last Name)');
    console.log('========================================\n');
    
    const byLastName = {};
    result.rows.forEach(row => {
      const key = row.last_name.toLowerCase();
      if (!byLastName[key]) byLastName[key] = [];
      byLastName[key].push(row);
    });
    
    const duplicates = Object.values(byLastName).filter(arr => arr.length > 1);
    
    if (duplicates.length > 0) {
      duplicates.forEach(group => {
        console.log(`${group[0].last_name}:`);
        group.forEach(row => {
          console.log(`  - ${row.first_name} ${row.last_name} (${row.data_sources})`);
          console.log(`    ID: ${row.id}`);
          console.log(`    Teams: ${row.teams || 'None'}`);
        });
        console.log('');
      });
    } else {
      console.log('✅ No obvious duplicates found\n');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

// Run
console.log('🏃 Lighthouse Players Report\n');
if (ACTIVE_ONLY) {
  console.log('📋 Filtering: Active players only\n');
}

getLighthousePlayers().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
