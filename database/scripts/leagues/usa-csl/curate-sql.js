#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const BaseSqlCurator = require('../BaseSqlCurator');

/**
 * CSL SQL Curator
 * 
 * Reads APSL and CSL SQL files, matches duplicate clubs, and generates
 * curated SQL that merges CSL teams into existing APSL clubs.
 * 
 * Workflow: APSL SQL + CSL SQL → Curated CSL SQL
 */
class CslSqlCurator extends BaseSqlCurator {
  constructor() {
    super();
    this.apslPath = path.join(__dirname, '../usa-apsl/sql');
    this.cslPath = path.join(__dirname, '../usa-csl/sql');
  }

  /**
   * CSL-specific club family mappings
   */
  getClubFamily(baseName) {
    const families = {
      'central park rangers': 'central-park-rangers',
      'manhattan celtic': 'manhattan-celtic',
      'manhattan kickers': 'manhattan-kickers',
      'sporting astoria': 'sporting-astoria',
      'sporting astoria south bronx united': 'sporting-astoria',
      'zum schneider': 'zum-schneider',
      'zum schneider fc 03': 'zum-schneider',
      'hoboken fc': 'hoboken-fc',
      'hoboken fc 1912': 'hoboken-fc',
      'polonia': 'polonia',
      'polonia sc': 'polonia',
      'sc eintracht': 'sc-eintracht',
      'ny shamrocks': 'ny-shamrocks',
      'ny ukrainians': 'ny-ukrainians',
      'fc sandzak': 'fc-sandzak',
      'laberia fc': 'laberia-fc',
      'block fc': 'block-fc',
    };
    
    return families[baseName.toLowerCase()] || null;
  }

  /**
   * Main curation workflow
   */
  async curate() {
    console.log('\n🔍 CSL SQL Curation Starting...');
    
    // Read APSL SQL files
    console.log('   Reading APSL SQL...');
    const apslOrgsSql = fs.readFileSync(path.join(this.apslPath, '100.00001-organizations-usa-apsl.sql'), 'utf-8');
    const apslClubsSql = fs.readFileSync(path.join(this.apslPath, '101.00001-clubs-usa-apsl.sql'), 'utf-8');
    
    const apslOrgs = this.parseOrganizationsSql(apslOrgsSql, 1);
    const apslClubs = this.parseClubsSql(apslClubsSql, 1);
    
    console.log(`   APSL: ${apslOrgs.length} orgs, ${apslClubs.length} clubs`);
    
    // Read CSL SQL files
    console.log('   Reading CSL SQL...');
    const cslOrgsSql = fs.readFileSync(path.join(this.cslPath, '100.00003-organizations-usa-csl.sql'), 'utf-8');
    const cslClubsSql = fs.readFileSync(path.join(this.cslPath, '101.00003-clubs-usa-csl.sql'), 'utf-8');
    const cslTeamsSql = fs.readFileSync(path.join(this.cslPath, '102.00003-teams-usa-csl.sql'), 'utf-8');
    
    const cslOrgs = this.parseOrganizationsSql(cslOrgsSql, 3);
    const cslClubs = this.parseClubsSql(cslClubsSql, 3);
    const cslTeams = this.parseTeamsSql(cslTeamsSql, 3);
    
    console.log(`   CSL: ${cslOrgs.length} orgs, ${cslClubs.length} clubs, ${cslTeams.length} teams`);
    
    // Match CSL clubs to APSL clubs
    console.log('   Matching clubs...');
    const matches = [];
    const newClubs = [];
    
    for (const cslClub of cslClubs) {
      const apslMatch = this.findMatchingClub(cslClub.name, apslClubs);
      
      if (apslMatch) {
        matches.push({ cslClub, apslClub: apslMatch });
      } else {
        newClubs.push(cslClub);
      }
    }
    
    console.log(`   Matched: ${matches.length} clubs`);
    console.log(`   New CSL-only: ${newClubs.length} clubs`);
    
    // Display matches for review
    console.log('\n   📋 Club Matches:');
    for (const { cslClub, apslClub } of matches) {
      console.log(`      ${cslClub.name} (CSL) → ${apslClub.name} (APSL id=${apslClub.id})`);
    }
    
    console.log('\n   🆕 New CSL Clubs:');
    for (const club of newClubs) {
      console.log(`      ${club.name}`);
    }
    
    // Generate curated SQL
    console.log('\n   Generating curated SQL...');
    const curatedSql = this.generateCuratedSql(apslOrgs, apslClubs, cslOrgs, cslClubs, cslTeams, matches, newClubs);
    
    // Write curated SQL files
    this.writeCuratedSql(curatedSql);
    
    console.log('✓ CSL curation complete\n');
  }

