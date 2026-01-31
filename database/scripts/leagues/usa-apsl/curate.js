#!/usr/bin/env node
/**
 * APSL Curation Entry Point
 */
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const ApslCurator = require('./ApslCurator');

async function main() {
  const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'footballhome',
    user: 'footballhome_user',
    password: 'footballhome_password'
  });

  try {
    const curator = new ApslCurator(pool);
    await curator.curate();
    
    const sql = curator.generateSqlFile('00001', 'APSL');
    const outputPath = path.join(__dirname, '../../../data/900.00001-curation-usa-apsl.sql');
    
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ Created: 900.00001-curation-usa-apsl.sql`);
  } catch (error) {
    console.error('Curation failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
