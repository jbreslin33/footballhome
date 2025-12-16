const Scraper = require('../base/Scraper');
const CsvFetcher = require('../fetchers/CsvFetcher');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const DuplicateDetector = require('../services/DuplicateDetector');
const Team = require('../models/Team');
const Player = require('../models/Player');
const Match = require('../models/Match');
const puppeteer = require('puppeteer');
require('dotenv').config();

/**
 * CASA League Scraper
 * Scrapes CASA Soccer League using Puppeteer for standings and published Google Sheets HTML for rosters
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
    
    // Published Google Sheets HTML URLs for rosters
    this.rosterSheets = {
      liga1: {
        url: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pubhtml',
        name: 'Philadelphia CASA Select Liga 1'
      },
      liga2: {
        url: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pubhtml',
        name: 'Philadelphia CASA Select Liga 2'
      }
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
    
    // Launch Puppeteer with macOS-friendly settings
    this.browser = await puppeteer.launch({
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--disable-gpu'
      ]
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
    // Always fetch team structure (structure mode includes teams)
    await this.fetchLiga1Teams();
    await this.fetchLiga2Teams();
    
    // Fetch schedules if requested
    if (this.shouldScrapeSchedules()) {
      await this.fetchLiga1Schedule();
      await this.fetchLiga2Schedule();
    }
    
    // Fetch rosters from Google Sheets only in players/full mode
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
      this.log(`   Navigating to ${url}...`);
      await page.goto(url, { 
        waitUntil: 'networkidle2'
      });
      
      // Wait for iframe to load
      this.log(`   Waiting for iframe content...`);
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Find the frame with standings data
      const frames = page.frames();
      let standingsFrame = null;
      
      for (const frame of frames) {
        const url = frame.url();
        if (url.includes('sportsengine.com') && url.includes('standings')) {
          standingsFrame = frame;
          break;
        }
      }
      
      if (!standingsFrame) {
        this.logWarning(`No standings iframe found for ${divisionName}`);
        return;
      }
      
      this.log(`   Found standings iframe`);
      
      // Extract team names from standings table in iframe
      const teamNames = await standingsFrame.evaluate(() => {
        const data = [];
        const rows = document.querySelectorAll('table tbody tr');
        
        rows.forEach(row => {
          // Get the row's text content and parse it
          const text = row.innerText || row.textContent;
          const parts = text.split(/\s{2,}|\t/).map(p => p.trim()).filter(p => p);
          
          // Format is: rank teamName pts w l d gp gf ga gd
          // Team name is typically the second element (after rank number)
          if (parts.length >= 2) {
            const rank = parts[0];
            const teamName = parts[1];
            
            // If first part is a number (rank), second part is team name
            if (/^\d+$/.test(rank) && teamName && teamName.length > 2) {
              data.push(teamName);
            }
          }
        });
        return data;
      });
      
      this.log(`   Extracted ${teamNames.length} team names`);
      
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
      this.log(`   Navigating to schedule...`);
      await page.goto(url, { waitUntil: 'networkidle2' });
      
      // Wait for iframe to load
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Find the frame with schedule data
      const frames = page.frames();
      let scheduleFrame = null;
      
      for (const frame of frames) {
        const frameUrl = frame.url();
        if (frameUrl.includes('sportsengine.com') && frameUrl.includes('schedule')) {
          scheduleFrame = frame;
          break;
        }
      }
      
      if (!scheduleFrame) {
        this.logWarning(`No schedule iframe found for ${divisionName}`);
        return;
      }
      
      this.log(`   Found schedule iframe`);
      
      // Extract match data from iframe
      const rawRows = await scheduleFrame.evaluate(() => {
        const rows = [];
        const tableRows = document.querySelectorAll('table tbody tr');
        tableRows.forEach(row => {
          const text = row.innerText || row.textContent;
          if (text && text.trim()) {
            rows.push(text.trim());
          }
        });
        return rows;
      });
      
      // Parse matches
      let matchCount = 0;
      for (const rowData of rawRows) {
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
    this.log('👥 Fetching rosters from published Google Sheets...');
    
    // Fetch Liga 1 rosters (each tab = one team)
    await this.fetchRostersFromPublishedSheet(
      this.rosterSheets.liga1.url,
      this.rosterSheets.liga1.name,
      '9f708557-d2bf-4192-82f5-9ea58a3978cc' // Liga 1 division ID
    );
    
    // Fetch Liga 2 rosters (each tab = one team)
    await this.fetchRostersFromPublishedSheet(
      this.rosterSheets.liga2.url,
      this.rosterSheets.liga2.name,
      'a8e19668-3cc0-4283-93e6-0fb69b4a4d33' // Liga 2 division ID
    );
  }

  async fetchRostersFromPublishedSheet(url, sheetName, divisionId) {
    try {
      this.log(`   Loading ${sheetName}...`);
      
      const page = await this.browser.newPage();
      await page.goto(url, { waitUntil: 'networkidle2' });
      
      // Extract tab data from JavaScript (items.push({name: "...", pageUrl: "...", gid: "..."}))
      const tabs = await page.evaluate(() => {
        // Parse the JavaScript items array from the page source
        const scriptText = document.body.parentElement.innerHTML;
        const itemsMatch = scriptText.match(/items\.push\({[^}]+}\);/g);
        if (!itemsMatch) return [];
        
        const tabs = [];
        for (const match of itemsMatch) {
          const nameMatch = match.match(/name:\s*"([^"]+)"/);
          const urlMatch = match.match(/pageUrl:\s*"([^"]+)"/);
          const gidMatch = match.match(/gid:\s*"([^"]+)"/);
          
          if (nameMatch && urlMatch && gidMatch) {
            tabs.push({
              name: nameMatch[1],
              url: urlMatch[1].replace(/\\/g, ''),
              gid: gidMatch[1]
            });
          }
        }
        return tabs;
      });
      
      this.log(`   Found ${tabs.length} tabs in ${sheetName}`);
      
      // Process each tab
      for (const tab of tabs) {
        const teamName = tab.name;
        
        // Skip template/hidden sheets
        if (teamName.toLowerCase().includes('template')) {
          continue;
        }
        
        this.log(`      Processing ${teamName}...`);
        
        // Navigate to the tab's direct URL
        await page.goto(tab.url, { waitUntil: 'networkidle2' });
        await new Promise(resolve => setTimeout(resolve, 500)); // Wait for content to load
        
        // Find the team in our data (with fuzzy matching)
        let teamId = null;
        const normalizedTabName = this.normalizeTeamName(teamName);
        
        for (const [id, team] of this.data.teams.entries()) {
          const normalizedTeamName = this.normalizeTeamName(team.name);
          
          // Exact match
          if (normalizedTeamName === normalizedTabName) {
            teamId = id;
            break;
          }
          
          // Partial match (either name contains the other)
          if (normalizedTeamName.includes(normalizedTabName) || normalizedTabName.includes(normalizedTeamName)) {
            teamId = id;
            break;
          }
        }
        
        if (!teamId) {
          this.logWarning(`      Team "${teamName}" not found in standings data (normalized: "${normalizedTabName}"), skipping roster`);
          continue;
        }
        
        // Extract headers and player data from table
        const tableData = await page.$$eval('table tbody tr', rows => {
          if (rows.length === 0) return { headers: [], players: [] };
          
          // Find the header row (contains "First Name" and "Last Name")
          let headerRowIndex = -1;
          let headers = [];
          
          for (let i = 0; i < rows.length; i++) {
            const cells = Array.from(rows[i].querySelectorAll('td')).map(cell => cell.textContent.trim());
            const text = cells.join(' ').toLowerCase();
            if (text.includes('first name') && text.includes('last name')) {
              headerRowIndex = i;
              headers = cells.map(c => c.toLowerCase());
              break;
            }
          }
          
          if (headerRowIndex === -1) return { headers: [], players: [] };
          
          // Extract player rows (everything after header row)
          const players = [];
          for (let i = headerRowIndex + 1; i < rows.length; i++) {
            const cells = Array.from(rows[i].querySelectorAll('td')).map(cell => cell.textContent.trim());
            if (cells.length > 0 && cells.some(c => c !== '')) {
              players.push({ raw: cells });
            }
          }
          
          return { headers, players };
        });
        
        const headers = tableData.headers;
        const players = tableData.players;
        
        if (players.length === 0) {
          this.logWarning(`      No players in ${teamName}`);
          continue;
        }
        
        // Parse players
        let playerCount = 0;
        for (const playerData of players) {
          const cells = playerData.raw;
          
          // Map cells to fields using header names
          const firstName = this.getCellValue(cells, headers, ['first name', 'firstname', 'first', 'name']);
          const lastName = this.getCellValue(cells, headers, ['last name', 'lastname', 'last', 'surname']);
          const jerseyNumber = this.getCellValue(cells, headers, ['jersey', 'jersey number', 'number', '#']);
          const position = this.getCellValue(cells, headers, ['position', 'pos']);
          
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
          playerCount++;
        }
        
        this.log(`      ✓ ${teamName}: ${playerCount} players`);
      }
      
      await page.close();
      
    } catch (error) {
      this.logError(`Failed to fetch rosters from ${sheetName}`, error);
    }
  }
  
  // Helper to get cell value by trying multiple column names (case-insensitive)
  getCellValue(cells, headers, possibleNames) {
    for (const name of possibleNames) {
      const index = headers.findIndex(h => h === name);
      if (index !== -1 && cells[index]) {
        return cells[index].trim();
      }
    }
    return null;
  }

  // Normalize team names for matching (remove accents, special characters, standardize)
  normalizeTeamName(name) {
    let normalized = name
      .toLowerCase()
      .normalize('NFD') // Decompose accented characters
      .replace(/[\u0300-\u036f]/g, ''); // Remove diacritics
    
    // Expand common abbreviations BEFORE removing suffixes
    normalized = normalized
      .replace(/\bphila\b/g, 'philadelphia')
      .replace(/\bphl\b/g, 'philadelphia')
      .replace(/\bphilly\b/g, 'philadelphia')
      .replace(/\bcf\b/g, 'club de futbol')
      .replace(/\bpsc\b/g, 'philadelphia');
    
    // Remove common team suffixes and variations (multiple passes)
    const suffixes = ['fc', 'sc', 'united', 'ii', 'i', 'club', 'scm', 'scr', 'de futbol', 'soccer'];
    for (const suffix of suffixes) {
      normalized = normalized.replace(new RegExp(`\\s+${suffix}\\b`, 'gi'), '');
    }
    
    // Remove spaces between words for compound names
    normalized = normalized
      .replace(/black\s+stars/g, 'blackstars');
    
    return normalized.replace(/\s+/g, ' ').trim();
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
      this.log('Closing browser...');
      await this.browser.close();
      this.log('Browser closed');
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
