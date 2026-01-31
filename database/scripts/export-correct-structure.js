#!/usr/bin/env node

/**
 * Export with correct structure:
 * - Teams BY league (042.X)
 * - Organizations GLOBAL (043)
 * - Clubs GLOBAL (044)
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const LEAGUE_CONFIGS = [
  { source_system_id: 1, leagueId: '00001', slug: 'usa-apsl', name: 'APSL', country: 'USA' },
  { source_system_id: 2, leagueId: '00002', slug: 'usa-casa', name: 'CASA', country: 'USA' },
  { source_system_id: 3, leagueId: '00003', slug: 'usa-csl', name: 'CSL', country: 'USA' }
];

async function exportAll() {
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASSWORD || 'footballhome_pass'
  });

  try {
    await client.connect();
    console.log('Connected to database\n');

    // Export each league as a package: orgs, clubs, teams
    for (const config of LEAGUE_CONFIGS) {
      console.log(`Exporting league: ${config.name} (${config.slug})`);
      await exportOrganizations(client, config);
      await exportClubs(client, config);
      await exportTeams(client, config);
      console.log('');
    }

    await client.end();
    console.log('\n✓ All exports completed successfully\n');

  } catch (error) {
    console.error('ERROR:', error.message);
    process.exit(1);
  }
}

async function exportTeams(client, config) {
  const filename = `102.${config.leagueId}-teams-${config.slug}.sql`;
  
  const result = await client.query(`
    SELECT id, club_id, name, city, logo_url, source_system_id, external_id
    FROM teams
    WHERE source_system_id = $1
    ORDER BY id
  `, [config.source_system_id]);

  const teams = result.rows;
  
  let sql = generateHeader(filename, `${config.country} - ${config.name} Teams`, teams.length);
  sql += `-- Note: club_id may reference clubs created in 044-clubs.sql\n\n`;

  if (teams.length > 0) {
    sql += `INSERT INTO teams (id, club_id, name, city, logo_url, source_system_id, external_id) VALUES\n`;
    teams.forEach((t, i) => {
      const isLast = i === teams.length - 1;
      sql += `  (${t.id}, ${t.club_id || 'NULL'}, ${sqlString(t.name)}, ${sqlString(t.city)}, ${sqlString(t.logo_url)}, ${t.source_system_id}, ${sqlString(t.external_id)})`;
      sql += isLast ? ';\n' : ',\n';
    });
  }

  writeFile(filename, sql);
  console.log(`✓ ${filename} (${teams.length} teams)`);
}

async function exportOrganizations(client, config) {
  const filename = `100.${config.leagueId}-organizations-${config.slug}.sql`;
  
  // Get organizations that own clubs that have teams in this league
  const result = await client.query(`
    SELECT DISTINCT o.id, o.name, o.short_name, o.description, o.website_url, 
           o.logo_url, o.is_active
    FROM organizations o
    JOIN clubs c ON c.organization_id = o.id
    JOIN teams t ON t.club_id = c.id
    WHERE t.source_system_id = $1
    ORDER BY o.id
  `, [config.source_system_id]);

  const orgs = result.rows;
  
  let sql = generateHeader(filename, `${config.country} - ${config.name} Organizations`, orgs.length);
  sql += `-- Note: Duplicates will be merged by 900-cross-league-curation.sql\n\n`;

  if (orgs.length > 0) {
    sql += `INSERT INTO organizations (id, name, short_name, description, website_url, logo_url, is_active) VALUES\n`;
    orgs.forEach((o, i) => {
      const isLast = i === orgs.length - 1;
      sql += `  (${o.id}, ${sqlString(o.name)}, ${sqlString(o.short_name)}, ${sqlString(o.description)}, ${sqlString(o.website_url)}, ${sqlString(o.logo_url)}, ${o.is_active})`;
      sql += isLast ? ';\n' : ',\n';
    });
  }

  writeFile(filename, sql);
  console.log(`✓ ${filename} (${orgs.length} organizations)`);
}

async function exportClubs(client, config) {
  const filename = `101.${config.leagueId}-clubs-${config.slug}.sql`;
  // Get clubs that have teams in this league
  const result = await client.query(`
    SELECT DISTINCT c.id, c.organization_id, c.name, c.sport_id,
           c.website, c.logo_url, c.is_active
    FROM clubs c
    JOIN teams t ON t.club_id = c.id
    WHERE t.source_system_id = $1
    ORDER BY c.id
  `, [config.source_system_id]);

  const clubs = result.rows;
  
  let sql = generateHeader(filename, `${config.country} - ${config.name} Clubs`, clubs.length);
  sql += `-- Note: Duplicates will be merged by 900-cross-league-curation.sqln multiple leagues\n`;
  sql += `-- After curation (051), duplicates will be merged\n\n`;

  if (clubs.length > 0) {
    sql += `INSERT INTO clubs (id, organization_id, name, sport_id, website, logo_url, is_active) VALUES\n`;
    clubs.forEach((c, i) => {
      const isLast = i === clubs.length - 1;
      sql += `  (${c.id}, ${c.organization_id || 'NULL'}, ${sqlString(c.name)}, ${c.sport_id || 1}, ${sqlString(c.website)}, ${sqlString(c.logo_url)}, ${c.is_active})`;
      sql += isLast ? ';\n' : ',\n';
    });
  }

  writeFile(filename, sql);
  console.log(`✓ ${filename} (${clubs.length} clubs)`);
}

function generateHeader(filename, title, count) {
  let sql = `-- ============================================================================\n`;
  sql += `-- ${filename}\n`;
  sql += `-- ${title}\n`;
  sql += `-- ============================================================================\n`;
  sql += `--\n`;
  sql += `-- Generated: ${new Date().toISOString()}\n`;
  sql += `-- Total Records: ${count}\n`;
  sql += `--\n\n`;
  return sql;
}

function sqlString(value) {
  if (value === null || value === undefined) return 'NULL';
  return `'${String(value).replace(/'/g, "''")}'`;
}

function writeFile(filename, content) {
  const outputPath = path.join(__dirname, '../data', filename);
  fs.writeFileSync(outputPath, content);
}

exportAll();
