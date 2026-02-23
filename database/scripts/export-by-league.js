#!/usr/bin/env node

/**
 * Export all entities by league using Dewey Decimal naming
 * 
 * Generates SQL files:
 * - 042.X-teams-{country}-{league}.sql
 * - 043.X-organizations-{country}-{league}.sql
 * - 044.X-clubs-{country}-{league}.sql
 * - 045.X-players-{country}-{league}.sql
 * - 046.X-matches-{country}-{league}.sql
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const LEAGUE_CONFIGS = [
  { source_system_id: 1, number: '042.1', slug: 'apsl', name: 'APSL', country: 'USA' },
  { source_system_id: 2, number: '042.2', slug: 'casa', name: 'CASA', country: 'USA' },
  { source_system_id: 3, number: '042.3', slug: 'csl', name: 'CSL', country: 'USA' }
];

async function exportByLeague() {
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

    for (const config of LEAGUE_CONFIGS) {
      console.log(`========================================`);
      console.log(`Exporting: ${config.name} (${config.country})`);
      console.log(`========================================\n`);

      await exportTeams(client, config);
      await exportOrganizations(client, config);
      await exportClubs(client, config);
      // Skip players - they're seasonal rosters tied to divisions, not source_system_id
      // await exportPlayers(client, config);
      // Skip matches for now - can add later
      // await exportMatches(client, config);
      
      console.log('');
    }

    await client.end();
    console.log('✓ All exports completed successfully\n');

  } catch (error) {
    console.error('ERROR:', error.message);
    process.exit(1);
  }
}

async function exportTeams(client, config) {
  const filename = `${config.number}-teams-${config.slug}.sql`;
  
  const result = await client.query(`
    SELECT id, club_id, name, city, logo_url, source_system_id, external_id
    FROM teams
    WHERE source_system_id = $1
    ORDER BY id
  `, [config.source_system_id]);

  const teams = result.rows;
  
  let sql = generateHeader(filename, `${config.country} - ${config.name} Teams`, teams.length);
  sql += `-- Note: club_id may be NULL initially. 044-auto-create-clubs.sql will create missing clubs.\n\n`;

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
  const filename = `${config.number.replace('042', '043')}-organizations-${config.slug}.sql`;
  
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
  const filename = `${config.number.replace('042', '044')}-clubs-${config.slug}.sql`;
  
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

async function exportPlayers(client, config) {
  const filename = `${config.number.replace('042', '045')}-players-${config.slug}.sql`;
  
  // Get players on teams in this league
  const result = await client.query(`
    SELECT DISTINCT p.id, p.person_id, p.height_cm, p.nationality, 
           p.photo_url, p.source_system_id, p.external_id
    FROM players p
    JOIN team_players tp ON tp.player_id = p.id
    JOIN teams t ON t.id = tp.team_id
    WHERE t.source_system_id = $1
    ORDER BY p.id
  `, [config.source_system_id]);

  const players = result.rows;
  
  let sql = generateHeader(filename, `${config.country} - ${config.name} Players`, players.length);

  if (players.length > 0) {
    sql += `INSERT INTO players (id, person_id, height_cm, nationality, photo_url, source_system_id, external_id) VALUES\n`;
    players.forEach((p, i) => {
      const isLast = i === players.length - 1;
      sql += `  (${p.id}, ${p.person_id}, ${p.height_cm || 'NULL'}, ${sqlString(p.nationality)}, ${sqlString(p.photo_url)}, ${p.source_system_id || 'NULL'}, ${sqlString(p.external_id)})`;
      sql += isLast ? ';\n' : ',\n';
    });
  }

  writeFile(filename, sql);
  console.log(`✓ ${filename} (${players.length} players)`);
}

async function exportMatches(client, config) {
  const filename = `${config.number.replace('042', '046')}-matches-${config.slug}.sql`;
  
  // Get matches for teams in this league
  const result = await client.query(`
    SELECT DISTINCT m.id, m.home_team_id, m.away_team_id, m.venue_id, m.match_date,
           m.match_time, m.home_score, m.away_score, m.status, m.division_id,
           m.source_system_id, m.external_id
    FROM matches m
    JOIN teams ht ON ht.id = m.home_team_id
    WHERE ht.source_system_id = $1
    ORDER BY m.match_date DESC, m.id
  `, [config.source_system_id]);

  const matches = result.rows;
  
  let sql = generateHeader(filename, `${config.country} - ${config.name} Matches`, matches.length);
  sql += `-- Note: This is initial schedule data. Use update.sh to refresh scores/standings.\n\n`;

  if (matches.length > 0) {
    sql += `INSERT INTO matches (id, home_team_id, away_team_id, venue_id, match_date, match_time, home_score, away_score, status, division_id, source_system_id, external_id) VALUES\n`;
    matches.forEach((m, i) => {
      const isLast = i === matches.length - 1;
      const matchDate = m.match_date ? `'${m.match_date.toISOString().split('T')[0]}'` : 'NULL';
      sql += `  (${m.id}, ${m.home_team_id}, ${m.away_team_id}, ${m.venue_id || 'NULL'}, ${matchDate}, ${sqlString(m.match_time)}, ${m.home_score || 'NULL'}, ${m.away_score || 'NULL'}, ${sqlString(m.status)}, ${m.division_id || 'NULL'}, ${m.source_system_id || 'NULL'}, ${sqlString(m.external_id)})`;
      sql += isLast ? ';\n' : ',\n';
    });
  }

  writeFile(filename, sql);
  console.log(`✓ ${filename} (${matches.length} matches)`);
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

exportByLeague();
