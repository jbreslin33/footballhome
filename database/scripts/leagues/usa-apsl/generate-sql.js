#!/usr/bin/env node

/**
 * APSL SQL Generator
 * 
 * Reads cached HTML files and generates SQL (no database writes).
 * Creates organizations, clubs, and teams from scraped data.
 * 
 * Workflow: HTML → SQL files → Manual curation → Load to DB
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const BaseGenerator = require('../BaseGenerator');

class ApslSqlGenerator extends BaseGenerator {
  constructor() {
    super('APSL', 1, '00001', 100, 100, 100);
    // Data structures inherited from BaseGenerator:
    // this.organizations, this.clubs, this.teams, this.standings, 
    // this.divisionTeams, this.divisions, this.players
  }

  /**
   * Get league folder name
   */
  getLeagueFolder() {
    return 'usa-apsl';
  }

  /**
   * Get player ID base
   */
  getPlayerIdBase() {
    return 10000; // Start player IDs at 10000
  }

  /**
   * Get active season name
   */
  getSeasonName() {
    return '2025/2026'; // APSL active season
  }

  /**
   * Get league ID
   */
  getLeagueId() {
    return 1; // APSL league_id in leagues table
  }

  /**
   * Main workflow
   */
  async generate() {
    console.log('\n📄 Generating APSL SQL from HTML...');
    
    // Read standings HTML
    const standingsHtml = this.readStandingsHtml();
    
    // Parse teams and standings
    this.parseStandingsPage(standingsHtml);
    
    console.log(`   Found ${this.teams.length} teams with standings data`);
    
    // Parse rosters from team detail pages
    this.parseTeamRosters();
    
    console.log(`   Parsed ${this.players.length} players from team rosters`);
    
    // Group teams by club (deduplicates clubs with multiple teams)
    const teamGroups = this.groupTeamsByClub(this.teams);
    this.clubs = this.extractClubsFromGroups(teamGroups);
    this.organizations = this.extractOrganizationsFromClubs(this.clubs);
    
    console.log(`   Extracted ${this.clubs.size} unique clubs (grouped from teams)`);
    console.log(`   Extracted ${this.organizations.size} unique organizations`);
    console.log(`   Extracted ${this.divisions.size} divisions`);
    console.log(`   Parsed standings: ${this.teams.length} team records`);
    
    // Generate SQL files
    this.writeOrganizationsSql();
    this.writeClubsSql();
    this.writeTeamsSql();
    this.writeDivisionTeamsSql();
    this.writeStandingsSql();    this.writePlayersSql();    
    console.log('✓ SQL generation complete\n');
  }

  /**
   * Read cached standings HTML (uses most recent file)
   */
  readStandingsHtml() {
    const htmlDir = path.join(__dirname, '../../../scraped-html/apsl');
    const files = fs.readdirSync(htmlDir)
      .filter(f => f.startsWith('tables-'))
      .map(f => ({
        name: f,
        path: path.join(htmlDir, f),
        mtime: fs.statSync(path.join(htmlDir, f)).mtime
      }))
      .sort((a, b) => b.mtime - a.mtime); // Sort by most recent first
    
    if (files.length === 0) {
      throw new Error('No standings HTML found. Run ./scrape.sh first.');
    }
    
    const htmlPath = files[0].path;
    console.log(`   Reading: ${htmlPath}`);
    return fs.readFileSync(htmlPath, 'utf-8');
  }

  /**
   * Parse APSL standings page
   */
  parseStandingsPage(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // APSL uses accordion titles like "2025/2026 - Mayflower Conference"
    const accordionTitles = document.querySelectorAll('.leagueAccordTitle1');
    
    accordionTitles.forEach((title) => {
      const titleText = title.textContent.trim();
      const match = titleText.match(/\d{4}\/\d{4}\s*-\s*(.+)/);
      if (!match) return;
      
      const divisionName = match[1];
      
      // Find the accordion box (div.leagueAccordbox) that follows this title
      let current = title.parentElement;
      let table = null;
      let iterations = 0;
      
      while (current && !table && iterations < 100) {
        iterations++;
        current = current.nextElementSibling;
        if (current && current.classList && current.classList.contains('leagueAccordbox')) {
          table = current.querySelector('table');
        }
      }
      
      if (!table) return;
      
      const rows = table.querySelectorAll('tr');
      rows.forEach((row, index) => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 10) return;
        
        const teamCell = cells[1];
        const teamName = teamCell.textContent.trim();
        const teamLink = teamCell.querySelector('a');
        const teamHref = teamLink?.getAttribute('href') || '';
        const externalId = teamHref.match(/\/Team\/(\d+)/i)?.[1];
        
        // Parse standings data
        const position = parseInt(cells[0]?.textContent.trim()) || index + 1;
        const played = parseInt(cells[2]?.textContent.trim()) || 0;
        const wins = parseInt(cells[3]?.textContent.trim()) || 0;
        const draws = parseInt(cells[4]?.textContent.trim()) || 0;
        const losses = parseInt(cells[5]?.textContent.trim()) || 0;
        const goalsFor = parseInt(cells[6]?.textContent.trim()) || 0;
        const goalsAgainst = parseInt(cells[7]?.textContent.trim()) || 0;
        const goalDiff = parseInt(cells[8]?.textContent.trim()) || 0;
        const points = parseInt(cells[9]?.textContent.trim()) || 0;
        
        if (teamName && externalId) {
          this.addTeam(teamName, externalId, divisionName, {
            position,
            played,
            wins,
            draws,
            losses,
            goalsFor,
            goalsAgainst,
            goalDiff,
            points
          });
        }
      });
    });
  }

  /**
   * Parse team rosters from cached HTML files
   */
  parseTeamRosters() {
    const htmlDir = path.join(__dirname, '../../../../database/scraped-html/apsl');
    const files = fs.readdirSync(htmlDir);
    
    // Track unique players by name to avoid duplicates
    const uniquePlayers = new Map();
    
    for (const file of files) {
      // Skip non-HTML files and the standings file
      if (!file.endsWith('.html') || file.includes('tables-') || file.endsWith('.skip')) continue;
      
      const filePath = path.join(htmlDir, file);
      const html = fs.readFileSync(filePath, 'utf-8');
      const dom = new JSDOM(html);
      const document = dom.window.document;
      
      // Find roster table
      const rosterTable = document.querySelector('table.TableRoster');
      if (!rosterTable) continue;
      
      // Parse player rows
      const rows = rosterTable.querySelectorAll('tr');
      for (const row of rows) {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) continue;
        
        // Player name is in second cell
        const nameDiv = cells[1].querySelector('div');
        if (!nameDiv) continue;
        
        const fullName = nameDiv.textContent.trim();
        if (!fullName) continue;
        
        // Split name into first/last
        const nameParts = fullName.split(/\s+/);
        const firstName = nameParts[0] || '';
        const lastName = nameParts.slice(1).join(' ') || '';
        
        // Use full name as key to avoid duplicates
        const key = fullName.toLowerCase();
        if (!uniquePlayers.has(key)) {
          uniquePlayers.set(key, {
            firstName: firstName,
            lastName: lastName,
            fullName: fullName
          });
        }
      }
    }
    
    // Convert to array
    this.players = Array.from(uniquePlayers.values());
  }

  /**
   * Add team (clubs/orgs will be extracted later via grouping)
   */
  addTeam(teamName, externalId, divisionName, standings) {
    const team = {
      name: teamName,
      externalId: externalId,
      divisionName: divisionName,
      sourceSystemId: this.sourceSystemId,
      standings: standings
    };
    
    this.teams.push(team);
    
    // Track division for later reference
    if (!this.divisions.has(divisionName)) {
      this.divisions.set(divisionName, { name: divisionName });
    }
  }



  /**
   * Write organizations SQL
   */
  writeOrganizationsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - APSL
