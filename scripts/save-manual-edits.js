const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Database configuration
const dbConfig = {
    user: process.env.DB_USER || 'footballhome_user',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'footballhome',
    password: process.env.DB_PASSWORD || 'footballhome_pass',
    port: process.env.DB_PORT || 5432,
};

const OUTPUT_FILE = path.join(__dirname, '../database/data/99-manual-roster-edits.sql');

async function saveManualEdits() {
    const client = new Client(dbConfig);

    try {
        await client.connect();
        console.log('Connected to database...');

        let sqlContent = `-- ========================================\n`;
        sqlContent += `-- MANUAL ROSTER EDITS SNAPSHOT\n`;
        sqlContent += `-- Generated: ${new Date().toISOString()}\n`;
        sqlContent += `-- This file applies manual edits (names, status, reg numbers) on top of scraped data\n`;
        sqlContent += `-- ========================================\n\n`;

        // ---------------------------------------------------------
        // 1. USERS (Names)
        // ---------------------------------------------------------
        console.log('Backing up Users (Names)...');
        
        // Strategy: We will dump updates for ALL users found in team_players or division_players
        // This ensures that if we fixed a typo, it persists.
        const allUsersRes = await client.query(`
            SELECT DISTINCT u.id, u.first_name, u.last_name
            FROM users u
            JOIN players p ON u.id = p.id
            WHERE EXISTS (SELECT 1 FROM team_players tp WHERE tp.player_id = p.id)
               OR EXISTS (SELECT 1 FROM division_players dp WHERE dp.player_id = p.id)
        `);

        sqlContent += `-- ---------------------------------------------------------\n`;
        sqlContent += `-- USERS (Name Corrections)\n`;
        sqlContent += `-- ---------------------------------------------------------\n`;
        
        for (const row of allUsersRes.rows) {
            const safeFirstName = row.first_name.replace(/'/g, "''");
            const safeLastName = row.last_name.replace(/'/g, "''");
            sqlContent += `UPDATE users SET first_name = '${safeFirstName}', last_name = '${safeLastName}' WHERE id = '${row.id}';\n`;
        }
        sqlContent += `\n`;

        // ---------------------------------------------------------
        // 2. TEAM PLAYERS (Roster Status, Jersey, Captain)
        // ---------------------------------------------------------
        console.log('Backing up Team Rosters...');
        const teamPlayersRes = await client.query(`
            SELECT 
                tp.team_id,
                tp.player_id,
                tp.jersey_number,
                tp.position_id,
                tp.is_captain,
                tp.is_vice_captain,
                tp.roster_status_id,
                tp.is_active
            FROM team_players tp
        `);

        sqlContent += `-- ---------------------------------------------------------\n`;
        sqlContent += `-- TEAM ROSTERS (Jersey, Status, Captaincy)\n`;
        sqlContent += `-- ---------------------------------------------------------\n`;

        for (const row of teamPlayersRes.rows) {
            const jersey = row.jersey_number !== null ? row.jersey_number : 'NULL';
            const posId = row.position_id ? `'${row.position_id}'` : 'NULL';
            const statusId = row.roster_status_id ? row.roster_status_id : 1;
            
            sqlContent += `INSERT INTO team_players (team_id, player_id, jersey_number, position_id, is_captain, is_vice_captain, roster_status_id, is_active) \n`;
            sqlContent += `VALUES ('${row.team_id}', '${row.player_id}', ${jersey}, ${posId}, ${row.is_captain}, ${row.is_vice_captain}, ${statusId}, ${row.is_active}) \n`;
            sqlContent += `ON CONFLICT (team_id, player_id) DO UPDATE SET \n`;
            sqlContent += `    jersey_number = EXCLUDED.jersey_number, \n`;
            sqlContent += `    position_id = EXCLUDED.position_id, \n`;
            sqlContent += `    is_captain = EXCLUDED.is_captain, \n`;
            sqlContent += `    is_vice_captain = EXCLUDED.is_vice_captain, \n`;
            sqlContent += `    roster_status_id = EXCLUDED.roster_status_id, \n`;
            sqlContent += `    is_active = EXCLUDED.is_active;\n`;
        }
        sqlContent += `\n`;

        // ---------------------------------------------------------
        // 3. DIVISION PLAYERS (Status, Reg Number)
        // ---------------------------------------------------------
        console.log('Backing up Division Rosters...');
        const divPlayersRes = await client.query(`
            SELECT 
                dp.division_id,
                dp.player_id,
                dp.status,
                dp.registration_number
            FROM division_players dp
        `);

        sqlContent += `-- ---------------------------------------------------------\n`;
        sqlContent += `-- DIVISION ROSTERS (Status, Reg Number)\n`;
        sqlContent += `-- ---------------------------------------------------------\n`;

        for (const row of divPlayersRes.rows) {
            const safeRegNum = row.registration_number ? `'${row.registration_number}'` : 'NULL';
            
            sqlContent += `INSERT INTO division_players (division_id, player_id, status, registration_number) \n`;
            sqlContent += `VALUES ('${row.division_id}', '${row.player_id}', '${row.status}', ${safeRegNum}) \n`;
            sqlContent += `ON CONFLICT (division_id, player_id) DO UPDATE SET \n`;
            sqlContent += `    status = EXCLUDED.status, \n`;
            sqlContent += `    registration_number = EXCLUDED.registration_number;\n`;
        }

        fs.writeFileSync(OUTPUT_FILE, sqlContent);
        console.log(`✅ Successfully saved FULL manual edits backup to ${OUTPUT_FILE}`);

    } catch (err) {
        console.error('Error saving manual edits:', err);
    } finally {
        await client.end();
    }
}

saveManualEdits();
