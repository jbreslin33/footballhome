#!/usr/bin/env node
/**
 * CSL Curation Entry Point
 */
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const CslCurator = require('./CslCurator');

async function main() {
  const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'footballhome',
    user: 'footballhome_user',
    password: 'footballhome_password'
  });

  try {
    const curator = new CslCurator(pool);
    await curator.curate();
    
    const sql = curator.generateSqlFile('00003', 'CSL');
    const outputPath = path.join(__dirname, '../../../data/900.00003-curation-usa-csl.sql');
    
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ Created: 900.00003-curation-usa-csl.sql`);
  } catch (error) {
    console.error('Curation failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
