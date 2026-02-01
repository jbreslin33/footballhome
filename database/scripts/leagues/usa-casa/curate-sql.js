#!/usr/bin/env node
/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * CASA - SQL Curation
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * Curates CASA teams against existing APSL and CSL clubs.
 * - Matches CASA teams to existing clubs via fuzzy matching
 * - Creates new orgs/clubs only for unmatched teams
 * - Rewrites team club_id to reference existing clubs where matched
 * 
 * Matching Strategy:
 * 1. Check club family mappings (e.g., "Lighthouse Boys Club" → "Lighthouse 1893 SC")
 * 2. Strip suffixes (II, Reserve, Old Timers, Boys Club, etc.)
 * 3. Fuzzy match base names
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const fs = require('fs');
const path = require('path');
const BaseSqlCurator = require('../BaseSqlCurator');

class CasaSqlCurator extends BaseSqlCurator {
  constructor() {
    super('CASA', 'usa-casa');
    this.sourceSystemId = 2;
    this.orgIdBase = 20000;
    this.clubIdBase = 20000;
    this.teamIdBase = 20000;
  }

  /**
   * Club family mappings for CASA teams
   * Maps CASA base names to existing club base names
   */
  getClubFamily(baseName) {
    const families = {
      // Lighthouse family
      'lighthouse-boys-club': 'lighthouse-1893-sc',
      'lighthouse-old-timers-club': 'lighthouse-1893-sc',
      'lighthouse-1893-sc': 'lighthouse-1893-sc',
      
      // Philadelphia family (in APSL)
      'philadelphia-sc': 'philadelphia-soccer-club',
      'philadelphia-soccer-club': 'philadelphia-soccer-club',
      
      // Phoenix family (CASA-only)
      'phoenix-scm': 'phoenix-sc',
      'phoenix-scr': 'phoenix-sc',
      'phoenix-sc': 'phoenix-sc',
      
      // Persepolis family (CASA-only)
      'persepolis-fc': 'persepolis-fc',
      'persepolis-united-fc': 'persepolis-fc',
      
      // Oaklyn United (in APSL)
      'oaklyn-united-fc': 'oaklyn-united-fc',
      
      // Alloy (in APSL)
      'alloy-soccer-club': 'alloy-sc',
      'alloy-sc': 'alloy-sc'
    };

    return families[baseName] || baseName;
  }

  /**
   * Parse CASA teams from old multi-row format
   * Format: INSERT INTO teams (...) VALUES\n  (id, club_id, name, ...),\n  (id, club_id, name, ...);
   */
  parseCasaTeamsSql(sql) {
    const teams = [];
    // Match the full multi-row INSERT statement
    const regex = /\((\d+),\s*(NULL|\d+),\s*'([^']+)',\s*[^)]+\)/g;
    
    let match;
    while ((match = regex.exec(sql)) !== null) {
      teams.push({
        id: parseInt(match[1]),
        clubId: match[2] === 'NULL' ? null : parseInt(match[2]),
        name: match[3],
        externalId: null, // CASA teams don't have external_id
        sourceSystemId: this.sourceSystemId
      });
    }
    
