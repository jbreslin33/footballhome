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
const CslMatchParser = require('../../infrastructure/parsers/CslMatchParser');

class CslSqlGenerator extends BaseGenerator {
  constructor() {
    // CSL ID ranges: orgs 10000+, clubs 10000+, teams 10000+
    super('CSL', 3, '00003', 10000, 10000, 10000);
    this.matchParser = new CslMatchParser();
  }

  /**
   * Required BaseGenerator methods
   */
  getLeagueFolder() {
    return 'usa-csl';
  }

  getPlayerIdBase() {
    return 20000; // CSL players start at 20000 (after APSL 10000-19999)
  }

  getSeasonName() {
    return '2022/2023'; // CSL active season (they use older season names)
  }

  getLeagueId() {
    return 4; // CSL league_id in leagues table
  }

  /**
   * Main workflow
   */
  async generate() {
    console.log('\n📄 Generating CSL SQL from HTML...');
    
    // Read standings HTML
    const standingsHtml = this.readStandingsHtml();
    
    // Parse standings (populates teams, standings, divisions)
    this.parseStandingsPage(standingsHtml);
    
    console.log(`   Found ${this.teams.length} teams`);
    console.log(`   Found ${this.standings.length} standings records`);
    console.log(`   Found ${this.divisions.size} divisions`);
    
    // Parse match schedules from team pages FIRST (less memory intensive)
    this.parseMatchSchedules();
    
    console.log(`   Found ${this.matches.length} matches`);
    
    // Parse player rosters from team pages (memory intensive - done after matches)
    this.parseTeamRosters();
    
    console.log(`   Found ${this.players.length} players`);
    console.log(`   Found ${this.rosters.length} roster entries (player-team relationships)`);
    
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
    this.writeStandingsSql();
    this.writePlayersSql();
    this.writeRostersSql();
    this.writeMatchesSql();
    
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
   * Parse standings page to extract teams and standings data
   */
  parseStandingsPage(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Find all div elements that contain division names
    const allDivs = document.querySelectorAll('div');
    
    for (const div of allDivs) {
      const text = div.textContent.trim();
      
      // Match division headers like "2022/2023 - Division 1"
      const divisionMatch = text.match(/^(\d{4}\/\d{4})\s*-\s*(.+)$/);
      if (!divisionMatch) continue;
      
      const season = divisionMatch[1]; // e.g., "2022/2023"
      const divisionName = divisionMatch[2]; // Just the division name without season
      
      // Only process current season (2022/2023 for CSL - they use older season names)
      if (season !== '2022/2023') continue;
      
      // Track division
      if (!this.divisions.has(divisionName)) {
        this.divisions.set(divisionName, { name: divisionName });
      }
      
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
          // Extract standings data
          // Column order: Rank, Team, MP, W, D, L, GF, GA, GD, Pts
          const position = parseInt(cells[0].textContent.trim()) || null;
          const played = parseInt(cells[2].textContent.trim()) || 0;
          const wins = parseInt(cells[3].textContent.trim()) || 0;
          const draws = parseInt(cells[4].textContent.trim()) || 0;
          const losses = parseInt(cells[5].textContent.trim()) || 0;
          const goalsFor = parseInt(cells[6].textContent.trim()) || 0;
          const goalsAgainst = parseInt(cells[7].textContent.trim()) || 0;
          const goalDiff = parseInt(cells[8].textContent.trim()) || 0;
          const points = parseInt(cells[9].textContent.trim()) || 0;
          
          // Add team with standings data attached
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
    }
  }

  /**
   * Add team (clubs/orgs will be extracted later via grouping)
   */
  addTeam(teamName, externalId, divisionName, standings = null) {
    this.teams.push({
      name: teamName,
      externalId: externalId,
      divisionName: divisionName,
      sourceSystemId: this.sourceSystemId,
      standings: standings // Attach standings data to team
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
   * Write matches SQL
   */
  writeMatchesSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - CSL
-- Total Records: ${this.matches.length}
-- Match type: 1=league, 3=practice, 4=scrimmage
-- Match status: 1=scheduled, 3=completed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    // Write venues first
    if (this.venues.size > 0) {
      sql += `-- Venues\n`;
      for (const [key, venue] of this.venues) {
        sql += `INSERT INTO venues (name, address) 
VALUES ('${this.escapeSql(venue.name)}', ${venue.address ? `'${this.escapeSql(venue.address)}'` : 'NULL'})
ON CONFLICT (name) DO NOTHING;\n`;
      }
      sql += `\n`;
    }

    // Write matches
    sql += `-- Matches\n`;
    for (const match of this.matches) {
      const matchType = match.matchType === 'league' ? 1 : (match.matchType === 'practice' ? 3 : 4);
      const matchStatus = match.status === 'completed' ? 3 : 1;
      
      sql += `INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT 
  ${matchType}, '${match.matchDate}', ${match.matchTime ? `'${match.matchTime}'` : 'NULL'}, ${matchStatus},
  ht.id, at.id, ${match.venueId ? `v.id` : 'NULL'},
  ${match.homeScore !== null ? match.homeScore : 'NULL'}, ${match.awayScore !== null ? match.awayScore : 'NULL'},
  ${match.sourceSystemId}, ${match.externalId ? `'${match.externalId}'` : 'NULL'}
FROM teams ht
JOIN teams at ON at.external_id = '${match.awayTeamExternalId}' AND at.source_system_id = ${match.sourceSystemId}
${match.venueId ? `LEFT JOIN venues v ON v.name = '${this.escapeSql(Array.from(this.venues.values()).find(v => v.id === match.venueId).name)}'` : ''}
WHERE ht.external_id = '${match.homeTeamExternalId}' AND ht.source_system_id = ${match.sourceSystemId}
ON CONFLICT (source_system_id, external_id) DO NOTHING;\n\n`;
    }

    const outputPath = path.join(__dirname, 'sql', `106.${this.leagueId}-matches-usa-csl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
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
  /**
   * Write teams SQL
   * NEW SCHEMA: Teams must have division_id (NOT NULL FK)
   */
  writeTeamsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CSL
-- Total Records: ${this.teams.length}
-- NOTE: division_id is now part of team identity (NOT NULL)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    for (const team of this.teams) {
      const club = this.clubs.get(team.clubName);
      if (!club) {
        console.error(`ERROR: Club not found for team "${team.name}", clubName="${team.clubName}"`);
        console.error(`Available clubs: ${Array.from(this.clubs.keys()).slice(0,5).join(', ')}...`);
        throw new Error('Club lookup failed');
      }
      
      // Lookup division_id by division name for current season
      // Team identity is now bound to division (same club in different divisions = different teams)
      sql += `INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT '${this.escapeSql(team.name)}', '${team.externalId}', ${club.id}, d.id, ${team.sourceSystemId}
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '${this.getSeasonName()}'
  AND s.league_id = ${this.getLeagueId()}
ON CONFLICT (division_id, name) DO NOTHING;\n`;
    }

    const outputPath = path.join(__dirname, 'sql', `102.${this.leagueId}-teams-usa-csl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Parse match schedules from team detail pages
   */
  parseMatchSchedules() {
    const htmlDir = path.join(__dirname, '../../../scraped-html/csl');
    const files = fs.readdirSync(htmlDir);
    
    for (const file of files) {
      // Skip non-HTML files and the standings file
      if (!file.endsWith('.html') || file.startsWith('tables-') || file.endsWith('.skip')) continue;
      
      const filePath = path.join(htmlDir, file);
      const html = fs.readFileSync(filePath, 'utf-8');
      
      // Extract team external ID from filename (e.g., 10041-228e8c91.html)
      const match = file.match(/^(\d+)-[a-f0-9]+\.html$/);
      if (!match) continue;
      
      const teamExternalId = match[1];
      
      // Parse matches for this team
      const teamMatches = this.matchParser.parse(html, teamExternalId);
      
      // Process each match
      for (const matchData of teamMatches) {
        // Get or create venue
        const venueId = matchData.venue && matchData.venue.name 
          ? this.getOrCreateVenue(matchData.venue.name, matchData.venue.address) 
          : null;
        
        // Add match
        this.addMatch({
          homeTeamExternalId: matchData.homeTeamId,
          awayTeamExternalId: matchData.awayTeamId,
          matchDate: matchData.matchDate,
          matchTime: matchData.matchTime,
          venueId: venueId,
          homeScore: matchData.homeScore,
          awayScore: matchData.awayScore,
          matchType: matchData.matchType || 'league',
          status: matchData.matchStatusId === 2 ? 'completed' : 'scheduled',
          sourceSystemId: this.sourceSystemId,
          externalId: matchData.externalId
        });
      }
    }
  }

  /**
   * Parse player rosters from team detail pages
   */
  parseTeamRosters() {
    const htmlDir = path.join(__dirname, '../../../scraped-html/csl');
    const files = fs.readdirSync(htmlDir).filter(f => 
      f.endsWith('.html') && 
      !f.startsWith('tables-') && 
      !f.endsWith('.skip')
    );
    
    const playersMap = new Map(); // Deduplicate by full name
    let playerId = this.getPlayerIdBase();
    const createdTeams = [];
    
    for (const file of files) {
      // Extract team external_id from filename (e.g., "114828-7c60e4e3.html" -> "114828")
      const teamExternalId = file.match(/^(\d+)-/)?.[1];
      if (!teamExternalId) continue;
      
      // Find team by external_id to get team name
      let team = this.teams.find(t => t.externalId === teamExternalId);
      if (!team) {
        // Skip roster files for teams not in current standings
        // (these are from previous seasons and would create broken placeholder teams)
        continue;
      }
      
      const htmlPath = path.join(htmlDir, file);
      const html = fs.readFileSync(htmlPath, 'utf-8');
      const dom = new JSDOM(html);
      const document = dom.window.document;
      
      // Find roster table (CSL uses same TableRoster class as APSL)
      const tables = document.querySelectorAll('table.TableRoster');
      
      for (const table of tables) {
        const rows = table.querySelectorAll('tr');
        
        for (const row of rows) {
          const cells = row.querySelectorAll('td');
          if (cells.length < 2) continue;
          
          // Jersey number in cells[0] (optional)
          const jerseyNumber = cells[0].textContent.trim() || null;
          
          // Player name is in cells[1], inside a div
          const nameDiv = cells[1].querySelector('div');
          if (!nameDiv) continue;
          
          const fullName = nameDiv.textContent.trim();
          if (!fullName || fullName === 'Name') continue; // Skip header
          
          // Split into first/last name
          const nameParts = fullName.split(/\s+/);
          const firstName = nameParts[0] || fullName;
          const lastName = nameParts.slice(1).join(' ') || fullName;
          
          // Deduplicate: one player can appear on multiple team pages
          const key = fullName.toLowerCase();
          let currentPlayerId;
          
          if (!playersMap.has(key)) {
            currentPlayerId = playerId++;
            playersMap.set(key, { 
              firstName, 
              lastName,
              playerId: currentPlayerId
            });
          } else {
            currentPlayerId = playersMap.get(key).playerId;
          }
          
          // Add roster entry (player-team relationship) using team NAME not external_id
          this.rosters.push({
            playerId: currentPlayerId,
            teamName: team.name,
            jerseyNumber: jerseyNumber
          });
        }
      }
    }
    
    // Convert to array
    this.players = Array.from(playersMap.values());
    
    if (createdTeams.length > 0) {
      console.log(`   ℹ️  Created ${createdTeams.length} placeholder teams from roster files (not in current standings)`);
    }
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
