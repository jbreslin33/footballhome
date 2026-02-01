#!/usr/bin/env node

/**
 * CSL SQL Generator
 * 
 * Reads cached HTML files and generates SQL (no database writes).
 * Creates organizations, clubs, and teams from team names.
 * 
 * Workflow: HTML → SQL files → Manual curation → Load to DB
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const BaseGenerator = require('../BaseGenerator');

class CslSqlGenerator extends BaseGenerator {
  constructor() {
    super('CSL', 3, '00003', 10000, 10000, 10000);
    this.organizations = new Map();
    this.clubs = new Map();
    this.teams = [];
  }

  /**
   * Main workflow
   */
  async generate() {
    console.log('\n📄 Generating CSL SQL from HTML...');
    
    // Read standings HTML
    const standingsHtml = this.readStandingsHtml();
    
    // Parse teams
    this.parseStandingsPage(standingsHtml);
    
    console.log(`   Found ${this.teams.length} teams`);
    
    // Group teams by club (deduplicates clubs with multiple teams)
    const teamGroups = this.groupTeamsByClub(this.teams);
    this.clubs = this.extractClubsFromGroups(teamGroups);
    this.organizations = this.extractOrganizationsFromClubs(this.clubs);
    
    console.log(`   Extracted ${this.clubs.size} unique clubs (grouped from teams)`);
    console.log(`   Sample clubs: ${Array.from(this.clubs.keys()).slice(0, 5).join(', ')}`);
    console.log(`   Extracted ${this.organizations.size} unique organizations`);
    
    // Generate SQL files
    this.writeOrganizationsSql();
    this.writeClubsSql();
    this.writeTeamsSql();
    
    console.log('✓ SQL generation complete\n');
  }

  /**
   * Read cached standings HTML
   */
  readStandingsHtml() {
    const htmlDir = path.join(__dirname, '../../../scraped-html/csl');
    const files = fs.readdirSync(htmlDir).filter(f => f.startsWith('tables-'));
    
    if (files.length === 0) {
      throw new Error('No standings HTML found. Run ./scrape.sh first.');
    }
    
    const htmlPath = path.join(htmlDir, files[0]);
    console.log(`   Reading: ${htmlPath}`);
    return fs.readFileSync(htmlPath, 'utf-8');
  }

  /**
   * Parse standings page to extract teams
   */
  parseStandingsPage(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Find all div elements that contain division names
    const allDivs = document.querySelectorAll('div');
    
    for (const div of allDivs) {
      const text = div.textContent.trim();
      
      // Match division headers like "2025/2026 - Division 1"
      const divisionMatch = text.match(/^(\d{4}\/\d{4})\s*-\s*(.+)$/);
      if (!divisionMatch) continue;
      
      const divisionName = divisionMatch[2]; // Just the division name without season
      
      // Find the table that follows this div
      let current = div;
      let table = null;
      let iterations = 0;
      
      while (current && !table && iterations < 100) {
        iterations++;
        current = current.nextElementSibling;
        if (current && current.tagName === 'TABLE') {
          table = current;
        }
        if (!current && div.parentElement) {
          current = div.parentElement.nextElementSibling;
          if (current) {
            table = current.querySelector('table');
          }
        }
      }
      
      if (!table) continue;
      
      // Parse teams from table (no tbody in CSL HTML)
      const rows = table.querySelectorAll('tr');
      rows.forEach((row) => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 10) return; // Skip header rows
        
        // Team name is in second column (cells[1])
        const teamCell = cells[1];
        const teamName = teamCell.textContent.trim();
        const teamLink = teamCell.querySelector('a[href*="/CSL/Team/"]');
        const teamHref = teamLink?.getAttribute('href') || '';
        const externalId = teamHref.match(/\/CSL\/Team\/(\d+)/)?.[1];
        
        if (teamName && externalId) {
          this.addTeam(teamName, externalId, divisionName);
        }
      });
    }
  }

  /**
   * Add team (clubs/orgs will be extracted later via grouping)
   */
  addTeam(teamName, externalId, divisionName) {
    this.teams.push({
      name: teamName,
      externalId: externalId,
      divisionName: divisionName,
      sourceSystemId: this.sourceSystemId
    });
  }

  /**
   * Extract club name from team name
   */
  getClubName(teamName) {
    return teamName
      .replace(/\s+(II|III|IV|V|2|3|4|5)$/i, '')
      .replace(/\s+Reserve$/i, '')
      .replace(/\s+Legends$/i, '')
      .replace(/\s+Old Boys$/i, '')
      .replace(/\s+Masters$/i, '')
      .replace(/\s+Bhoys$/i, '')
      .replace(/\s+Lower East$/i, '')
      .replace(/\s+Hudson$/i, '')
      .replace(/\s+OG'S$/i, '')
      .replace(/\s+Dawgz$/i, '')
      .trim();
  }

  /**
   * Write organizations SQL
   */
  writeOrganizationsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - CSL
-- Total Records: ${this.organizations.size}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.orgIdBase;
    for (const [name, org] of this.organizations) {
      sql += `INSERT INTO organizations (id, name) VALUES (${id}, '${this.escapeSql(name)}') ON CONFLICT (id) DO NOTHING;\n`;
      org.id = id; // Store for club references
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `100.${this.leagueId}-organizations-usa-csl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write clubs SQL
   */
  writeClubsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CSL
-- Total Records: ${this.clubs.size}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.clubIdBase;
    for (const [name, club] of this.clubs) {
      const org = this.organizations.get(club.organizationName);
      sql += `INSERT INTO clubs (id, name, organization_id) VALUES (${id}, '${this.escapeSql(name)}', ${org.id}) ON CONFLICT (id) DO NOTHING;\n`;
      club.id = id; // Store for team references
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `101.${this.leagueId}-clubs-usa-csl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write teams SQL
   */
  writeTeamsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CSL
-- Total Records: ${this.teams.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.teamIdBase;
    for (const team of this.teams) {
      const club = this.clubs.get(team.clubName);
      if (!club) {
        console.error(`ERROR: Club not found for team "${team.name}", clubName="${team.clubName}"`);
        console.error(`Available clubs: ${Array.from(this.clubs.keys()).slice(0,5).join(', ')}...`);
        throw new Error('Club lookup failed');
      }
      sql += `INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (${id}, '${this.escapeSql(team.name)}', '${team.externalId}', ${club.id}, ${team.sourceSystemId}) ON CONFLICT (source_system_id, external_id) DO NOTHING;\n`;
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `102.${this.leagueId}-teams-usa-csl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Escape SQL string
   */
  escapeSql(str) {
    return str.replace(/'/g, "''");
  }
}

// CLI execution
if (require.main === module) {
  const generator = new CslSqlGenerator();
  generator.generate()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('❌ Error:', err);
      process.exit(1);
    });
}

module.exports = CslSqlGenerator;
