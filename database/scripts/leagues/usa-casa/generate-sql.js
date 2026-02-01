#!/usr/bin/env node

/**
 * CASA SQL Generator
 * 
 * Reads division-teams.json and generates SQL (no database writes).
 * Creates organizations, clubs, and teams from JSON data.
 * 
 * Workflow: JSON → SQL files → Curation → Load to DB
 */

const fs = require('fs');
const path = require('path');
const BaseGenerator = require('../BaseGenerator');

class CasaSqlGenerator extends BaseGenerator {
  constructor() {
    super('CASA', 2, '00002', 20000, 20000, 20000);
    this.organizations = new Map();
    this.clubs = new Map();
    this.teams = [];
  }

  /**
   * Main workflow
   */
  async generate() {
    console.log('\n📄 Generating CASA SQL from JSON...');
    
    // Read division-teams JSON
    const data = this.readDivisionTeamsJson();
    
    // Parse teams
    this.parseTeams(data);
    
    console.log(`   Found ${this.teams.length} teams`);
    
    // Group teams by club (deduplicates clubs with multiple teams)
    const teamGroups = this.groupTeamsByClub(this.teams);
    this.clubs = this.extractClubsFromGroups(teamGroups);
    this.organizations = this.extractOrganizationsFromClubs(this.clubs);
    
    console.log(`   Extracted ${this.clubs.size} unique clubs (grouped from teams)`);
    console.log(`   Extracted ${this.organizations.size} unique organizations`);
    
    // Generate SQL files
    this.writeOrganizationsSql();
    this.writeClubsSql();
    this.writeTeamsSql();
    
    console.log('✓ SQL generation complete\n');
  }

  /**
   * Read division-teams JSON file
   */
  readDivisionTeamsJson() {
    const jsonPath = path.join(__dirname, '../../../scraped-html/casa/division-teams.json');
    
    if (!fs.existsSync(jsonPath)) {
      throw new Error('division-teams.json not found. Run ./scrape.sh first.');
    }
    
    console.log(`   Reading: ${jsonPath}`);
    const content = fs.readFileSync(jsonPath, 'utf-8');
    return JSON.parse(content);
  }

  /**
   * Parse teams from JSON data
   */
  parseTeams(data) {
    for (const division of data.divisions) {
      for (const teamName of division.teams) {
        this.addTeam(teamName, division.external_id, division.name);
      }
    }
  }

  /**
   * Add team (clubs/orgs will be extracted later via grouping)
   */
  addTeam(teamName, divisionExternalId, divisionName) {
    // Use team name + division as external_id since CASA doesn't have team IDs
    const externalId = `${divisionExternalId}-${teamName.toLowerCase().replace(/\s+/g, '-')}`;
    
    this.teams.push({
      name: teamName,
      externalId: externalId,
      divisionName: divisionName,
      sourceSystemId: this.sourceSystemId
    });
  }

  /**
   * Write organizations SQL
   */
  writeOrganizationsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - CASA
-- Total Records: ${this.organizations.size}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.orgIdBase;
    for (const [name, org] of this.organizations) {
      sql += `INSERT INTO organizations (id, name) VALUES (${id}, '${this.escapeSql(name)}') ON CONFLICT (id) DO NOTHING;\n`;
      org.id = id;
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `100.${this.leagueId}-organizations-usa-casa.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write clubs SQL
   */
  writeClubsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA
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

    const outputPath = path.join(__dirname, 'sql', `101.${this.leagueId}-clubs-usa-casa.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write teams SQL
   */
  writeTeamsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA
-- Total Records: ${this.teams.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let id = this.teamIdBase;
    for (const team of this.teams) {
      const club = this.clubs.get(team.clubName);
      if (!club) {
        console.error(`ERROR: Club not found for team "${team.name}", clubName="${team.clubName}"`);
        throw new Error('Club lookup failed');
      }
      sql += `INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (${id}, '${this.escapeSql(team.name)}', '${this.escapeSql(team.externalId)}', ${club.id}, ${team.sourceSystemId}) ON CONFLICT (source_system_id, external_id) DO NOTHING;\n`;
      id++;
    }

    const outputPath = path.join(__dirname, 'sql', `102.${this.leagueId}-teams-usa-casa.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }
}

// CLI execution
if (require.main === module) {
  const generator = new CasaSqlGenerator();
  generator.generate()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('❌ Error:', err);
      process.exit(1);
    });
}

module.exports = CasaSqlGenerator;
