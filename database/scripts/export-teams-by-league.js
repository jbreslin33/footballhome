#!/usr/bin/env node

/**
 * Export teams to separate SQL files by league (source_system)
 * Creates: 042.1-teams-apsl.sql, 042.2-teams-casa.sql, 042.3-teams-csl.sql
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const LEAGUE_CONFIGS = [
  { source_system_id: 1, filename: '042.1-teams-apsl.sql', name: 'APSL', country: 'USA' },
  { source_system_id: 2, filename: '042.2-teams-casa.sql', name: 'CASA', country: 'USA' },
  { source_system_id: 3, filename: '042.3-teams-csl.sql', name: 'CSL', country: 'USA' }
];

async function exportTeams() {
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASSWORD || 'footballhome_pass'
  });

  try {
    await client.connect();

    for (const config of LEAGUE_CONFIGS) {
      console.log(`Exporting ${config.name} teams...`);

      // Get teams for this league
      const result = await client.query(`
        SELECT 
          t.id,
          t.club_id,
          t.name,
          t.city,
          t.logo_url,
          t.source_system_id,
          t.external_id
        FROM teams t
        WHERE t.source_system_id = $1
        ORDER BY t.id
      `, [config.source_system_id]);

      const teams = result.rows;

      // Generate SQL file
      let sql = `-- ============================================================================\n`;
      sql += `-- ${config.filename}\n`;
      sql += `-- ${config.country} - ${config.name} Teams\n`;
      sql += `-- ============================================================================\n`;
      sql += `--\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n`;
      sql += `-- Total Teams: ${teams.length}\n`;
      sql += `--\n`;
      sql += `-- Each team creates its own organization and club via 044-auto-create-clubs.sql\n`;
      sql += `-- Then 045-cross-league-curation.sql merges related teams under parent clubs.\n`;
      sql += `--\n\n`;

      if (teams.length === 0) {
        sql += `-- No teams for ${config.name}\n`;
      } else {
        sql += `INSERT INTO teams (id, club_id, name, city, logo_url, source_system_id, external_id) VALUES\n`;

        teams.forEach((team, index) => {
          const isLast = index === teams.length - 1;
          const clubId = team.club_id ? team.club_id : 'NULL';
          const city = team.city ? `'${team.city.replace(/'/g, "''")}'` : 'NULL';
          const logoUrl = team.logo_url ? `'${team.logo_url.replace(/'/g, "''")}'` : 'NULL';
          const externalId = team.external_id ? `'${team.external_id}'` : 'NULL';
          
          sql += `  (${team.id}, ${clubId}, '${team.name.replace(/'/g, "''")}', ${city}, ${logoUrl}, ${team.source_system_id}, ${externalId})`;
          sql += isLast ? ';\n' : ',\n';
        });

        sql += `\n-- Reset sequence to continue from next ID\n`;
        sql += `SELECT setval('teams_id_seq', (SELECT MAX(id) FROM teams));\n`;
      }

      // Write to file
      const outputPath = path.join(__dirname, '../data', config.filename);
      fs.writeFileSync(outputPath, sql);
      console.log(`✓ Created ${config.filename} (${teams.length} teams)`);
    }

    await client.end();
    console.log('\n✓ All team files exported successfully');

  } catch (error) {
    console.error('ERROR:', error.message);
    process.exit(1);
  }
}

exportTeams();
