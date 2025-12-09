#!/usr/bin/env node
/**
 * Export Audit Log to Replay SQL
 * 
 * This script reads the change_log table and generates a SQL file
 * that can replay all changes made after the initial database build.
 * 
 * Usage:
 *   node scripts/export-audit-log.js                    # Export all changes since init
 *   node scripts/export-audit-log.js --since 2025-12-01 # Export changes since date
 *   node scripts/export-audit-log.js --last 7           # Export last 7 days
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
let sinceDate = null;
let lastDays = null;

for (let i = 0; i < args.length; i++) {
    if (args[i] === '--since' && args[i + 1]) {
        sinceDate = args[i + 1];
        i++;
    } else if (args[i] === '--last' && args[i + 1]) {
        lastDays = parseInt(args[i + 1]);
        i++;
    } else if (args[i] === '--help' || args[i] === '-h') {
        console.log(`
Export Audit Log to Replay SQL

Usage:
  node scripts/export-audit-log.js                    Export all changes since init
  node scripts/export-audit-log.js --since 2025-12-01 Export changes since date
  node scripts/export-audit-log.js --last 7           Export last 7 days
  node scripts/export-audit-log.js --help             Show this help

Output: database/data/98-audit-replay.sql
        `);
        process.exit(0);
    }
}

// Database configuration
const dbConfig = {
    user: process.env.DB_USER || 'footballhome_user',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'footballhome',
    password: process.env.DB_PASSWORD || 'footballhome_pass',
    port: process.env.DB_PORT || 5432,
};

const OUTPUT_FILE = path.join(__dirname, '../database/data/98-audit-replay.sql');

async function exportAuditLog() {
    const client = new Client(dbConfig);

    try {
        await client.connect();
        console.log('Connected to database...');

        // Build WHERE clause based on arguments
        let whereClause = "replay_sql IS NOT NULL AND replay_sql != ''";
        const params = [];

        if (lastDays) {
            whereClause += " AND changed_at >= NOW() - $1::INTERVAL";
            params.push(`${lastDays} days`);
        } else if (sinceDate) {
            whereClause += " AND changed_at >= $1::TIMESTAMPTZ";
            params.push(sinceDate);
        }

        // Query the change log
        const query = `
            SELECT 
                id,
                table_name,
                operation,
                changed_at,
                replay_sql,
                new_values,
                source
            FROM change_log
            WHERE ${whereClause}
            AND table_name != '_system'
            ORDER BY changed_at ASC
        `;

        console.log('Querying change log...');
        const result = await client.query(query, params);
        
        if (result.rows.length === 0) {
            console.log('No changes found to export.');
            return;
        }

        console.log(`Found ${result.rows.length} changes to export.`);

        // Build SQL file header
        let sqlContent = `-- ========================================\n`;
        sqlContent += `-- AUDIT LOG REPLAY\n`;
        sqlContent += `-- Generated: ${new Date().toISOString()}\n`;
        
        if (lastDays) {
            sqlContent += `-- Contains changes from last ${lastDays} days\n`;
        } else if (sinceDate) {
            sqlContent += `-- Contains changes since ${sinceDate}\n`;
        } else {
            sqlContent += `-- Contains ALL changes since database initialization\n`;
        }
        
        sqlContent += `-- Total changes: ${result.rows.length}\n`;
        sqlContent += `-- ========================================\n\n`;

        // Add note about idempotency
        sqlContent += `-- NOTE: These statements use ON CONFLICT or WHERE clauses\n`;
        sqlContent += `-- to make them safe to run multiple times.\n\n`;

        // Group changes by table for better organization
        const changesByTable = {};
        for (const row of result.rows) {
            if (!changesByTable[row.table_name]) {
                changesByTable[row.table_name] = [];
            }
            changesByTable[row.table_name].push(row);
        }

        // Write changes grouped by table
        for (const [tableName, changes] of Object.entries(changesByTable)) {
            sqlContent += `-- ---------------------------------------------------------\n`;
            sqlContent += `-- ${tableName.toUpperCase()} (${changes.length} changes)\n`;
            sqlContent += `-- ---------------------------------------------------------\n`;

            for (const change of changes) {
                // Add a comment with metadata
                sqlContent += `-- ${change.operation} at ${change.changed_at.toISOString()}`;
                
                // Add helpful context for user changes
                if (change.new_values) {
                    const nv = change.new_values;
                    if (nv.first_name && nv.last_name) {
                        sqlContent += ` (${nv.first_name} ${nv.last_name})`;
                    } else if (nv.jersey_number) {
                        sqlContent += ` (Jersey #${nv.jersey_number})`;
                    } else if (nv.title) {
                        sqlContent += ` (${nv.title})`;
                    }
                }
                
                sqlContent += `\n${change.replay_sql}\n\n`;
            }

            sqlContent += `\n`;
        }

        // Add summary at the end
        sqlContent += `-- ========================================\n`;
        sqlContent += `-- SUMMARY\n`;
        sqlContent += `-- ========================================\n`;
        for (const [tableName, changes] of Object.entries(changesByTable)) {
            const inserts = changes.filter(c => c.operation === 'INSERT').length;
            const updates = changes.filter(c => c.operation === 'UPDATE').length;
            const deletes = changes.filter(c => c.operation === 'DELETE').length;
            
            sqlContent += `-- ${tableName}: `;
            if (inserts > 0) sqlContent += `${inserts} INSERTs `;
            if (updates > 0) sqlContent += `${updates} UPDATEs `;
            if (deletes > 0) sqlContent += `${deletes} DELETEs`;
            sqlContent += `\n`;
        }

        // Write to file
        fs.writeFileSync(OUTPUT_FILE, sqlContent);
        
        console.log(`\n✅ Successfully exported audit log to ${OUTPUT_FILE}`);
        console.log(`   Total statements: ${result.rows.length}`);
        console.log(`   Tables affected: ${Object.keys(changesByTable).length}`);
        console.log(`   File size: ${(fs.statSync(OUTPUT_FILE).size / 1024).toFixed(1)} KB`);

    } catch (err) {
        console.error('Error exporting audit log:', err);
        process.exit(1);
    } finally {
        await client.end();
    }
}

exportAuditLog();