    return teams;
  }

  /**
   * Main curation workflow
   */
  async curate() {
    console.log(`\n${'='.repeat(80)}`);
    console.log(`🎯 Curating ${this.leagueName} SQL against APSL + CSL`);
    console.log(`${'='.repeat(80)}\n`);

    // Read APSL SQL files
    const apslDir = path.join(__dirname, '../usa-apsl/sql');
    const apslOrgs = this.parseOrganizationsSql(fs.readFileSync(path.join(apslDir, '100.00001-organizations-usa-apsl.sql'), 'utf8'));
    const apslClubs = this.parseClubsSql(fs.readFileSync(path.join(apslDir, '101.00001-clubs-usa-apsl.sql'), 'utf8'));

    console.log(`📖 Parsed APSL:`);
    console.log(`   Organizations: ${apslOrgs.length}`);
    console.log(`   Clubs: ${apslClubs.length}`);

    // Read CSL SQL files
    const cslDir = path.join(__dirname, '../usa-csl/sql');
    const cslOrgs = this.parseOrganizationsSql(fs.readFileSync(path.join(cslDir, '100.00003-organizations-usa-csl.sql'), 'utf8'));
    const cslClubs = this.parseClubsSql(fs.readFileSync(path.join(cslDir, '101.00003-clubs-usa-csl.sql'), 'utf8'));

    console.log(`\n📖 Parsed CSL:`);
    console.log(`   Organizations: ${cslOrgs.length}`);
    console.log(`   Clubs: ${cslClubs.length}`);

    // Combine APSL + CSL clubs for matching
    const existingClubs = [...apslClubs, ...cslClubs];
    console.log(`\n📊 Total existing clubs to match against: ${existingClubs.length}`);

    // Read current CASA SQL files
    const sqlDir = path.join(__dirname, 'sql');
    const casaOrgsSql = fs.readFileSync(path.join(sqlDir, '100.00002-organizations-usa-casa.sql'), 'utf8');
    const casaClubsSql = fs.readFileSync(path.join(sqlDir, '101.00002-clubs-usa-casa.sql'), 'utf8');
    const casaTeamsSql = fs.readFileSync(path.join(sqlDir, '102.00002-teams-usa-casa.sql'), 'utf8');

    const casaOrgs = this.parseOrganizationsSql(casaOrgsSql);
    const casaClubs = this.parseClubsSql(casaClubsSql);
    const casaTeams = this.parseCasaTeamsSql(casaTeamsSql); // Use CASA-specific parser

    console.log(`\n📖 Parsed CASA (before curation):`);
    console.log(`   Organizations: ${casaOrgs.length}`);
    console.log(`   Clubs: ${casaClubs.length}`);
    console.log(`   Teams: ${casaTeams.length}`);

    // Match CASA teams to existing clubs
    // Note: CASA teams might not have clubs yet (club_id = NULL)
    // We need to infer club names from team names
    const matches = [];
    const newTeams = [];

    console.log(`\n🔍 Matching CASA teams to existing clubs...`);

    for (const casaTeam of casaTeams) {
      // Infer club name from team name (strip suffixes like II, Reserve, etc.)
      const inferredClubName = this.getClubBaseName(casaTeam.name);
      const existingMatch = this.findMatchingClub(inferredClubName, existingClubs);

      if (existingMatch) {
        matches.push({ casaTeam, existingClub: existingMatch });
      } else {
        newTeams.push(casaTeam);
      }
    }

    console.log(`\n   📋 Team Matches:`);
    for (const { casaTeam, existingClub } of matches) {
      console.log(`      ${casaTeam.name} (CASA) → ${existingClub.name} (${existingClub.id < 10000 ? 'APSL' : 'CSL'} id=${existingClub.id})`);
    }

    console.log(`\n   🆕 New CASA Teams (need new clubs):`);
    for (const team of newTeams) {
      console.log(`      ${team.name}`);
    }

    // Generate curated SQL
    const curatedSql = this.generateCuratedSql(
      casaOrgs,
      casaClubs,
      casaTeams,
      matches,
      newTeams
    );

    // Write curated SQL back to files
    fs.writeFileSync(path.join(sqlDir, '100.00002-organizations-usa-casa.sql'), curatedSql.organizations);
    fs.writeFileSync(path.join(sqlDir, '101.00002-clubs-usa-casa.sql'), curatedSql.clubs);
    fs.writeFileSync(path.join(sqlDir, '102.00002-teams-usa-casa.sql'), curatedSql.teams);

    console.log(`\n✓ Curated SQL files written to ${sqlDir}`);
    console.log(`   Matched teams: ${matches.length}`);
    console.log(`   New teams: ${newTeams.length}`);
    console.log(`\n${'='.repeat(80)}\n`);
  }

  /**
   * Generate curated SQL with proper club_id references
   */
  generateCuratedSql(casaOrgs, casaClubs, casaTeams, matches, newTeams) {
    const sql = {
      organizations: '',
      clubs: '',
      teams: ''
    };

    // Group new teams by normalized club name
    const teamGroups = this.groupTeamsByClub(newTeams);
    
    const newClubs = [];
    const newOrgs = [];
    let nextOrgId = this.orgIdBase;
    let nextClubId = this.clubIdBase;

    // Create ONE club per group
    for (const [normalizedName, teams] of teamGroups) {
      // Use the first team's base name as the club name
      const clubName = this.getClubBaseName(teams[0].name);
      
      const orgId = nextOrgId++;
      const clubId = nextClubId++;

      newOrgs.push({ id: orgId, name: clubName });
      newClubs.push({ id: clubId, name: clubName, organizationId: orgId });
      
      // Assign this club_id to ALL teams in the group
      for (const team of teams) {
        team.newClubId = clubId;
      }
    }

    // Organizations: Only new CASA-only orgs
    sql.organizations = this.generateSqlHeader(
      'Organizations - CASA (Curated)',
      `Only new organizations not in APSL or CSL. Total: ${newOrgs.length}`
    );

    for (const org of newOrgs) {
      sql.organizations += `INSERT INTO organizations (id, name) VALUES (${org.id}, '${this.escapeSql(org.name)}') ON CONFLICT (id) DO NOTHING;\n`;
    }

    // Clubs: Only new CASA-only clubs
    sql.clubs = this.generateSqlHeader(
      'Clubs - CASA (Curated)',
      `Only new clubs not in APSL or CSL. Matched teams use existing club IDs. Total new: ${newClubs.length}`
    );

    for (const club of newClubs) {
      sql.clubs += `INSERT INTO clubs (id, name, organization_id) VALUES (${club.id}, '${this.escapeSql(club.name)}', ${club.organizationId}) ON CONFLICT (id) DO NOTHING;\n`;
    }

    // Teams: All teams, using existing or new club_id
    sql.teams = this.generateSqlHeader(
      'Teams - CASA (Curated)',
      `Teams linked to existing clubs where matched. Total: ${casaTeams.length}`
    );

    // Create mapping of team → final club_id
    const teamClubMap = new Map();
    for (const { casaTeam, existingClub } of matches) {
      teamClubMap.set(casaTeam.id, existingClub.id);
    }
    for (const team of newTeams) {
      teamClubMap.set(team.id, team.newClubId);
    }

    for (const team of casaTeams) {
      const finalClubId = teamClubMap.get(team.id);
      if (!finalClubId) {
        console.error(`⚠️  No club_id mapping for team: ${team.name} (id=${team.id})`);
        continue;
      }

      const externalId = team.externalId || 'NULL';
      const externalIdStr = externalId === 'NULL' ? 'NULL' : `'${externalId}'`;

      sql.teams += `INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (${team.id}, '${this.escapeSql(team.name)}', ${externalIdStr}, ${finalClubId}, ${team.sourceSystemId}) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;\n`;
    }

    return sql;
  }
}

// Run if called directly
if (require.main === module) {
  const curator = new CasaSqlCurator();
  curator.curate().catch(err => {
    console.error('❌ Error curating CASA SQL:', err);
    process.exit(1);
  });
}

module.exports = CasaSqlCurator;
