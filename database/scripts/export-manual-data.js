const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Configuration
const DB_CONFIG = {
  host: 'localhost',
  port: 5432,
  database: 'footballhome',
  user: 'footballhome_user',
  password: 'footballhome_pass'
};

const OUTPUT_DIR = path.join(__dirname, '../data');
const ROSTER_FILE = path.join(OUTPUT_DIR, '23m-team-players-manual.sql');
const LINKS_FILE = path.join(OUTPUT_DIR, '80m-manual-links.sql');

async function exportManualData() {
  const client = new Client(DB_CONFIG);
  
  try {
    await client.connect();
    console.log('Connected to database...');

    // 1. Export Manual Links (Identity -> User)
    // We look for identities that are linked to a user
    console.log('Exporting manual identity links...');
    const linksResult = await client.query(`
      SELECT 
        uei.external_id, 
        uei.provider_id, 
        u.email,
        u.first_name,
        u.last_name
      FROM user_external_identities uei
      JOIN users u ON uei.user_id = u.id
      WHERE uei.user_id IS NOT NULL
      ORDER BY u.last_name, u.first_name
    `);

    let linksSql = '-- Manual Identity Links (Exported)\n';
    linksSql += '-- Links external identities to specific users\n\n';

    for (const row of linksResult.rows) {
      // We use a DO block or specific UPDATE to be safe
      linksSql += `-- Link ${row.first_name} ${row.last_name} to ${row.external_id}\n`;
      linksSql += `UPDATE user_external_identities\n`;
      linksSql += `SET user_id = (SELECT id FROM users WHERE email = '${row.email}')\n`;
      linksSql += `WHERE external_id = '${row.external_id}' AND provider_id = '${row.provider_id}';\n\n`;
    }

    fs.writeFileSync(LINKS_FILE, linksSql);
    console.log(`Saved ${linksResult.rows.length} links to ${path.basename(LINKS_FILE)}`);

    // 2. Export Manual Roster Entries
    // This is trickier - how do we know which are manual?
    // For now, we'll export ALL team_division_players for specific "Manual" teams if needed,
    // or we can rely on the fact that scraped data is re-imported anyway.
    // A better approach for the future: add a 'source' column to team_division_players.
    
    // For this proof of concept, we'll skip overwriting 23m unless we have a way to identify manual entries.
    console.log('Skipping roster export (requires schema update to track source)');

  } catch (err) {
    console.error('Error exporting data:', err);
  } finally {
    await client.end();
  }
}

exportManualData();