  /**
   * Generate curated SQL that merges CSL into APSL
   */
  generateCuratedSql(apslOrgs, apslClubs, cslOrgs, cslClubs, cslTeams, matches, newClubs) {
    const sql = {
      organizations: '',
      clubs: '',
      teams: ''
    };
    
    // Organizations: Only insert new CSL-only orgs
    sql.organizations = this.generateSqlHeader(
      'Organizations - CSL (Curated)',
      `Only new organizations not in APSL. Total: ${newClubs.length}`
    );
    
    const newOrgIds = new Set(newClubs.map(c => c.organizationId));
    const newOrgs = cslOrgs.filter(org => newOrgIds.has(org.id));
    
    for (const org of newOrgs) {
      sql.organizations += `INSERT INTO organizations (id, name) VALUES (${org.id}, '${this.escapeSql(org.name)}') ON CONFLICT (id) DO NOTHING;\n`;
    }
    
    // Clubs: Only insert new CSL-only clubs
    sql.clubs = this.generateSqlHeader(
      'Clubs - CSL (Curated)',
      `Only new clubs not in APSL. Matched clubs use APSL IDs. Total new: ${newClubs.length}`
    );
    
    for (const club of newClubs) {
      sql.clubs += `INSERT INTO clubs (id, name, organization_id) VALUES (${club.id}, '${this.escapeSql(club.name)}', ${club.organizationId}) ON CONFLICT (id) DO NOTHING;\n`;
    }
    
    // Teams: Update club_id to reference APSL clubs where matched
    sql.teams = this.generateSqlHeader(
      'Teams - CSL (Curated)',
      `Teams linked to existing APSL clubs where matched. Total: ${cslTeams.length}`
    );
    
    // Create mapping of CSL club_id → APSL club_id
    const clubIdMap = new Map();
    for (const { cslClub, apslClub } of matches) {
      clubIdMap.set(cslClub.id, apslClub.id);
    }
    
    for (const team of cslTeams) {
      // Use APSL club_id if matched, otherwise keep CSL club_id (for new clubs)
      const finalClubId = clubIdMap.get(team.clubId) || team.clubId;
      sql.teams += `INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (${team.id}, '${this.escapeSql(team.name)}', '${team.externalId}', ${finalClubId}, ${team.sourceSystemId}) ON CONFLICT (source_system_id, external_id) DO NOTHING;\n`;
    }
    
    return sql;
  }

  /**
   * Write curated SQL files
   */
  writeCuratedSql(sql) {
    const outputDir = this.cslPath;
    
    fs.writeFileSync(path.join(outputDir, '100.00003-organizations-usa-csl.sql'), sql.organizations);
    console.log(`      ✓ 100.00003-organizations-usa-csl.sql`);
    
    fs.writeFileSync(path.join(outputDir, '101.00003-clubs-usa-csl.sql'), sql.clubs);
    console.log(`      ✓ 101.00003-clubs-usa-csl.sql`);
    
    fs.writeFileSync(path.join(outputDir, '102.00003-teams-usa-csl.sql'), sql.teams);
    console.log(`      ✓ 102.00003-teams-usa-csl.sql`);
  }
}

// CLI execution
if (require.main === module) {
  const curator = new CslSqlCurator();
  curator.curate()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('❌ Curation failed:', err);
      process.exit(1);
    });
}

module.exports = CslSqlCurator;
