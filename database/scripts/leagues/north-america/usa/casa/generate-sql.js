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
const BaseGenerator = require('../../../BaseGenerator');

class CasaSqlGenerator extends BaseGenerator {
  constructor() {
    const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf8'));
    super(config.leagueName, config.sourceSystemId, config.fileCode, config.orgIdBase, config.clubIdBase, config.teamIdBase);
    this.config = config;
    this.organizations = new Map();
    this.clubs = new Map();
    this.teams = [];
    this.standings = [];
  }

  /**
   * Abstract method implementations
   */
  getLeagueFolder() {
    return this.config.leaguePath;
  }

  getLeagueSlug() {
    return this.config.leagueSlug;
  }

  getPlayerIdBase() {
    return this.config.playerIdBase;
  }

  getSeasonName() {
    return this.config.activeSeason;
  }

  getLeagueId() {
    return this.config.leagueDbId;
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
    
    // Parse standings from schedule HTML
    console.log('\n📈 Parsing standings from schedule HTML...');
    await this.parseStandings();
    this.writeStandingsSql();
    
    // Parse rosters and generate players SQL
    console.log('\n👥 Parsing player rosters...');
    await this.parseTeamRosters();
    this.writePlayersSql();
    this.writeRostersSql();
    
    // Parse matches from JSON
    console.log('\n⚽ Parsing matches from JSON...');
    await this.parseMatches();
    console.log(`   Found ${this.matches.length} matches`);
    this.writeMatchesSql();
    
    // Save universal JSON snapshot for diff-based updates
    this.saveSnapshot();
    
    console.log('\n✓ SQL generation complete\n');
  }

