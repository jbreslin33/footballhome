#!/usr/bin/env node

/**
 * Cleanup Orphan Clubs Script
 * 
 * Problem: Files 043-clubs-from-teams.sql and 044a-standalone-team-clubs.sql
 * created clubs from every CSL team name including variants (II, III, Legends, etc.)
 * when they should only create clubs for base teams.
 * 
 * This script:
 * 1. Identifies clubs with 0 teams (orphan clubs)
 * 2. Reports what will be deleted
 * 3. Deletes orphan clubs (safe since they have no teams/foreign keys)
 * 
 * Usage:
 *   node database/scripts/cleanup-orphan-clubs.js --dry-run  # Preview only
 *   node database/scripts/cleanup-orphan-clubs.js --execute  # Actually delete
 */

const { Client } = require('pg');

const DB_CONFIG = {
  host: 'localhost',
  port: 5433,
  database: 'footballhome',
  user: 'footballhome_user',
  password: process.env.DB_PASSWORD || ''
};

async function findOrphanClubs(client) {
  const query = `
    SELECT 
      c.id,
      c.name as club_name,
      c.organization_id,
      o.name as organization_name,
      COUNT(t.id) as team_count
    FROM clubs c
    LEFT JOIN teams t ON t.club_id = c.id
    LEFT JOIN organizations o ON o.id = c.organization_id
    GROUP BY c.id, c.name, c.organization_id, o.name
    HAVING COUNT(t.id) = 0
    ORDER BY c.name;
  `;
  
  const result = await client.query(query);
  return result.rows;
}

async function deleteOrphanClubs(client, clubIds) {
  const query = `
    DELETE FROM clubs 
    WHERE id = ANY($1)
    RETURNING id, name;
  `;
  
  const result = await client.query(query, [clubIds]);
  return result.rows;
}

async function main() {
  const args = process.argv.slice(2);
  const isDryRun = args.includes('--dry-run') || !args.includes('--execute');
  
  const client = new Client(DB_CONFIG);
  
  try {
    await client.connect();
    console.log('✓ Connected to database');
    
    // Find orphan clubs
    const orphanClubs = await findOrphanClubs(client);
    
    console.log(`\n📊 Found ${orphanClubs.length} clubs with 0 teams:\n`);
    
    if (orphanClubs.length === 0) {
      console.log('✓ No orphan clubs found! Database is clean.');
      return;
    }
    
    // Group by pattern for reporting
    const patterns = {
      'II': [],
      'III': [],
      'IV': [],
      'Legends': [],
      'Old Boys': [],
      'Young Boys': [],
      'Hudson': [],
      'Green': [],
      'Orange': [],
      'Red': [],
      '1999': [],
      'Other': []
    };
    
    orphanClubs.forEach(club => {
      const name = club.club_name;
      if (name.includes(' II')) patterns['II'].push(club);
      else if (name.includes(' III')) patterns['III'].push(club);
      else if (name.includes(' IV')) patterns['IV'].push(club);
      else if (name.includes('Legends')) patterns['Legends'].push(club);
      else if (name.includes('Old Boys')) patterns['Old Boys'].push(club);
      else if (name.includes('Young Boys')) patterns['Young Boys'].push(club);
      else if (name.includes('Hudson')) patterns['Hudson'].push(club);
      else if (name.includes('Green')) patterns['Green'].push(club);
      else if (name.includes('Orange')) patterns['Orange'].push(club);
      else if (name.includes('Red')) patterns['Red'].push(club);
      else if (name.includes('1999')) patterns['1999'].push(club);
      else patterns['Other'].push(club);
    });
    
    // Display grouped results
    for (const [pattern, clubs] of Object.entries(patterns)) {
      if (clubs.length > 0) {
        console.log(`\n${pattern} Variants (${clubs.length}):`);
        clubs.forEach(club => {
          console.log(`  • [${club.id}] ${club.club_name}`);
        });
      }
    }
    
    if (isDryRun) {
      console.log('\n⚠️  DRY RUN MODE - No changes made');
      console.log('\nTo actually delete these clubs, run:');
      console.log('  node database/scripts/cleanup-orphan-clubs.js --execute');
    } else {
      console.log('\n⚠️  EXECUTING DELETION...');
      
      const clubIds = orphanClubs.map(c => c.id);
      const deleted = await deleteOrphanClubs(client, clubIds);
      
      console.log(`\n✓ Deleted ${deleted.length} orphan clubs`);
      
      // Verify cleanup
      const remaining = await findOrphanClubs(client);
      if (remaining.length === 0) {
        console.log('✓ All orphan clubs cleaned up successfully!');
      } else {
        console.log(`⚠️  Warning: ${remaining.length} orphan clubs still remain`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

// Run the script
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}
