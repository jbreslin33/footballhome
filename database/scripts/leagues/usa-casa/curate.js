#!/usr/bin/env node
/**
 * CASA Curation Entry Point
 */
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const CasaCurator = require('./CasaCurator');

async function main() {
  const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'footballhome',
    user: 'footballhome_user',
    password: 'footballhome_password'
  });

  try {
    const curator = new CasaCurator(pool);
    await curator.curate();
    
    const sql = curator.generateSqlFile('00002', 'CASA');
    const outputPath = path.join(__dirname, '../../../data/900.00002-curation-usa-casa.sql');
    
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ Created: 900.00002-curation-usa-casa.sql`);
  } catch (error) {
    console.error('Curation failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
