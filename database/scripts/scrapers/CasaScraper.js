const Scraper = require('../base/Scraper');
const CsvFetcher = require('../fetchers/CsvFetcher');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const DuplicateDetector = require('../services/DuplicateDetector');
const Team = require('../models/Team');
const Player = require('../models/Player');
const Match = require('../models/Match');
const puppeteer = require('puppeteer');

/**
 * CASA League Scraper
 * Scrapes CASA Soccer League using Puppeteer for dynamic content + Google Sheets for rosters
 */
class CasaScraper extends Scraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'CASA',
      mode: mode,
      includeSchedules: options.includeSchedules || false,
      teamFilter: options.teamFilter || null
    });

    this.leagueId = '00000000-0000-0000-0001-000000000002';
    this.sportId = '550e8400-e29b-41d4-a716-446655440101';
    
    // CASA URLs
    this.urls = {
      liga1Standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090889',
      liga1Schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889',
      liga2Standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9096430',
      liga2Schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430'
    };
    
    // Google Sheets roster CSVs
    this.rosterUrls = {
      liga1: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pub?gid=480494399&output=csv',
      liga2: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pub?gid=310279135&output=csv'
    };
    
    // Services
    this.csvFetcher = new CsvFetcher();
    this.duplicateDetector = new DuplicateDetector();
    this.sqlGenerator = new SqlGenerator();
    
    // Puppeteer browser
    this.browser = null;
  }

  async initialize() {
    this.log('Initializing CASA scraper...');
    
    // Launch Puppeteer
    this.browser = await puppeteer.launch({
      headless: "new",
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    // Create conference and divisions
    const confId = IdGenerator.fromComponents('casa', 'conference', 'CASA Conference');
    this.data.conferences.set(confId, {
      id: confId,
      league_id: this.leagueId,
      name: 'CASA Conference',
      display_name: 'CASA Conference',
      slug: 'casa-conference'
    });
    
    const liga1Id = IdGenerator.fromComponents('casa', 'division', 'Liga 1');
    this.data.divisions.set(liga1Id, {
      id: liga1Id,
      conference_id: confId,
      name: 'Liga 1',
      display_name: 'Liga 1',
      slug: 'liga-1',
      tier: 1
    });
    
    const liga2Id = IdGenerator.fromComponents('casa', 'division', 'Liga 2');
    this.data.divisions.set(liga2Id, {
      id: liga2Id,
      conference_id: confId,
      name: 'Liga 2',
      display_name: 'Liga 2',
      slug: 'liga-2',
      tier: 2
    });
    
    this.divisionIds = { liga1Id, liga2Id };
  }

  async fetchData() {
    // Fetch structure (teams and schedule)
    if (this.shouldScrapeTeams()) {
      await this.fetchLiga1Teams();
      await this.fetchLiga2Teams();
      
      if (this.shouldScrapeSchedules()) {
        await this.fetchLiga1Schedule();
        await this.fetchLiga2Schedule();
      }
    }
    
    // Fetch rosters from Google Sheets
    if (this.shouldScrapePlayers()) {
      await this.fetchRosters();
    }
  }

  async fetchLiga1Teams() {
    this.log('\n⚽ Fetching Liga 1 teams...');
    await this.fetchTeamsFromStandings(this.urls.liga1Standings, this.divisionIds.liga1Id, 'Liga 1');
  }

  async fetchLiga2Teams() {
    this.log('\n⚽ Fetching Liga 2 teams...');
    await this.fetchTeamsFromStandings(this.urls.liga2Standings, this.divisionIds.liga2Id, 'Liga 2');
  }

  async fetchTeamsFromStandings(url, divisionId, divisionName) {
    const page = await this.browser.newPage();
    
    try {
      await page.goto(url, { waitUntil: 'networkidle2' });
      
      // Wait for table
      try {
        await page.waitForSelector('table tbody tr', { timeout: 10000 });
      } catch (e) {
        this.logWarning(`Timeout waiting for ${divisionName} table`);
      }
      
      // Extract team names from standings table
      const teamNames = await page.evaluate(() => {
        const data = [];
        const rows = document.querySelectorAll('table tbody tr');
        rows.forEach(row => {
          const cells = row.querySelectorAll('td');
          if (cells.length > 0) {
            let name = cells[0].textContent.trim();
            // If first cell is a number, team name is in second cell
            if (/^\d+$/.test(name) && cells.length > 1) {
              name = cells[1].textContent.trim();
            }
            if (name && name !== 'Team' && name.length > 2) {
              data.push(name);
            }
          }
        });
        return data;
      });
      
      for (const teamName of teamNames) {
        if (!this.matchesTeamFilter(teamName)) {
          this.log(`   ⊘ Skipping ${teamName} (filtered out)`);
          continue;
        }
        
        const clubId = IdGenerator.fromComponents('casa', 'club', teamName);
        const sportDivId = IdGenerator.fromComponents('casa', 'sportdiv', teamName);
        const teamId = IdGenerator.fromComponents('casa', 'team', teamName);
        
        // Create club
        if (!this.data.clubs.has(clubId)) {
          this.data.clubs.set(clubId, {
            id: clubId,
            name: teamName,
            display_name: teamName,
            slug: this.slugify(teamName)
          });
        }
        
        // Create sport division
        if (!this.data.sportDivisions.has(sportDivId)) {
          this.data.sportDivisions.set(sportDivId, {
            id: sportDivId,
            club_id: clubId,
            sport_id: this.sportId,
            name: teamName,
            display_name: teamName,
            slug: this.slugify(teamName)
          });
        }
        
        // Create team
        const team = new Team({
          id: teamId,
          name: teamName,
          sport_division_id: sportDivId,
          league_division_id: divisionId
        });
        
        this.data.teams.set(teamId, team);
        this.log(`   ✓ ${teamName}`);
      }
      
    } catch (error) {
      this.logError(`Failed to fetch ${divisionName} teams`, error);
    } finally {
      await page.close();
    }
  }

  async fetchLiga1Schedule() {
    this.log('\n📅 Fetching Liga 1 schedule...');
    await this.fetchSchedule(this.urls.liga1Schedule, 'Liga 1');
  }

  async fetchLiga2Schedule() {
    this.log('\n📅 Fetching Liga 2 schedule...');
    await this.fetchSchedule(this.urls.liga2Schedule, 'Liga 2');
  }

  async fetchSchedule(url, divisionName) {
    const page = await this.browser.newPage();
    
    try {
      await page.goto(url, { waitUntil: 'networkidle2' });
      
      try {
        await page.waitForSelector('table tbody tr', { timeout: 10000 });
      } catch (e) {
        this.logWarning(`Timeout waiting for ${divisionName} schedule table`);
      }
      
      // Extract match data
      const rowsData = await page.evaluate(() => {
        const rawRows = [];
        const rows = document.querySelectorAll('table tbody tr');
        rows.forEach(row => {
          const cells = row.querySelectorAll('td');
          const rowData = [];
          cells.forEach(cell => rowData.push(cell.textContent.trim()));
          if (rowData.length > 0) rawRows.push(rowData);
        });
        return rawRows;
      });
      
      // Parse matches
      let matchCount = 0;
      for (const rowData of rowsData) {
        const match = this.parseMatchRow(rowData, divisionName);
        if (match) {
          this.data.matches.set(match.event_id, match);
          matchCount++;
        }
      }
      
      this.log(`   Found ${matchCount} matches`);
      
    } catch (error) {
      this.logError(`Failed to fetch ${divisionName} schedule`, error);
    } finally {
      await page.close();
    }
  }

  parseMatchRow(rowData, divisionName) {
    let dateText = '';
    let homeText = '';
    let awayText = '';
    
    // Find team names and date in row
    for (const text of rowData) {
      // Check if it's a team name
      const isTeam = Array.from(this.data.teams.values()).some(t => t.name === text);
      if (isTeam) {
        if (!homeText) homeText = text;
        else if (!awayText) awayText = text;
      }
      
      // Check if it's a date (MM/DD or MM-DD format)
      if (!dateText && /\d{1,2}[\/-]\d{1,2}/.test(text)) {
        dateText = text;
      }
    }
    
    if (!dateText || !homeText || !awayText) {
      return null;
    }
    
    // Find team IDs
    const homeTeam = Array.from(this.data.teams.values()).find(t => t.name === homeText);
    const awayTeam = Array.from(this.data.teams.values()).find(t => t.name === awayText);
    
    if (!homeTeam || !awayTeam) {
      return null;
    }
    
    const eventId = IdGenerator.fromComponents('casa', 'match', dateText, homeText, awayText);
    
    return new Match({
      event_id: eventId,
      name: `${homeText} vs ${awayText}`,
      event_type_id: '550e8400-e29b-41d4-a716-446655440402', // MATCH_EVENT_TYPE_ID
      start_time: dateText,
      home_team_id: homeTeam.id,
      away_team_id: awayTeam.id,
      created_by: '77d77471-1250-47e0-81ab-d4626595d63c',
      source_app_id: '550e8400-e29b-41d4-a716-446655440311',
      external_source: 'casa'
    });
  }

  async fetchRosters() {
    this.log('\n👥 Fetching rosters from Google Sheets...');
    
    // Liga 1 roster
    await this.fetchRosterFromCsv(this.rosterUrls.liga1, 'Liga 1');
    
    // Liga 2 roster
    await this.fetchRosterFromCsv(this.rosterUrls.liga2, 'Liga 2');
  }

  async fetchRosterFromCsv(url, divisionName) {
    try {
      const rows = await this.csvFetcher.fetch(url);
      
      if (rows.length === 0) {
        this.logWarning(`No data in ${divisionName} roster CSV`);
        return;
      }
      
      // Skip header row
      const dataRows = rows.slice(1);
      
      for (const row of dataRows) {
        // Typical columns: First Name, Last Name, Jersey #, Position, etc.
        const firstName = row[0]?.trim();
        const lastName = row[1]?.trim();
        const jerseyNumber = row[2]?.trim();
        const position = row[3]?.trim();
        
        if (!firstName || !lastName) continue;
        
        // Check for duplicates
        if (this.duplicateDetector.isDuplicate('player', { firstName, lastName }, ['firstName', 'lastName'])) {
          continue;
        }
        
        const playerId = IdGenerator.fromComponents('player', firstName, lastName);
        const player = new Player({
          id: playerId,
          first_name: firstName,
          last_name: lastName,
          jersey_number: jerseyNumber || null,
          position: position || null
        });
        
        this.data.players.set(playerId, player);
        this.duplicateDetector.markSeen('player', { firstName, lastName }, ['firstName', 'lastName']);
      }
      
      this.log(`   ${divisionName}: ${dataRows.length} players`);
      
    } catch (error) {
      this.logError(`Failed to fetch ${divisionName} roster`, error);
    }
  }

  async transformData() {
    // Apply team filter if specified
    if (this.hasTeamFilter()) {
      this.applyTeamFilter();
    }
  }

  applyTeamFilter() {
    // Filter teams
    for (const [id, team] of this.data.teams.entries()) {
      if (!this.matchesTeamFilter(team.name)) {
        this.data.teams.delete(id);
      }
    }
  }

  async generateOutput() {
    this.log('\n💾 Generating SQL output...');
    
    const results = await this.sqlGenerator.generateMultiple([
      {
        filename: '06-clubs-casa.sql',
        data: this.data.clubs,
        options: {
          title: 'CASA Clubs',
          useInserts: true
        }
      },
      {
        filename: '07-sport-divisions-casa.sql',
        data: this.data.sportDivisions,
        options: {
          title: 'CASA Sport Divisions',
          useInserts: true
        }
      },
      {
        filename: '22-teams-casa.sql',
        data: this.data.teams,
        options: {
          title: 'CASA Teams',
          useInserts: true
        }
      },
      {
        filename: '08b-users-casa.sql',
        data: this.data.players,
        options: {
          title: 'CASA Players (Users)',
          useInserts: true
        }
      },
      {
        filename: '25-schedule-casa.sql',
        data: this.data.matches,
        options: {
          title: 'CASA Match Schedule',
          useInserts: true
        }
      }
    ]);
    
    for (const result of results) {
      this.logSuccess(`${result.filepath}: ${result.count} records`);
    }
  }

  async cleanup() {
    if (this.browser) {
      await this.browser.close();
    }
  }

  slugify(text) {
    return text.toString().toLowerCase()
      .replace(/\s+/g, '-')
      .replace(/[^\w\-]+/g, '')
      .replace(/\-\-+/g, '-')
      .replace(/^-+/, '')
      .replace(/-+$/, '');
  }
}

module.exports = CasaScraper;