-- Total Records: ${this.organizations.size}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.orgIdBase;
    for (const [name, org] of this.organizations) {
      sql += `INSERT INTO organizations (id, name) VALUES (${id}, '${this.escapeSql(name)}') ON CONFLICT (id) DO NOTHING;\n`;
      org.id = id;
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `100.${this.leagueId}-organizations-usa-apsl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write clubs SQL
   */
  writeClubsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - APSL
-- Total Records: ${this.clubs.size}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.clubIdBase;
    for (const [name, club] of this.clubs) {
      const org = this.organizations.get(club.organizationName);
      sql += `INSERT INTO clubs (id, name, organization_id) VALUES (${id}, '${this.escapeSql(name)}', ${org.id}) ON CONFLICT (id) DO NOTHING;\n`;
      club.id = id;
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `101.${this.leagueId}-clubs-usa-apsl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write teams SQL
   */
  writeTeamsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - APSL
-- Total Records: ${this.teams.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.teamIdBase;
    for (const team of this.teams) {
      const club = this.clubs.get(team.clubName);
      sql += `INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (${id}, '${this.escapeSql(team.name)}', '${team.externalId}', ${club.id}, ${team.sourceSystemId}) ON CONFLICT (source_system_id, external_id) DO NOTHING;\n`;
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `102.${this.leagueId}-teams-usa-apsl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  // writeDivisionTeamsSql() and writeStandingsSql() are now inherited from BaseGenerator
}

// CLI execution
if (require.main === module) {
  const generator = new ApslSqlGenerator();
  generator.generate()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('❌ Error:', err);
      process.exit(1);
    });
}

module.exports = ApslSqlGenerator;
