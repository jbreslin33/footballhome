const Scraper = require('../base/Scraper');
const CsvFetcher = require('../fetchers/CsvFetcher');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const DuplicateDetector = require('../services/DuplicateDetector');
const Club = require('../models/Club');
const SportDivision = require('../models/SportDivision');
const Team = require('../models/Team');
const Player = require('../models/Player');
const TeamPlayer = require('../models/TeamPlayer');
const Match = require('../models/Match');
const LeagueConference = require('../models/LeagueConference');
const LeagueDivision = require('../models/LeagueDivision');
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
    
    // CASA Conferences Configuration
    // Each conference can have multiple divisions (ligas)
    this.conferences = {
      philadelphia: {
        name: 'Philadelphia',
        divisions: {
          liga1: {
            name: 'Liga 1',
            tier: 1,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090889',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pubhtml'
          },
          liga2: {
            name: 'Liga 2',
            tier: 2,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9096430',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pubhtml'
          }
        }
      },
      boston: {
        name: 'Boston',
        divisions: {
          liga1: {
            name: 'Liga 1',
            tier: 1,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090891',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090891',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/1OnHnhrSRA3Wp2eCs_9-dJhDBlVhSEoobFDGTYvQTfvE/export?format=html'
          }
        }
      },
      lancaster: {
        name: 'Lancaster',
        divisions: {
          liga1: {
            name: 'Liga 1',
            tier: 1,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090893',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090893',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/1alzJMAccMT5IIBQ_YOAp6FMbADnfC77dxRMZtceMau4/export?format=html'
          }
        }
      },
      centralNJ: {
        name: 'Central NJ',
        divisions: {
          liga1: {
            name: 'Liga 1',
            tier: 1,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9124981',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9124981',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/1tStu09AvdhBJtYLXl49R-oa5XgFYDo9j/export?format=html'
          }
        }
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
    
    // Create conferences and divisions from configuration
    this.divisionIds = {};
    
    for (const [confKey, confData] of Object.entries(this.conferences)) {
      // Create conference
      const confId = IdGenerator.fromComponents('casa', 'conference', confData.name);
      this.data.conferences.set(confId, new LeagueConference({
        id: confId,
        league_id: this.leagueId,
        name: confData.name,
        display_name: confData.name,
        slug: confData.name.toLowerCase().replace(/\s+/g, '-')
      }));
      
      this.log(`Created conference: ${confData.name} (${confId})`);
      
      // Create divisions for this conference
      for (const [divKey, divData] of Object.entries(confData.divisions)) {
        const divId = IdGenerator.fromComponents('casa', 'division', `${confData.name} ${divData.name}`);
        this.data.divisions.set(divId, new LeagueDivision({
          id: divId,
          conference_id: confId,
          name: divData.name,
          display_name: `${confData.name} ${divData.name}`,
          slug: `${confData.name.toLowerCase().replace(/\s+/g, '-')}-${divData.name.toLowerCase().replace(/\s+/g, '-')}`,
          tier: divData.tier
        }));
        
        // Store division ID for later reference
        this.divisionIds[`${confKey}_${divKey}`] = divId;
        
        this.log(`  Created division: ${confData.name} ${divData.name} (${divId})`);
      }
    }
  }

  async fetchData() {
    // Loop through all conferences and divisions
    for (const [confKey, confData] of Object.entries(this.conferences)) {
      this.log(`\n📍 Processing ${confData.name} Conference...`);
      
      for (const [divKey, divData] of Object.entries(confData.divisions)) {
        const divisionId = this.divisionIds[`${confKey}_${divKey}`];
        const divisionName = `${confData.name} ${divData.name}`;
        
        // Always fetch team structure (structure mode includes teams)
        this.log(`\n⚽ Fetching ${divisionName} teams...`);
        await this.fetchTeamsFromStandings(divData.standings, divisionId, divisionName);
        
        // Fetch schedules if requested
        if (this.shouldScrapeSchedules()) {
          this.log(`\n📅 Fetching ${divisionName} schedule...`);
          await this.fetchSchedule(divData.schedule, divisionName);
        }
        
        // Fetch rosters from Google Sheets only in players/full mode
        if (this.shouldScrapePlayers() && divData.rosterSheet) {
          this.log(`\n👥 Fetching ${divisionName} rosters...`);
          await this.fetchRostersFromPublishedSheet(divData.rosterSheet, divisionName, divisionId);
        }
      }
    }
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
        
        // Generate consistent IDs based on normalized name (not league-specific)
        const normalizedName = teamName.trim();
        const clubId = IdGenerator.fromComponents('club', normalizedName);
        const sportDivId = IdGenerator.fromComponents('sportdiv', normalizedName);
        const teamId = IdGenerator.fromComponents('casa', 'team', normalizedName, divisionName);
        
        // Create club (reuse if already exists from another league)
        if (!this.data.clubs.has(clubId)) {
          const club = new Club({
            id: clubId,
            name: normalizedName,
            display_name: normalizedName,
            slug: this.slugify(normalizedName)
          });
          this.data.clubs.set(clubId, club);
        }
        
        // Create sport division (reuse if already exists from another league)
        if (!this.data.sportDivisions.has(sportDivId)) {
          const sportDiv = new SportDivision({
            id: sportDivId,
            club_id: clubId,
            sport_id: this.sportId,
            name: `${normalizedName} Soccer`,
            display_name: `${normalizedName} Soccer`,
            slug: this.slugify(normalizedName)
          });
          this.data.sportDivisions.set(sportDivId, sportDiv);
        }
        
        // Create team (each team is unique per league division)
        const team = new Team({
          id: teamId,
          name: normalizedName,
          sport_division_id: sportDivId,
          league_division_id: divisionId
        });
        
        this.data.teams.set(teamId, team);
        this.log(`   ✓ ${normalizedName}`);
      }
      
    } catch (error) {
      this.logError(`Failed to fetch ${divisionName} teams`, error);
    } finally {
      await page.close();
    }
  }

  async fetchSchedule(url, divisionName) {
    const page = await this.browser.newPage();
    
    try {
      this.log(`   Navigating to schedule...`);
      await page.goto(url, { waitUntil: 'networkidle2' });
      
      // Wait longer for iframe content to load (schedule loads slower than standings)
      this.log(`   Waiting for iframe content to load...`);
      await new Promise(resolve => setTimeout(resolve, 5000));
      
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
      
      this.log(`   Found schedule iframe: ${scheduleFrame.url()}`);
      
      // Check what's actually in the iframe without waiting for table
      const frameContent = await scheduleFrame.evaluate(() => {
        const html = document.body.innerHTML;
        const text = document.body.innerText || document.body.textContent;
        
        return {
          htmlLength: html.length,
          textLength: text.length,
          textPreview: text.substring(0, 500),
          htmlPreview: html.substring(0, 1000),
          hasTable: document.querySelectorAll('table').length > 0,
          hasDivs: document.querySelectorAll('div').length,
          hasSchedule: text.toLowerCase().includes('schedule'),
          hasNoGames: text.toLowerCase().includes('no games') || text.toLowerCase().includes('no matches')
        };
      });
      
      this.log(`   Iframe content: ${frameContent.textLength} chars, ${frameContent.hasDivs} divs, table=${frameContent.hasTable}`);
      
      if (frameContent.hasNoGames) {
        this.logWarning(`Schedule appears empty (no games published)`);
        return;
      }
      
      // Schedule uses div-based structure, not tables
      // Extract match data from divs (different from standings approach)
      const matchData = await scheduleFrame.evaluate(() => {
        const data = [];
        
        // Get all text content and split by newlines
        const text = document.body.innerText || document.body.textContent;
        const lines = text.split('\n').map(l => l.trim()).filter(l => l);
        
        // Parse matches - looking for date pattern followed by teams
        let currentDate = '';
        let currentTime = '';
        let i = 0;
        
        while (i < lines.length) {
          const line = lines[i];
          
          // Check if this is a date line (e.g., "Sun Nov 9", "Mon Dec 15")
          if (/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s+[A-Z][a-z]+\s+\d{1,2}$/.test(line)) {
            currentDate = line;
            i++;
            
            // Next line is usually the time
            if (i < lines.length && /\d{1,2}:\d{2}\s+(AM|PM|EST|EDT)/.test(lines[i])) {
              currentTime = lines[i];
              i++;
            }
            
            // Skip "FINAL", "SCHEDULED", etc status lines
            while (i < lines.length && /^(FINAL|SCHEDULED|POSTPONED|CANCELLED)$/.test(lines[i])) {
              i++;
            }
            
            // Next two non-empty lines should be team names
            let homeTeam = '';
            let awayTeam = '';
            let score = '';
            
            // Get home team (skip lines with just parentheses/records)
            while (i < lines.length) {
              if (lines[i] && !lines[i].match(/^\([0-9\s\-]+\)$/) && !lines[i].match(/^\d+\s*-\s*\d+$/)) {
                homeTeam = lines[i];
                i++;
                break;
              }
              i++;
            }
            
            // Skip record in parentheses
            if (i < lines.length && lines[i].match(/^\([0-9\s\-]+\)$/)) {
              i++;
            }
            
            // Get score if present
            if (i < lines.length && lines[i].match(/^\d+\s*-\s*\d+$/)) {
              score = lines[i];
              i++;
            }
            
            // Skip "Game recap" or similar
            if (i < lines.length && lines[i].toLowerCase().includes('recap')) {
              i++;
            }
            
            // Get away team
            while (i < lines.length) {
              if (lines[i] && !lines[i].match(/^\([0-9\s\-]+\)$/) && !lines[i].match(/^\d+\s*-\s*\d+$/)) {
                awayTeam = lines[i];
                i++;
                break;
              }
              i++;
            }
            
            if (homeTeam && awayTeam && currentDate) {
              data.push({
                date: currentDate,
                time: currentTime,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                score: score
              });
            }
          } else {
            i++;
          }
        }
        
        return data;
      });
      
      this.log(`   Extracted ${matchData.length} matches from schedule`);
      
      // Parse matches
      let matchCount = 0;
      for (const matchInfo of matchData) {
        const match = this.parseMatchFromDiv(matchInfo, divisionName);
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

  parseMatchFromDiv(matchInfo, divisionName) {
    // matchInfo: { date, time, homeTeam, awayTeam, score }
    const { date, time, homeTeam, awayTeam, score } = matchInfo;
    
    if (!date || !homeTeam || !awayTeam) {
      return null;
    }
    
    // Find matching teams using normalization
    const teamNames = Array.from(this.data.teams.values()).map(t => t.name);
    
    const findTeam = (name) => {
      return teamNames.find(teamName => {
        const normalized1 = this.normalizeTeamName(teamName);
        const normalized2 = this.normalizeTeamName(name);
        return normalized1 === normalized2 || 
               normalized1.includes(normalized2) || 
               normalized2.includes(normalized1);
      });
    };
    
    const matchedHome = findTeam(homeTeam);
    const matchedAway = findTeam(awayTeam);
    
    if (!matchedHome || !matchedAway) {
      this.logWarning(`Could not match teams: "${homeTeam}" vs "${awayTeam}"`);
      return null;
    }
    
    // Find team IDs
    const homeTeamObj = Array.from(this.data.teams.values()).find(t => t.name === matchedHome);
    const awayTeamObj = Array.from(this.data.teams.values()).find(t => t.name === matchedAway);
    
    if (!homeTeamObj || !awayTeamObj) {
      return null;
    }
    
    // Parse date and time into a timestamp
    const eventDateTime = time ? `${date} ${time}` : date;
    
    const eventId = IdGenerator.fromComponents('casa', 'match', date, matchedHome, matchedAway);
    
    return new Match({
      event_id: eventId,
      name: `${matchedHome} vs ${matchedAway}`,
      event_type_id: '550e8400-e29b-41d4-a716-446655440402', // MATCH_EVENT_TYPE_ID
      start_time: eventDateTime,
      home_team_id: homeTeamObj.id,
      away_team_id: awayTeamObj.id,
      created_by: '77d77471-1250-47e0-81ab-d4626595d63c',
      source_app_id: '550e8400-e29b-41d4-a716-446655440311',
      external_source: 'casa'
    });
  }

  parseMatchRow(parts, divisionName) {
    // parts is an array: [Date, Home Team, Away Team, Time, Location...]
    // We need at least date, home team, and away team
    if (!parts || parts.length < 3) {
      return null;
    }
    
    let dateText = '';
    let homeText = '';
    let awayText = '';
    let timeText = '';
    
    // Find date (MM/DD or MM-DD format)
    for (const part of parts) {
      if (!dateText && /\d{1,2}[\/-]\d{1,2}/.test(part)) {
        dateText = part;
        break;
      }
    }
    
    // Find team names - check against our known teams
    const teamNames = Array.from(this.data.teams.values()).map(t => t.name);
    
    for (const part of parts) {
      // Skip if this is the date
      if (part === dateText) continue;
      
      // Check if this matches any team name (exact or partial match)
      const matchedTeam = teamNames.find(name => {
        const normalized1 = this.normalizeTeamName(name);
        const normalized2 = this.normalizeTeamName(part);
        return normalized1 === normalized2 || 
               normalized1.includes(normalized2) || 
               normalized2.includes(normalized1);
      });
      
      if (matchedTeam) {
        if (!homeText) {
          homeText = matchedTeam;
        } else if (!awayText && matchedTeam !== homeText) {
          awayText = matchedTeam;
        }
      }
      
      // Check for time (HH:MM AM/PM format)
      if (!timeText && /\d{1,2}:\d{2}\s*(AM|PM|am|pm)?/.test(part)) {
        timeText = part;
      }
    }
    
    if (!dateText || !homeText || !awayText) {
      this.logWarning(`Could not parse match row: ${parts.join(' | ')}`);
      return null;
    }
    
    // Find team IDs
    const homeTeam = Array.from(this.data.teams.values()).find(t => t.name === homeText);
    const awayTeam = Array.from(this.data.teams.values()).find(t => t.name === awayText);
    
    if (!homeTeam || !awayTeam) {
      this.logWarning(`Could not find teams: ${homeText} vs ${awayText}`);
      return null;
    }
    
    // Parse date and time
    let eventDateTime = dateText;
    if (timeText) {
      eventDateTime = `${dateText} ${timeText}`;
    }
    
    const eventId = IdGenerator.fromComponents('casa', 'match', dateText, homeText, awayText);
    
    return new Match({
      event_id: eventId,
      name: `${homeText} vs ${awayText}`,
      event_type_id: '550e8400-e29b-41d4-a716-446655440402', // MATCH_EVENT_TYPE_ID
      start_time: eventDateTime,
      home_team_id: homeTeam.id,
      away_team_id: awayTeam.id,
      created_by: '77d77471-1250-47e0-81ab-d4626595d63c',
      source_app_id: '550e8400-e29b-41d4-a716-446655440311',
      external_source: 'casa'
    });
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
            position: position || null
          });
          
          this.data.players.set(playerId, player);
          this.duplicateDetector.markSeen('player', { firstName, lastName }, ['firstName', 'lastName']);
          
          // Create team-player association
          const teamPlayerKey = `${teamId}_${playerId}`;
          const teamPlayer = new TeamPlayer({
            team_id: teamId,
            player_id: playerId,
            jersey_number: jerseyNumber || null,
            is_active: true
          });
          this.data.teamPlayers.set(teamPlayerKey, teamPlayer);
          
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
        filename: '04-conferences-casa.sql',
        data: this.data.conferences,
        options: {
          title: 'CASA Conferences',
          tableName: 'league_conferences',
          columns: ['id', 'league_id', 'name', 'display_name', 'slug', 'description', 'contact_email', 'contact_phone', 'is_active'],
          useInserts: true
        }
      },
      {
        filename: '05-league-divisions-casa.sql',
        data: this.data.divisions,
        options: {
          title: 'CASA League Divisions',
          tableName: 'league_divisions',
          columns: ['id', 'conference_id', 'name', 'display_name', 'slug', 'tier', 'hierarchy_group', 'skill_level', 'age_group', 'description', 'is_active'],
          useInserts: true
        }
      },
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
        filename: '08-users-casa.sql',
        data: this.data.players,
        options: {
          title: 'CASA Users',
          tableName: 'users',
          columns: ['id', 'first_name', 'last_name', 'email', 'phone', 'date_of_birth', 'is_active', 'created_at', 'updated_at'],
          useInserts: true,
          customSQL: (players) => {
            const lines = [];
            for (const player of players) {
              lines.push(player.toUserSQL());
            }
            return lines.join('\n\n');
          }
        }
      },
      {
        filename: '09-players-casa.sql',
        data: this.data.players,
        options: {
          title: 'CASA Players',
          tableName: 'players',
          columns: ['id', 'preferred_position_id', 'photo_url', 'height_cm', 'weight_kg', 'dominant_foot', 'player_rating', 'notes', 'created_at', 'updated_at'],
          useInserts: true,
          customSQL: (players) => {
            const lines = [];
            for (const player of players) {
              lines.push(player.toPlayerSQL());
            }
            return lines.join('\n\n');
          }
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
        filename: '23-team-players-casa.sql',
        data: this.data.teamPlayers,
        options: {
          title: 'CASA Team Rosters',
          tableName: 'team_players',
          columns: ['team_id', 'player_id', 'jersey_number', 'is_active', 'joined_date', 'left_date', 'notes'],
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
