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
   * Parse CASA teams from new schema format
   * Format: INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
   *         SELECT '...', '...', club_id, d.id, 2 FROM divisions d...
   */
  parseCasaTeamsSql(sql) {
    const teams = [];
    
    // New schema format with division_id lookup (multi-line, use dotall flag)
    const regex = /INSERT INTO teams \(name, external_id, club_id, division_id, source_system_id\)\s+SELECT '([^']+)', '([^']+)', (\d+), d\.id, (\d+)/gs;
    
    let match;
    while ((match = regex.exec(sql)) !== null) {
      teams.push({
        id: null, // Auto-generated
        name: match[1],
        externalId: match[2],
        clubId: parseInt(match[3]),
        sourceSystemId: parseInt(match[4])
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
    const casaTeams = this.parseTeamsSql(casaTeamsSql); // Use base parser for standard format

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

    // Group new teams to extract clubs
    const teamGroups = this.groupTeamsByClub(newTeams);
    const newClubs = [];
    for (const [normalized, teams] of teamGroups) {
      const clubName = this.getClubBaseName(teams[0].name);
      newClubs.push({ name: clubName, teams });
    }

    // Check for potential duplicates using BaseGenerator logic
    const BaseGenerator = require('../BaseGenerator');
    const baseGen = new BaseGenerator('CASA', 2, '00002', 20000, 20000, 20000);
    const potentialDuplicates = baseGen.findPotentialDuplicates(existingClubs, newClubs);
    
    if (potentialDuplicates.length > 0) {
      console.log(`\n   ⚠️  POTENTIAL DUPLICATES DETECTED:`);
      for (const warning of potentialDuplicates) {
        console.log(`      [${warning.severity}] "${warning.newClub}" may duplicate "${warning.existingClub}"`);
        console.log(`              Matching words: ${warning.matchingWords.join(', ')}`);
      }
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

    // Teams: NEW SCHEMA - copy INSERT...SELECT statements and update club_id
    sql.teams = this.generateSqlHeader(
      'Teams - CASA (Curated)',
      `Teams with curated club_id references. Total: ${casaTeams.length}`
    );

    // Read original teams SQL
    const teamsPath = path.join(__dirname, 'sql', '102.00002-teams-usa-casa.sql');
    if (fs.existsSync(teamsPath)) {
      let originalTeamsSql = fs.readFileSync(teamsPath, 'utf8');
      
      // For each matched team, replace its club_id in the SQL
      for (const { casaTeam, existingClub } of matches) {
        // Find the team's INSERT statement by name
        const escapedName = casaTeam.name.replace(/'/g, "''");
        const oldClubId = casaTeam.clubId;
        const newClubId = existingClub.id;
        
        // Replace club_id in the INSERT statement for this team
        const oldPattern = `SELECT '${escapedName}', '${casaTeam.externalId}', ${oldClubId},`;
        const newPattern = `SELECT '${escapedName}', '${casaTeam.externalId}', ${newClubId},`;
        originalTeamsSql = originalTeamsSql.replace(oldPattern, newPattern);
      }
      
      // Extract INSERT statements (multi-line, so split by INSERT and rejoin)
      const insertStatements = originalTeamsSql
        .split(/(?=INSERT INTO teams)/g)  // Split before each INSERT
        .filter(stmt => stmt.trim().startsWith('INSERT'))  // Keep only INSERT statements
        .map(stmt => stmt.trim())  // Trim whitespace
        .join('\n');  // Join with newlines
      
      sql.teams += insertStatements + '\n';
    } else {
      console.log('   ⚠️  Original teams SQL not found at', teamsPath);
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
