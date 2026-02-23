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
const ApslMatchParser = require('../../infrastructure/parsers/ApslMatchParser');

class ApslSqlGenerator extends BaseGenerator {
  constructor() {
    const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf8'));
    super(config.leagueName, config.sourceSystemId, config.fileCode, config.orgIdBase, config.clubIdBase, config.teamIdBase);
    this.config = config;
    
    this.matchParser = new ApslMatchParser();
  }

  getLeagueFolder() {
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
    console.log('\n📄 Generating APSL SQL from HTML...');
    
    // Read standings HTML
    const standingsHtml = this.readStandingsHtml();
    
    // Parse teams and standings
    this.parseStandingsPage(standingsHtml);
    
    console.log(`   Found ${this.teams.length} teams with standings data`);
    
    // Parse rosters from team detail pages
    this.parseTeamRosters();
    
    console.log(`   Parsed ${this.players.length} players from team rosters`);
    console.log(`   Parsed ${this.rosters.length} roster entries (player-team relationships)`);
    
    // Parse match schedules from team detail pages (NEW)
    this.parseMatchSchedules();
    
    console.log(`   Parsed ${this.matches.length} matches`);
    
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
    this.writeStandingsSql();
    this.writePlayersSql();
    this.writeRostersSql();  // NEW: Write roster relationships
    this.writeMatchesSql();  // NEW
    
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
    
    // Select the file that matches the active season (not just most recent by mtime)
    const targetSeason = this.getSeasonName();
    const { JSDOM: JSDOMCheck } = require('jsdom');
    
    for (const file of files) {
      const html = fs.readFileSync(file.path, 'utf-8');
      const dom = new JSDOMCheck(html);
      const firstHeading = dom.window.document.querySelector('.leagueAccordTitle1');
      if (firstHeading) {
        const headingText = firstHeading.textContent.trim();
        if (headingText.startsWith(targetSeason)) {
          console.log(`   Reading: ${file.path} (season: ${targetSeason})`);
          return html;
        }
      }
    }
    
    // Fallback: use first file if no season match found
    console.warn(`   ⚠️  No HTML file found for season ${targetSeason}, using most recent file`);
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
    let playerId = this.getPlayerIdBase();
    const createdTeams = [];
    
    // Collect roster files, preferring new format (apsl-team-*) over old format (NNNNN-*)
    const rosterFiles = new Map(); // external_id -> filename
    for (const file of files) {
      if (!file.endsWith('.html') || file.includes('tables-') || file.endsWith('.skip')) continue;
      
      // New format: apsl-team-114812-46798c01.html
      const newMatch = file.match(/^apsl-team-(\d+)-[a-f0-9]+\.html$/);
      if (newMatch) {
        rosterFiles.set(newMatch[1], file); // Always prefer new format
        continue;
      }
      
      // Old format: 114812-bc27d2da.html (only use if no new format exists)
      const oldMatch = file.match(/^(\d+)-[a-f0-9]+\.html$/);
      if (oldMatch && !rosterFiles.has(oldMatch[1])) {
        rosterFiles.set(oldMatch[1], file);
      }
    }
    
    for (const [teamExternalId, file] of rosterFiles) {
      const filePath = path.join(htmlDir, file);
      const html = fs.readFileSync(filePath, 'utf-8');
      const dom = new JSDOM(html);
      const document = dom.window.document;
      
      // Find team by external_id to get team name
      let team = this.teams.find(t => t.externalId === teamExternalId);
      if (!team) {
        // Skip roster files for teams not in current standings
        // (these are from previous seasons and would create broken placeholder teams)
        continue;
      }
      
      // Find roster table
      const rosterTable = document.querySelector('table.TableRoster');
      if (!rosterTable) continue;
      
      // Parse player rows
      const rows = rosterTable.querySelectorAll('tr');
      for (const row of rows) {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) continue;
        
        // Jersey number is in first cell (optional)
        const jerseyNumber = cells[0].textContent.trim() || null;
        
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
        let currentPlayerId;
        
        if (!uniquePlayers.has(key)) {
          currentPlayerId = playerId++;
          uniquePlayers.set(key, {
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
            playerId: currentPlayerId
          });
        } else {
          currentPlayerId = uniquePlayers.get(key).playerId;
        }
        
        // Add roster entry (player-team relationship) using team NAME not external_id
        this.rosters.push({
          playerId: currentPlayerId,
          teamName: team.name,
          jerseyNumber: jerseyNumber
        });
      }
    }
    
    // Convert to array (just the player info, not roster data)
    this.players = Array.from(uniquePlayers.values());
    
    if (createdTeams.length > 0) {
      console.log(`   ℹ️  Created ${createdTeams.length} placeholder teams from roster files (not in current standings)`);
    }
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
   * Parse match schedules from team HTML files (NEW)
   */
  parseMatchSchedules() {
    const htmlDir = path.join(__dirname, '../../../../database/scraped-html/apsl');
    const files = fs.readdirSync(htmlDir);
    
    for (const file of files) {
      // Skip non-HTML files and the standings file
      if (!file.endsWith('.html') || file.includes('tables-') || file.endsWith('.skip')) continue;
      
      const filePath = path.join(htmlDir, file);
      const html = fs.readFileSync(filePath, 'utf-8');
      
      // Extract team external ID from filename (e.g., apsl-team-12345-hash.html or team-12345.html)
      const match = file.match(/(?:apsl-)?team-(\d+)(?:-[a-f0-9]+)?\.html/);
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
  /**
   * Write teams SQL
   * NEW SCHEMA: Teams must have division_id (NOT NULL FK)
   */
  writeTeamsSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - APSL
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
SELECT '${this.escapeSql(team.name)}', '${team.externalId}', ${club.id}, d.id, ${team.sourceSystemId}
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '${this.getSeasonName()}'
  AND s.league_id = ${this.getLeagueId()}
ON CONFLICT (division_id, name) DO NOTHING;\n`;
    }

    const outputPath = path.join(__dirname, 'sql', `102.${this.leagueId}-teams-usa-apsl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write matches SQL (NEW)
   */
  writeMatchesSql() {
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Matches - APSL
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

    const outputPath = path.join(__dirname, 'sql', `106.${this.leagueId}-matches-usa-apsl.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }
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