  /**
   * Read division-teams JSON file
   */
  readDivisionTeamsJson() {
    const jsonPath = path.join(__dirname, '../../../../../scraped-html/casa/division-teams.json');
    
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
      for (const teamObj of division.teams) {
        // Skip header/placeholder rows (only skip if name is "Teams")
        if (teamObj.teamName === 'Teams') continue;
        
        this.addTeam(teamObj.teamName, division.external_id, division.name);
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
      divisionExternalId: divisionExternalId,
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

    const outputPath = path.join(__dirname, 'sql', `100.${this.leagueId}-organizations-casa.sql`);
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

    const outputPath = path.join(__dirname, 'sql', `101.${this.leagueId}-clubs-casa.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write teams SQL
   * NEW SCHEMA: Teams must have division_id (NOT NULL FK)
   */
  writeTeamsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA
-- Total Records: ${this.teams.length}
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    for (const team of this.teams) {
      const club = this.clubs.get(team.clubName);
      if (!club) {
        console.error(`ERROR: Club not found for team "${team.name}", clubName="${team.clubName}"`);
        throw new Error('Club lookup failed');
      }
      
      // Lookup division_id by division name for current season
      // Team identity is now bound to division (same club in different divisions = different teams)
      sql += `INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT '${this.escapeSql(team.name)}', '${this.escapeSql(team.externalId)}', ${club.id}, d.id, ${team.sourceSystemId}
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '${this.getSeasonName()}'
  AND s.league_id = ${this.getLeagueId()}
ON CONFLICT (division_id, name) DO NOTHING;\n`;
    }

    const outputPath = path.join(__dirname, 'sql', `102.${this.leagueId}-teams-casa.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Parse standings from standings-data.json
   * This file is generated by parse-casa-standings.js using Puppeteer scrolling
   */
  async parseStandings() {
    const jsonPath = path.join(__dirname, '../../../../../scraped-html/casa/standings-data.json');
    
    if (!fs.existsSync(jsonPath)) {
      console.log('   ⚠️  standings-data.json not found');
      console.log('   💡 Run: node database/scripts/parse-casa-standings.js to generate it');
      return;
    }

    const standingsData = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
    console.log(`   📂 Reading standings-data.json (${standingsData.divisions.length} divisions)`);
    
    let matchedCount = 0;
    let unmatchedCount = 0;
    
    // Process each division's teams
    for (const division of standingsData.divisions) {
      for (const teamData of division.teams) {
        // Skip header/placeholder rows
        if (teamData.teamName === 'Teams' || teamData.played === 0) continue;
        
        // Find matching team in our teams array
        const team = this.teams.find(t => 
          t.name === teamData.teamName || 
          t.name.includes(teamData.teamName) || 
          teamData.teamName.includes(t.name)
        );
        
        if (!team) {
          console.log(`   ⚠️  Team not found in standings: ${teamData.teamName}`);
          unmatchedCount++;
          continue;
        }
        
        team.standings = {
          position: 0, // Will be determined by sort order
          played: teamData.played,
          wins: teamData.wins,
          draws: teamData.draws,
          losses: teamData.losses,
          goalsFor: teamData.goalsFor,
          goalsAgainst: teamData.goalsAgainst,
          goalDiff: teamData.goalDiff,
          points: teamData.points
        };
        matchedCount++;
      }
    }
    
    console.log(`   ✓ Parsed standings for ${matchedCount} teams (${matchedCount} matched, ${unmatchedCount} unmatched)`);
  }

  /**
   * Update standings map with team record (deprecated - kept for fallback)
   */
  updateStandings(standingsMap, teamName, record, goalsFor, goalsAgainst) {
    // Find team by name
    const team = this.teams.find(t => t.name === teamName);
    if (!team) {
      console.log(`   ⚠️  Team not found: ${teamName}`);
      return;
    }
    
    // Parse record (W - L) or (W - L - D)
    const parts = record.replace(/[()]/g, '').split('-').map(s => parseInt(s.trim()));
    const wins = parts[0] || 0;
    const losses = parts[1] || 0;
    const draws = parts[2] || 0;
    
    // Calculate points (3 for win, 1 for draw)
    const points = (wins * 3) + draws;
    
    // Accumulate goals if available
    const gf = parseInt(goalsFor) || 0;
    const ga = parseInt(goalsAgainst) || 0;
    
    // Get or create standing entry
    if (!standingsMap.has(team.id)) {
      standingsMap.set(team.id, {
        team_id: team.id,
        wins,
        losses,
        draws,
        goals_for: gf,
        goals_against: ga,
        points
      });
    } else {
      // Update with latest record (most recent match)
      const standing = standingsMap.get(team.id);
      standing.wins = wins;
      standing.losses = losses;
      standing.draws = draws;
      standing.goals_for += gf;
      standing.goals_against += ga;
      standing.points = (wins * 3) + draws;
    }
  }

  /**
   * Parse team rosters from cached XLSX files (downloaded from Google Sheets)
   * Populates this.players and this.rosters arrays for SQL generation
   * 
   * NEW: No longer assigns hardcoded player IDs. Instead stores
   * firstName, lastName, teamName for name-based SQL generation.
   */
  async parseTeamRosters() {
    const CasaRosterScraper = require('../../../../scrapers/CasaRosterScraper');
    const cacheDir = path.join(__dirname, '../../../../../scraped-html/casa');

    const scraper = new CasaRosterScraper(this.config, cacheDir);
    const { players: rosterPlayers, teamSummaries } = scraper.parseFromCache();

    if (rosterPlayers.length === 0) {
      console.log('   ⚠️  No roster data found in cache — skipping player SQL');
      console.log('   ℹ️  Run roster scraper first to download XLSX from Google Sheets');
      return;
    }

    // Track unique players by name to avoid duplicates within this league
    const uniquePlayers = new Map();

    for (const rp of rosterPlayers) {
      const key = `${rp.firstName} ${rp.lastName}`.toLowerCase();
      
      if (!uniquePlayers.has(key)) {
        uniquePlayers.set(key, {
          firstName: rp.firstName,
          lastName: rp.lastName,
          dateOfBirth: rp.dateOfBirth || null,
          teamName: rp.teamName,
          teamExternalId: ''
        });
      }

      this.rosters.push({
        firstName: rp.firstName,
        lastName: rp.lastName,
        teamName: rp.teamName,
        jerseyNumber: rp.jerseyNumber || null
      });
    }

    this.players = Array.from(uniquePlayers.values());
    console.log(`   ✅ Loaded ${this.players.length} unique players across ${Object.keys(teamSummaries).length} teams`);
  }

  /**
   * Parse matches from division-matches.json
   */
  async parseMatches() {
    const jsonPath = path.join(__dirname, '../../../../../scraped-html/casa/division-matches.json');
    
    if (!fs.existsSync(jsonPath)) {
      console.log('   ⚠️  division-matches.json not found');
      return;
    }
    
    const content = fs.readFileSync(jsonPath, 'utf-8');
    const data = JSON.parse(content);
    
    // Team name aliases (inconsistent naming in scraped data)
    const aliases = {
      'illyrians': 'illyrians fc',
      'phoenix reserves': 'phoenix scr'
    };
    
    // Create a map of team name -> external_id for matching
    const teamMap = new Map();
    for (const team of this.teams) {
      const key = team.name.toLowerCase().trim();
      teamMap.set(key, team.externalId);
      
      // Also add without common suffixes for fuzzy matching
      const baseKey = key.replace(/ (fc|sc|ii|reserves)$/i, '').trim();
      if (baseKey !== key) {
        teamMap.set(baseKey, team.externalId);
      }
    }
    
    // Parse each division's matches
    for (const division of data.divisions) {
      // Occurrence counter for duplicate matchups (same teams playing twice)
      const matchCounters = {};

      for (const match of division.matches) {
        let homeTeamKey = match.home.toLowerCase().trim();
        let awayTeamKey = match.away.toLowerCase().trim();
        
        // Apply aliases
        homeTeamKey = aliases[homeTeamKey] || homeTeamKey;
        awayTeamKey = aliases[awayTeamKey] || awayTeamKey;
        
        const homeExternalId = teamMap.get(homeTeamKey);
        const awayExternalId = teamMap.get(awayTeamKey);
        
        if (!homeExternalId || !awayExternalId) {
          console.log(`   ⚠️  Skipping match - team not found: ${match.home} vs ${match.away}`);
          continue;
        }
        
        // Parse score if final
        let homeScore = null;
        let awayScore = null;
        let status = 'scheduled';
        
        if (match.status === 'Final' && match.score) {
          const scoreMatch = match.score.match(/(\d+)\s*-\s*(\d+)/);
          if (scoreMatch) {
            homeScore = parseInt(scoreMatch[1]);
            awayScore = parseInt(scoreMatch[2]);
            status = 'completed';
          }
        }
        
        // Generate stable external ID matching scraper format:
        // {divExtId}_{homeSlug}_vs_{awaySlug}_{occurrence}
        const homeSlug = match.home.toLowerCase().replace(/\s+/g, '-');
        const awaySlug = match.away.toLowerCase().replace(/\s+/g, '-');
        const pairKey = `${homeSlug}::${awaySlug}`;
        matchCounters[pairKey] = (matchCounters[pairKey] || 0) + 1;
        const occurrence = matchCounters[pairKey];
        const externalId = `${division.external_id}_${homeSlug}_vs_${awaySlug}_${occurrence}`;
        
        // Add match (will be deduplicated by BaseGenerator)
        this.addMatch({
          homeTeamExternalId: homeExternalId,
          awayTeamExternalId: awayExternalId,
          homeTeamName: match.home,
          awayTeamName: match.away,
          divisionName: division.name,
          divisionExternalId: division.external_id,
          matchDate: '2026-01-01', // CASA doesn't have dates in JSON - use placeholder
          matchTime: null,
          venueId: null,
          homeScore: homeScore,
          awayScore: awayScore,
          matchType: 'league',
          status: status,
          sourceSystemId: this.sourceSystemId,
          externalId: externalId
        });
      }
    }
  }

  /**
   * Write matches SQL
   */
  writeMatchesSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CASA
-- Total Records: ${this.matches.length}
-- Match type: 1=league
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    // Write matches
    sql += `-- Matches\n`;
    for (const match of this.matches) {
      const matchType = 1; // league
      const matchStatus = match.status === 'completed' ? 3 : 1;
      
      sql += `INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  ${matchType}, '${match.matchDate}', ${match.matchTime ? `'${match.matchTime}'` : 'NULL'}, ${matchStatus},
  ht.id, at.id, NULL,
  ${match.homeScore !== null ? match.homeScore : 'NULL'}, ${match.awayScore !== null ? match.awayScore : 'NULL'},
  ${match.sourceSystemId}, '${this.escapeSql(match.externalId)}'
FROM teams ht
JOIN teams at ON at.external_id = '${this.escapeSql(match.awayTeamExternalId)}' AND at.source_system_id = ${match.sourceSystemId}
WHERE ht.external_id = '${this.escapeSql(match.homeTeamExternalId)}' AND ht.source_system_id = ${match.sourceSystemId}
ON CONFLICT (source_system_id, external_id) DO NOTHING;\n\n`;
    }

    const outputPath = path.join(__dirname, 'sql', `106.${this.leagueId}-matches-casa.sql`);
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
