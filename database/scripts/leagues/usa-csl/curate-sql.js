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
    this.config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf8'));
    this.apslConfig = JSON.parse(fs.readFileSync(path.join(__dirname, '../usa-apsl/config.json'), 'utf8'));
    this.apslPath = path.join(__dirname, '../usa-apsl/sql');
    this.cslPath = path.join(__dirname, 'sql');
  }

  /**
   * CSL-specific club family mappings from config
   */
  getClubFamily(baseName) {
    return this.config.clubFamilies[baseName.toLowerCase()] || null;
  }

  /**
   * Main curation workflow
   */
  async curate() {
    console.log('\n🔍 CSL SQL Curation Starting...');
    
    // Read APSL SQL files
    const afc = this.apslConfig.fileCode;
    const aslug = this.apslConfig.leagueSlug;
    console.log('   Reading APSL SQL...');
    const apslOrgsSql = fs.readFileSync(path.join(this.apslPath, `100.${afc}-organizations-${aslug}.sql`), 'utf-8');
    const apslClubsSql = fs.readFileSync(path.join(this.apslPath, `101.${afc}-clubs-${aslug}.sql`), 'utf-8');
    
    const apslOrgs = this.parseOrganizationsSql(apslOrgsSql, this.apslConfig.sourceSystemId);
    const apslClubs = this.parseClubsSql(apslClubsSql, this.apslConfig.sourceSystemId);
    
    console.log(`   APSL: ${apslOrgs.length} orgs, ${apslClubs.length} clubs`);
    
    // Read CSL SQL files
    const cfc = this.config.fileCode;
    const cslug = this.config.leagueSlug;
    console.log('   Reading CSL SQL...');
    const cslOrgsSql = fs.readFileSync(path.join(this.cslPath, `100.${cfc}-organizations-${cslug}.sql`), 'utf-8');
    const cslClubsSql = fs.readFileSync(path.join(this.cslPath, `101.${cfc}-clubs-${cslug}.sql`), 'utf-8');
    const cslTeamsSql = fs.readFileSync(path.join(this.cslPath, `102.${cfc}-teams-${cslug}.sql`), 'utf-8');
    
    const cslOrgs = this.parseOrganizationsSql(cslOrgsSql, this.config.sourceSystemId);
    const cslClubs = this.parseClubsSql(cslClubsSql, this.config.sourceSystemId);
    const cslTeams = this.parseTeamsSql(cslTeamsSql, this.config.sourceSystemId);
    
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
    
    // Check for potential duplicates using BaseGenerator logic
    const BaseGenerator = require('../BaseGenerator');
    const baseGen = new BaseGenerator(this.config.leagueName, this.config.sourceSystemId, this.config.fileCode, this.config.orgIdBase, this.config.clubIdBase, this.config.teamIdBase);
    const potentialDuplicates = baseGen.findPotentialDuplicates(apslClubs, newClubs);
    
    if (potentialDuplicates.length > 0) {
      console.log('\n   ⚠️  POTENTIAL DUPLICATES DETECTED:');
      for (const warning of potentialDuplicates) {
        console.log(`      [${warning.severity}] "${warning.newClub}" may duplicate "${warning.existingClub}"`);
        console.log(`              Matching words: ${warning.matchingWords.join(', ')}`);
      }
    }
    
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
    
    // Teams: Read original SQL and replace club_ids for matched clubs
    // This preserves the SELECT...FROM divisions subqueries from the generator
    const originalTeamsSql = fs.readFileSync(path.join(this.cslPath, `102.${this.config.fileCode}-teams-${this.config.leagueSlug}.sql`), 'utf-8');
    let curatedTeamsSql = originalTeamsSql;

    // Create mapping of CSL club_id → APSL club_id
    const clubIdMap = new Map();
    for (const { cslClub, apslClub } of matches) {
      clubIdMap.set(cslClub.id, apslClub.id);
    }

    // Replace club_ids in the original SQL using regex
    for (const [oldClubId, newClubId] of clubIdMap) {
      // Match pattern: SELECT 'TeamName', 'externalId', OLD_CLUB_ID, d.id, SOURCE_SYSTEM_ID
      const pattern = new RegExp(`(SELECT '[^']*(?:''[^']*)*', '[^']*', )${oldClubId}(, d\\.id, \\d+)`, 'g');
      curatedTeamsSql = curatedTeamsSql.replace(pattern, `$1${newClubId}$2`);
    }

    sql.teams = curatedTeamsSql;

    return sql;
  }

  /**
   * Write curated SQL files
   */
  writeCuratedSql(sql) {
    const outputDir = this.cslPath;
    const fc = this.config.fileCode;
    const slug = this.config.leagueSlug;
    
    fs.writeFileSync(path.join(outputDir, `100.${fc}-organizations-${slug}.sql`), sql.organizations);
    console.log(`      ✓ 100.${fc}-organizations-${slug}.sql`);
    
    fs.writeFileSync(path.join(outputDir, `101.${fc}-clubs-${slug}.sql`), sql.clubs);
    console.log(`      ✓ 101.${fc}-clubs-${slug}.sql`);
    
    fs.writeFileSync(path.join(outputDir, `102.${fc}-teams-${slug}.sql`), sql.teams);
    console.log(`      ✓ 102.${fc}-teams-${slug}.sql`);
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
