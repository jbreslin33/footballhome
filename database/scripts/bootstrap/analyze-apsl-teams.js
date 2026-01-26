#!/usr/bin/env node

/**
 * Analyze APSL roster HTML files to extract team information
 * Identifies teams that need to be added to database for Fall 2025 rosters
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.PGHOST || 'localhost',
    port: process.env.PGPORT || 5432,
    database: process.env.PGDATABASE || 'footballhome',
    user: process.env.PGUSER || 'footballhome_user',
    password: process.env.PGPASSWORD || 'footballhome_pass'
});

const SCRAPED_HTML_DIR = path.join(__dirname, '../../scraped-html/apsl');
const APSL_SOURCE_SYSTEM_ID = 1;
const APSL_SEASON_NAME = '2024/2025';  // Fall 2025 = 2024/2025 season

async function analyzeTeams() {
    const client = await pool.connect();
    
    try {
        // Get all roster HTML files (apsl-team-XXXXX-hash.html pattern)
        const files = fs.readdirSync(SCRAPED_HTML_DIR)
            .filter(f => f.match(/^apsl-team-\d+-[a-f0-9]+\.html$/))
            .sort();
        
        console.log(`Found ${files.length} roster HTML files`);
        
        // Extract team info from each file
        const teamsFromHtml = new Map();
        
        for (const filename of files) {
            const match = filename.match(/^apsl-team-(\d+)-/);
            if (!match) continue;
            
            const teamId = match[1];
            
            if (!teamsFromHtml.has(teamId)) {
                const filePath = path.join(SCRAPED_HTML_DIR, filename);
                const html = fs.readFileSync(filePath, 'utf-8');
                
                // Skip empty files
                if (html.length < 100) {
                    console.log(`  Skipping empty file: ${filename}`);
                    continue;
                }
                
                const dom = new JSDOM(html);
                const doc = dom.window.document;
                
                // Extract team name from page (try multiple selectors)
                let teamName = null;
                
                // Try h1 > a (most reliable for APSL team pages)
                const h1Link = doc.querySelector('h1 > a[href*="/Team/"]');
                if (h1Link) {
                    teamName = h1Link.textContent.trim();
                }
                
                // Try any h1
                if (!teamName) {
                    const h1 = doc.querySelector('h1');
                    if (h1) {
                        // Get first text node, ignore <small> tags
                        const link = h1.querySelector('a');
                        if (link) {
                            teamName = link.textContent.trim();
                        } else {
                            teamName = h1.textContent.split('\n')[0].trim();
                        }
                    }
                }
                
                // Try title tag
                if (!teamName && titleEl && titleEl.textContent.includes('Team Profile')) {
                    teamName = titleEl.textContent.replace(/\s*-\s*Team Profile.*/, '').trim();
                }
                
                // Fallback
                if (!teamName || teamName.includes('American Premier')) {
                    teamName = `APSL Team ${teamId}`;
                }
                
                teamsFromHtml.set(teamId, {
                    external_id: teamId,
                    name: teamName.replace(/\s+/g, ' ')
                });
            }
        }
        
        console.log(`\nFound ${teamsFromHtml.size} unique teams in HTML files`);
        
        // Check which teams exist in database
        const existingTeamsResult = await client.query(
            'SELECT external_id, name FROM teams WHERE source_system_id = $1',
            [APSL_SOURCE_SYSTEM_ID]
        );
        
        const existingTeams = new Set(existingTeamsResult.rows.map(r => r.external_id));
        console.log(`${existingTeamsResult.rows.length} APSL teams exist in database`);
        
        // Find missing teams
        const missingTeams = [];
        for (const [teamId, teamInfo] of teamsFromHtml) {
            if (!existingTeams.has(teamId)) {
                missingTeams.push(teamInfo);
            }
        }
        
        console.log(`\n${missingTeams.length} teams need to be added to database`);
        
        if (missingTeams.length > 0) {
            console.log('\nMissing teams:');
            missingTeams.slice(0, 20).forEach(t => {
                console.log(`  ${t.external_id}: ${t.name}`);
            });
            
            if (missingTeams.length > 20) {
                console.log(`  ... and ${missingTeams.length - 20} more`);
            }
            
            // Generate SQL INSERT statements
            const sqlStatements = missingTeams.map(t => {
                const escapedName = t.name.replace(/'/g, "''");
                return `INSERT INTO teams (name, source_system_id, external_id) VALUES ('${escapedName}', ${APSL_SOURCE_SYSTEM_ID}, '${t.external_id}');`;
            });
            
            const sqlFile = path.join(__dirname, '../../data/030-apsl-teams-fall-2025.sql');
            const sqlContent = `-- APSL Fall 2025 Teams (from roster HTML analysis)
-- Generated: ${new Date().toISOString()}
-- Source: database/scripts/bootstrap/analyze-apsl-teams.js

${sqlStatements.join('\n')}
`;
            
            fs.writeFileSync(sqlFile, sqlContent);
            console.log(`\nGenerated SQL file: ${sqlFile}`);
        }
        
        // Summary
        console.log('\n=== SUMMARY ===');
        console.log(`Total roster files: ${files.length}`);
        console.log(`Unique teams in HTML: ${teamsFromHtml.size}`);
        console.log(`Teams in database: ${existingTeamsResult.rows.length}`);
        console.log(`Teams to add: ${missingTeams.length}`);
        
    } finally {
        client.release();
        await pool.end();
    }
}

analyzeTeams().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
