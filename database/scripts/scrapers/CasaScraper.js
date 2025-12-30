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
const Coach = require('../models/Coach');
const TeamCoach = require('../models/TeamCoach');
const Match = require('../models/Match');
const LeagueConference = require('../models/LeagueConference');
const LeagueDivision = require('../models/LeagueDivision');
const puppeteer = require('puppeteer');
const { JSDOM } = require('jsdom');
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
    this.conferences = {
      philadelphia: {
        name: 'Philadelphia',
        divisions: {
          liga1: {
            name: 'Liga 1',
            tier: 1,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090889',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/14eQOJ60T0XNru6twNp59rP4RNrAuO2Gf/htmlview?gid=732556598'
          },
          liga2: {
            name: 'Liga 2',
            tier: 2,
            standings: 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9096430',
            schedule: 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430',
            rosterSheet: 'https://docs.google.com/spreadsheets/d/195usWo3fmXLw4IUOY_vEdB4dAk7EVfTu/htmlview?gid=1361313939'
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

    // Initialize data stores using normalized schema (same tables as APSL)
    this.data.leagues = new Map();
    this.data.conferences = new Map();
    this.data.divisions = new Map();
    this.data.teams = new Map();
    this.data.teamDivisions = new Map();
    this.data.players = new Map();
    this.data.teamPlayers = new Map();
    this.data.matches = new Map();
    
    // Source system IDs
    this.SOURCE_SYSTEM_ID = 2; // CASA source system
    this.ORGANIZATION_ID = 2;   // CASA organization
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
    
    // Create CASA League (single entry like APSL)
    const leagueId = 1; // Sequential ID
    this.data.leagues.set(leagueId, {
      id: leagueId,
      organization_id: this.ORGANIZATION_ID,  // CASA organization
      name: 'CASA Soccer League',
      season: '2024-2025',
      website_url: 'https://www.casasoccerleagues.com',
      affiliation: null,
      age_calculation_method_id: null,
      age_min: null,
      age_max: null,
      age_cutoff_month_day: null,
      age_display_label: 'Open',
      sex_restriction: 'men',
      source_system_id: this.SOURCE_SYSTEM_ID,
      external_id: 'casa-2024-2025',
      is_active: true
    });
    
    // Track conference and division IDs
    this.conferenceIds = {};
    this.divisionIds = {};
    
    let conferenceSeq = 1;
    let divisionSeq = 1;
    
    // Create conferences and divisions from configuration
    for (const [confKey, confData] of Object.entries(this.conferences)) {
      // Create Conference
      const confId = conferenceSeq++;
      this.conferenceIds[confKey] = confId;
      
      this.data.conferences.set(confId, {
        id: confId,
        league_id: leagueId,
        name: confData.name,
        abbreviation: confData.name.substring(0, 10),
        source_system_id: this.SOURCE_SYSTEM_ID,
        external_id: `casa-conf-${confKey}`,
        sort_order: confId
      });
      
      this.log(`Created conference: ${confData.name} (ID: ${confId})`);
      
      // Create divisions for this conference
      for (const [divKey, divData] of Object.entries(confData.divisions)) {
        const divId = divisionSeq++;
        this.divisionIds[`${confKey}_${divKey}`] = divId;
        
        this.data.divisions.set(divId, {
          id: divId,
          league_id: leagueId,
          conference_id: confId,
          name: divData.name,
          skill_level: divData.tier,
          skill_label: `Tier ${divData.tier}`,
          source_system_id: this.SOURCE_SYSTEM_ID,
          external_id: `casa-div-${divKey}`,
          sort_order: divId
        });
        
        this.log(`  Created division: ${confData.name} ${divData.name} (ID: ${divId})`);
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
          // Fetch individual team schedules using extracted IDs
          await this.fetchTeamSchedules(divisionId, divisionName);
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
    const teamIdMap = new Map(); // Map Name -> ID

    // Listen for network responses to find the hidden API data
    page.on('response', async response => {
        try {
            const url = response.url();
            const contentType = response.headers()['content-type'];
            
            if (contentType && contentType.includes('application/json')) {
                this.log(`   DEBUG: JSON Response from ${url}`);
                // Look for standings/team data
                // SportsEngine often uses 'standings' or 'teams' in the API endpoint
                if (url.includes('standings') || url.includes('teams') || url.includes('seasons') || url.includes('schedule')) {
                    try {
                        const data = await response.json();
                        
                        if (url.includes('standings')) {
                             this.log(`   DEBUG: Standings API Data Structure: ${JSON.stringify(data).substring(0, 500)}...`);
                             if (Array.isArray(data)) {
                                 this.log(`   DEBUG: Standings is Array of length ${data.length}`);
                                 if (data.length > 0) this.log(`   DEBUG: First item keys: ${Object.keys(data[0]).join(', ')}`);
                             } else {
                                 this.log(`   DEBUG: Standings keys: ${Object.keys(data).join(', ')}`);
                             }
                        }

                        // Helper to process a team object
                        const processTeam = (t) => {
                            const name = t.team_name || t.name || t.title;
                            
                            // DEBUG: Log the team object if it looks like a V3 team record
                            if (t.team_id && !this._loggedV3Team) {
                                this.log(`   DEBUG: V3 Team Record: ${JSON.stringify(t)}`);
                                this._loggedV3Team = true;
                            }

                            // Look for various ID fields
                            const id = t.team_id || t.id || t.page_node_id || t.node_id;
                            
                            if (name && id) {
                                teamIdMap.set(name.trim(), id);
                                teamIdMap.set(name.trim().toLowerCase(), id);
                            }
                        };

                        // Handle different response structures
                        if (data.result && Array.isArray(data.result)) {
                            // SportsEngine V3 Standings API
                            data.result.forEach(group => {
                                if (group.program_id) {
                                    this.programId = group.program_id; // Store program ID (Season ID)
                                }
                                if (group.teamRecords && Array.isArray(group.teamRecords)) {
                                    group.teamRecords.forEach(processTeam);
                                }
                            });
                        } else if (Array.isArray(data)) {
                            data.forEach(processTeam);
                        } else if (data.teams && Array.isArray(data.teams)) {
                            data.teams.forEach(processTeam);
                        } else if (data.standings && Array.isArray(data.standings)) {
                            data.standings.forEach(processTeam);
                        } else if (data.data && Array.isArray(data.data)) {
                            // Sometimes wrapped in 'data'
                            data.data.forEach(processTeam);
                        }
                    } catch (e) {
                        // Ignore JSON parse errors
                    }
                }
            }
        } catch (e) {
            // Ignore response processing errors
        }
    });
    
    try {
      this.log(`   Navigating to ${url}...`);
      await page.goto(url, { 
        waitUntil: 'networkidle2',
        timeout: 60000
      });
      
      // Wait for iframe to load
      this.log(`   Waiting 5s for content...`);
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      // Get all frames
      const frames = page.frames();
      this.log(`   Found ${frames.length} frames. Scanning for standings...`);
      
      let teamNames = [];
      
      for (const frame of frames) {
        try {
            // Run extraction in the browser context
            const extractedTeams = await frame.evaluate(() => {
                const data = [];
                const rows = document.querySelectorAll('table tbody tr');
                
                rows.forEach(row => {
                    const teamCell = row.querySelector('.team-name');
                    if (teamCell) {
                        const name = teamCell.innerText.trim();
                        // We don't need to look for URL here anymore if we catch it via network
                        if (name) {
                            data.push({ name, url: null });
                        }
                    }
                });
                return data;
            });
            
            if (extractedTeams.length > 0) {
                this.log(`   Found ${extractedTeams.length} teams in frame ${frame.url()}`);
                teamNames = teamNames.concat(extractedTeams);
            }
        } catch (e) {
            // ignore
        }
      }
      
      // Fallback to main page
      if (teamNames.length === 0) {
          const mainHtml = await page.content();
          const names = this.parseStandingsHtml(mainHtml);
          if (names.length > 0) {
              this.log(`   Found ${names.length} teams in main page`);
              teamNames = names;
          }
      }
      
      if (teamNames.length === 0) {
        this.logWarning(`No teams found for ${divisionName}`);
        return;
      }
      
      // Deduplicate
      const uniqueTeams = new Map();
      teamNames.forEach(t => uniqueTeams.set(t.name, t));
      
      this.log(`   Extracted ${uniqueTeams.size} unique team names`);
      
      if (teamIdMap.size > 0) {
          this.log(`   Captured ${teamIdMap.size} team IDs from network traffic`);
      }

      // Update teams with IDs found in network traffic
      for (const team of uniqueTeams.values()) {
          const id = teamIdMap.get(team.name) || teamIdMap.get(team.name.toLowerCase());
          if (id) {
              team.nodeId = id;
              // Construct the URL using the ID
              // Pattern: https://www.casasoccerleagues.com/team_page?team_id={ID}
              // Or: https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id={ID}
              // Let's try the standard SportsEngine team page URL
              team.url = `https://www.casasoccerleagues.com/team_page?team_id=${id}`;
              this.log(`   ✓ ${team.name} (ID: ${id})`);
          } else {
              this.log(`   DEBUG: No ID found for ${team.name}`);
          }
      }
      
      for (const [teamName, teamData] of uniqueTeams) {
        if (!this.matchesTeamFilter(teamName)) {
          this.log(`   ⊘ Skipping ${teamName} (filtered out)`);
          continue;
        }
        
        // Generate sequential team ID
        if (!this.teamSeq) this.teamSeq = 1;
        const teamId = this.teamSeq++;
        
        // Extract CASA team ID (their external ID)
        const casaTeamId = teamIdMap.get(teamName) || teamIdMap.get(teamName.toLowerCase());
        
        // Create Team in normalized teams table (no division_id - use junction table instead)
        this.data.teams.set(teamId, {
          id: teamId,
          club_id: null,  // League teams don't belong to Football Home clubs
          sport_division_id: null,  // League teams don't belong to Football Home sport divisions
          name: teamName.trim(),
          city: null,
          logo_url: null,
          is_active: true,
          source_system_id: this.SOURCE_SYSTEM_ID,  // 2 = CASA
          external_id: casaTeamId || `casa-team-${teamId}`  // Use CASA's team ID or generate one
        });
        
        // Store page_node_id in a lookup map for matching with schedules
        if (casaTeamId) {
          this.teamNodeIdMap = this.teamNodeIdMap || new Map();
          this.teamNodeIdMap.set(casaTeamId, teamId);
        }
        
        // Create team_divisions junction record to link team to league division
        if (!this.teamDivisionSeq) this.teamDivisionSeq = 1;
        const teamDivisionId = this.teamDivisionSeq++;
        
        this.data.teamDivisions = this.data.teamDivisions || new Map();
        this.data.teamDivisions.set(teamDivisionId, {
          id: teamDivisionId,
          team_id: teamId,
          division_id: divisionId,
          season_id: null,
          is_active: true
        });

        this.log(`   ✓ ${teamName} (Node ID: ${casaTeamId || 'N/A'})`);
      }
      
    } catch (error) {
      this.logError(`Failed to fetch ${divisionName} teams`, error);
    } finally {
      await page.close();
    }
  }

  parseStandingsHtml(html) {
    const dom = new JSDOM(html);
    const doc = dom.window.document;
    const data = [];
    const rows = doc.querySelectorAll('table tbody tr');
    
    rows.forEach(row => {
      // Try to find by class first (SportsEngine specific)
      const rankCell = row.querySelector('.rank');
      const teamCell = row.querySelector('.team-name');
      
      if (rankCell && teamCell) {
          const rank = rankCell.textContent.trim();
          const teamName = teamCell.textContent.trim();
          
          // Extract URL
          let link = teamCell.querySelector('a');
          
          // Fallback: Check if the cell itself is a link
          if (!link && teamCell.tagName === 'A') {
              link = teamCell;
          }

          // Fallback: Search entire row for a link that looks like a team page
          if (!link) {
              const allLinks = row.querySelectorAll('a');
              for (const l of allLinks) {
                  if (l.href && (l.href.includes('page_node_id') || l.href.includes('team_home'))) {
                      link = l;
                      break;
                  }
              }
          }

          const url = link ? link.href : null;
          
          if (!url) {
             console.log(`DEBUG: No link found in team cell. Cell HTML: ${teamCell.innerHTML.substring(0, 100)}...`);
          }
          
          if (/^\d+$/.test(rank) && teamName && teamName.length > 2) {
              data.push({ name: teamName, url: url });
              return;
          }
      }

      // Fallback to column indices
      const cells = row.querySelectorAll('td');
      // Need at least rank and team name
      if (cells.length >= 2) {
          // Check index 0 and 1
          let rank = cells[0].textContent.trim();
          let teamName = cells[1].textContent.trim();
          let url = null;
          
          // Check for link in cell 1
          const link1 = cells[1].querySelector('a');
          if (link1) url = link1.href;
          
          if (/^\d+$/.test(rank) && teamName && teamName.length > 2) {
              data.push({ name: teamName, url: url });
              return;
          }
          
          // Check index 1 and 2 (if there's a shadow column)
          if (cells.length >= 3) {
              rank = cells[1].textContent.trim();
              teamName = cells[2].textContent.trim();
              
              // Check for link in cell 2
              const link2 = cells[2].querySelector('a');
              if (link2) url = link2.href;
              
              if (/^\d+$/.test(rank) && teamName && teamName.length > 2) {
                  data.push({ name: teamName, url: url });
              }
          }
      }
    });
    return data;
  }

  async fetchSchedule(url, divisionName) {
    const page = await this.browser.newPage();
    const apiMatches = [];
    
    // Find divisionId from divisionName
    let divisionId = null;
    for (const [id, div] of this.data.divisions) {
        if (div.display_name === divisionName || div.name === divisionName) {
            divisionId = id;
            break;
        }
    }
    
    if (!divisionId) {
        this.logWarning(`Could not find division ID for ${divisionName}`);
    }

    // Listen for network responses to find the hidden API data
    let lastApiCallTime = Date.now();
    page.on('response', async response => {
        try {
            const url = response.url();
            const contentType = response.headers()['content-type'];
            
            if (contentType && contentType.includes('application/json')) {
                // Look for schedule data - specifically the events API
                if (url.includes('/microsites/events?')) {
                    lastApiCallTime = Date.now();
                    const matchUrl = url.match(/page=(\d+)/);
                    const pageNum = matchUrl ? matchUrl[1] : '1';
                    
                    try {
                        const data = await response.json();
                        
                        // Helper to process matches
                        const processMatches = (matches) => {
                            if (!Array.isArray(matches)) return;
                            
                            let newMatches = 0;
                            matches.forEach(m => {
                                // Check for required fields
                                if (m.start_date_time || m.date || m.game_date) {
                                    apiMatches.push(m);
                                    newMatches++;
                                }
                            });
                            if (newMatches > 0) {
                                this.log(`   📄 Captured page ${pageNum}: ${newMatches} matches (total: ${apiMatches.length})`);
                            }
                        };

                        if (data.events && Array.isArray(data.events)) {
                            processMatches(data.events);
                        } else if (data.games && Array.isArray(data.games)) {
                            processMatches(data.games);
                        } else if (Array.isArray(data)) {
                            processMatches(data);
                        } else if (data.result && Array.isArray(data.result)) {
                             // Sometimes wrapped in result
                             processMatches(data.result);
                        }
                    } catch (e) {
                        // Ignore
                    }
                }
            }
        } catch (e) {
            // Ignore
        }
    });
    
    // Extract program_id from the URL to make direct API calls
    let programId = null;
    
    try {
      this.log(`   Navigating to schedule: ${url}`);
      await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });
      
      // Wait a moment for initial load
      await new Promise(r => setTimeout(r, 2000));
      
      // Try to extract program_id from the page
      const extractedData = await page.evaluate(() => {
          // Look for program_id in the iframe src
          const iframe = document.querySelector('iframe[src*="seasons"]');
          if (iframe && iframe.src) {
              const match = iframe.src.match(/seasons\/([a-f0-9]+)/);
              if (match) return { programId: match[1] };
          }
          return null;
      });
      
      if (extractedData && extractedData.programId) {
          programId = extractedData.programId;
          this.log(`   Found program_id: ${programId} - will use scrolling to load all matches`);
      }
      
      // Use scrolling method (works best with the page's built-in pagination)
      {
          
          // Get all frames
          const frames = page.frames();
          this.log(`   Found ${frames.length} frames. Scanning for schedule data...`);
          
          // Try to interact with the schedule frame to show all matches
          const scheduleFrame = frames.find(f => f.url().includes('schedule') && f.url().includes('sportsengine'));
          if (scheduleFrame) {
              this.log(`   Found schedule frame: ${scheduleFrame.url()}`);
              try {
                  // 1. Try to click "View All" or "Show All" or "View Full Schedule"
                  const clickedViewAll = await scheduleFrame.evaluate(() => {
                  const buttons = Array.from(document.querySelectorAll('a, button, div[role="button"], span, .sm-button'));
                  const viewAll = buttons.find(b => {
                      const text = b.textContent.trim().toLowerCase();
                      return text.includes('view all') || text.includes('show all') || text.includes('view full schedule');
                  });
                  if (viewAll) {
                      viewAll.click();
                      return true;
                  }
                  return false;
              });

              if (clickedViewAll) {
                  this.log(`   Clicked "View All" button`);
                  await new Promise(r => setTimeout(r, 1000));
              }

              // 2. CRITICAL: Try to find and click date/status filter to show ALL games
              this.log(`   Looking for date filter to show all games...`);
              
              // Debug: See what's available
              const availableControls = await scheduleFrame.evaluate(() => {
                  const controls = [];
                  document.querySelectorAll('select').forEach(s => {
                      Array.from(s.options).forEach(o => controls.push(`SELECT_OPTION: "${o.textContent.trim()}"`));
                  });
                  document.querySelectorAll('button, [role="button"], [role="tab"]').forEach(b => {
                      const text = b.textContent.trim();
                      if (text && text.length < 40) controls.push(`BUTTON: "${text}"`);
                  });
                  return controls.slice(0, 15);
              });
              this.log(`   Debug - Available: ${availableControls.join(', ')}`);
              
              const filterResult = await scheduleFrame.evaluate(() => {
                  // First, try to click "Jump To" dropdown
                  const buttons = Array.from(document.querySelectorAll('button, a, .filter-button, [role="button"], [role="tab"]'));
                  
                  const jumpToButton = buttons.find(b => b.textContent.trim() === 'Jump To');
                  if (jumpToButton) {
                      jumpToButton.click();
                      return 'opened_jump_to';
                  }
                  
                  // Fallback: try to open Filters panel
                  const filtersButton = buttons.find(b => b.textContent.trim().toLowerCase() === 'filters');
                  if (filtersButton) {
                      filtersButton.click();
                      return 'opened_filters';
                  }
                  
                  return null;
              });

              if (filterResult === 'opened_jump_to') {
                  this.log(`   ✓ Opened "Jump To" dropdown - looking for Season Start...`);
                  await new Promise(r => setTimeout(r, 500));
                  
                  // Now click "Season Start" option
                  const seasonStartClicked = await scheduleFrame.evaluate(() => {
                      // Look for "Season Start" in dropdown menu items
                      const menuItems = Array.from(document.querySelectorAll('a, button, li, [role="menuitem"], .dropdown-item, .menu-item'));
                      
                      const seasonStart = menuItems.find(item => 
                          item.textContent.trim().toLowerCase().includes('season start')
                      );
                      
                      if (seasonStart) {
                          seasonStart.click();
                          return true;
                      }
                      
                      return false;
                  });
                  
                  if (seasonStartClicked) {
                      this.log(`   ✓ Clicked "Season Start" - waiting for all matches to load...`);
                      await new Promise(r => setTimeout(r, 3000));
                  } else {
                      this.log(`   ⚠ Could not find "Season Start" option in dropdown`);
                  }
              } else if (filterResult === 'opened_filters') {
                  this.log(`   ✓ Opened Filters panel - now looking for date options...`);
                  await new Promise(r => setTimeout(r, 1000));
                  
                  // Now look for Season Start or date range options
                  const dateOption = await scheduleFrame.evaluate(() => {
                      // Look for select dropdowns that appeared
                      const selects = Array.from(document.querySelectorAll('select'));
                      
                      for (const select of selects) {
                          const options = Array.from(select.options);
                          const seasonStartOption = options.find(o => 
                              o.textContent.trim().toLowerCase().includes('season start')
                          );
                          
                          if (seasonStartOption) {
                              select.value = seasonStartOption.value;
                              select.dispatchEvent(new Event('change', { bubbles: true }));
                              return 'season_start';
                          }
                      }
                      
                      // If no Season Start, try finding "All" in a newly visible section
                      const allButtons = Array.from(document.querySelectorAll('button, [role="button"]'));
                      const allBtn = allButtons.find(b => {
                          const text = b.textContent.trim().toLowerCase();
                          return text === 'all' || text === 'all games';
                      });
                      
                      if (allBtn) {
                          allBtn.click();
                          return 'all';
                      }
                      
                      return null;
                  });
                  
                  if (dateOption) {
                      this.log(`   ✓ Selected "${dateOption}" date filter`);
                      await new Promise(r => setTimeout(r, 3000));
                  }
              } else if (filterResult) {
                  this.log(`   ✓ Clicked "${filterResult}" filter - waiting for reload...`);
                  await new Promise(r => setTimeout(r, 3000)); // Wait longer for matches to load
              } else {
                  this.log(`   ⚠ Could not find date filter - may only see upcoming games`);
              }

              // 3. Try to find and click "Season Start" option to show all games from the beginning
              const dateFilterSet = await scheduleFrame.evaluate(() => {
                  // First try select dropdowns
                  const selects = Array.from(document.querySelectorAll('select'));
                  
                  for (const select of selects) {
                      const options = Array.from(select.options);
                      const seasonStartOption = options.find(o => 
                          o.textContent.trim().toLowerCase().includes('season start')
                      );
                      
                      if (seasonStartOption) {
                          select.value = seasonStartOption.value;
                          select.dispatchEvent(new Event('change', { bubbles: true }));
                          return 'season_start';
                      }
                  }
                  
                  // Try clickable buttons - SportsEngine often has "Upcoming", "Past", "All", "Season Start"
                  const buttons = Array.from(document.querySelectorAll('button, a, [role="button"], .filter-button, .option'));
                  
                  // Priority: Season Start > All > Past
                  const seasonStartButton = buttons.find(b => {
                      const text = b.textContent.trim().toLowerCase();
                      return text.includes('season start');
                  });
                  
                  if (seasonStartButton) {
                      seasonStartButton.click();
                      return 'season_start';
                  }
                  
                  const allButton = buttons.find(b => {
                      const text = b.textContent.trim().toLowerCase();
                      return text === 'all' || text === 'all games' || text === 'all events';
                  });
                  
                  if (allButton) {
                      allButton.click();
                      return 'all_games';
                  }
                  
                  const pastButton = buttons.find(b => {
                      const text = b.textContent.trim().toLowerCase();
                      return text === 'past' || text === 'past games';
                  });
                  
                  if (pastButton) {
                      pastButton.click();
                      return 'past_games';
                  }
                  
                  return false;
              });

              if (dateFilterSet === 'season_start') {
                  this.log(`   ✓ Clicked "Season Start" filter`);
                  await new Promise(r => setTimeout(r, 2000));
              } else if (dateFilterSet === 'all_games') {
                  this.log(`   ✓ Clicked "All Games" filter`);
                  await new Promise(r => setTimeout(r, 2000));
              } else if (dateFilterSet === 'past_games') {
                  this.log(`   ✓ Clicked "Past Games" filter`);
                  await new Promise(r => setTimeout(r, 2000));
              } else {
                  this.log(`   ⚠ No date filter found - will see whatever the page shows by default`);
              }

              // 3. Try to find "Game Status" filter
              // SportsEngine often has a dropdown for "Upcoming", "Past", "All"
              const filterClicked = await scheduleFrame.evaluate(() => {
                  // Look for a select or dropdown
                  const selects = Array.from(document.querySelectorAll('select'));
                  const statusSelect = selects.find(s => {
                      const label = s.getAttribute('aria-label') || s.name || '';
                      return label.toLowerCase().includes('status') || s.innerHTML.includes('Upcoming');
                  });

                  if (statusSelect) {
                      // Try to set to 'All' or empty
                      // Options usually: Scheduled, Final, All, etc.
                      const options = Array.from(statusSelect.options);
                      const allOption = options.find(o => o.text.toLowerCase().includes('all') || o.value === '');
                      if (allOption) {
                          statusSelect.value = allOption.value;
                          statusSelect.dispatchEvent(new Event('change', { bubbles: true }));
                          return true;
                      }
                  }
                  
                  // Look for custom dropdowns (divs)
                  const dropdowns = Array.from(document.querySelectorAll('.filter-container, .filters, .dropdown'));
                  for (const d of dropdowns) {
                      if (d.textContent.includes('Upcoming')) {
                          // This might be the filter. Click it.
                          const toggle = d.querySelector('.dropdown-toggle, button, [role="button"]');
                          if (toggle) {
                              toggle.click();
                              // Now look for "All" in the menu that appeared (hopefully)
                              // This is tricky in a single evaluate, but we can try
                              return 'clicked_dropdown';
                          }
                      }
                  }
                  
                  return false;
              });

              if (filterClicked === true) {
                  this.log(`   Changed status filter to "All"`);
                  await new Promise(r => setTimeout(r, 1000));
              } else if (filterClicked === 'clicked_dropdown') {
                  this.log(`   Clicked filter dropdown, trying to select "All"...`);
                  await new Promise(r => setTimeout(r, 500));
                  // Try to click "All"
                  await scheduleFrame.evaluate(() => {
                      const items = Array.from(document.querySelectorAll('li, .dropdown-item, div[role="option"]'));
                      const allItem = items.find(i => i.textContent.trim().toLowerCase() === 'all' || i.textContent.trim().toLowerCase() === 'all games');
                      if (allItem) allItem.click();
                  });
                  await new Promise(r => setTimeout(r, 1000));
              }

              this.log(`   Auto-scrolling to load all matches...`);
              
              // More aggressive scrolling to trigger pagination
              let lastMatchCount = apiMatches.length;
              let noNewMatchesCount = 0;
              const maxScrollAttempts = 50; // Prevent infinite loop
              
              for (let i = 0; i < maxScrollAttempts; i++) {
                  // Scroll to bottom
                  await scheduleFrame.evaluate(() => {
                      window.scrollTo(0, document.body.scrollHeight);
                      
                      // Also scroll any scrollable containers
                      const containers = document.querySelectorAll('.sm-schedule__events, .scrollable, [style*="overflow"]');
                      containers.forEach(c => {
                          if (c.scrollHeight > c.clientHeight) {
                              c.scrollTop = c.scrollHeight;
                          }
                      });
                  });
                  
                  // Wait for potential API call
                  await new Promise(r => setTimeout(r, 500));
                  
                  // Check if we got new matches
                  if (apiMatches.length > lastMatchCount) {
                      lastMatchCount = apiMatches.length;
                      noNewMatchesCount = 0;
                      this.log(`   🔄 Scrolling... ${apiMatches.length} matches so far`);
                  } else {
                      noNewMatchesCount++;
                      // If no new matches after 5 scroll attempts, we're probably done
                      if (noNewMatchesCount >= 5) {
                          this.log(`   ✓ Scroll complete - no more matches loading`);
                          break;
                      }
                  }
              }
              
          } catch (e) {
              this.logWarning(`   Error interacting with schedule frame: ${e.message}`);
          }
          } // End of scheduleFrame if block
      } // End of scrolling method

      // Process API matches
      let matchCount = 0;
      if (apiMatches.length > 0) {
          this.log(`   Processing ${apiMatches.length} matches from API...`);
          for (const apiMatch of apiMatches) {
              const match = this.parseMatchFromApi(apiMatch, divisionName, divisionId);
              if (match) {
                  // Check for duplicate by external_id
                  let isDuplicate = false;
                  if (match.external_id) {
                      for (const existingMatch of this.data.matches.values()) {
                          if (existingMatch.external_id === match.external_id) {
                              isDuplicate = true;
                              break;
                          }
                      }
                  }
                  
                  if (!isDuplicate) {
                      if (!this.matchSeq) this.matchSeq = 1;
                      const matchId = this.matchSeq++;
                      this.data.matches.set(matchId, match);
                      matchCount++;
                  }
              }
          }
      }
      
      this.log(`   Saved ${matchCount} matches`);
      
    } catch (error) {
      this.logError(`Failed to fetch ${divisionName} schedule`, error);
    } finally {
      await page.close();
    }
  }

  async fetchTeamSchedules(divisionId, divisionName) {
    this.log(`\n🗓️ Fetching team schedules for ${divisionName}...`);
    
    // Find the division configuration to get the schedule URL
    let scheduleUrl = null;
    for (const [confKey, confData] of Object.entries(this.conferences)) {
        for (const [divKey, divData] of Object.entries(confData.divisions)) {
            const divId = this.divisionIds[`${confKey}_${divKey}`];
            if (divId === divisionId) {
                scheduleUrl = divData.schedule;
                break;
            }
        }
        if (scheduleUrl) break;
    }
    
    if (!scheduleUrl) {
        this.logWarning(`Could not find schedule URL for ${divisionName}`);
        return;
    }

    // Fetch the division-level schedule page (contains all teams' matches)
    this.log(`   Fetching from division schedule page...`);
    await this.fetchSchedule(scheduleUrl, divisionName);
  }

  findTeam(name) {
      const teamNames = Array.from(this.data.teams.values()).map(t => t.name);
      
      // Normalize the search name
      const searchNormalized = this.normalizeTeamName(name);
      
      return teamNames.find(teamName => {
        const normalized1 = this.normalizeTeamName(teamName).toLowerCase();
        const normalized2 = searchNormalized.toLowerCase();
        
        // Exact match
        if (normalized1 === normalized2) return true;
        
        // Generate variants for both names
        const variants1 = this.generateTeamNameVariants(normalized1);
        const variants2 = this.generateTeamNameVariants(normalized2);
        
        // Check if any variants match
        for (const v1 of variants1) {
            for (const v2 of variants2) {
                if (v1 === v2 && v1.length > 0) return true;
            }
        }
        
        return false;
      });
  }
  
  generateTeamNameVariants(name) {
      const lower = name.toLowerCase();
      const variants = [lower];
      
      // Handle spacing variations (e.g., "BlackStars" vs "Black Stars")
      variants.push(lower.replace(/\s+/g, ''));
      
      // Handle FC variations (with/without periods and spaces)
      if (lower.includes(' fc') || lower.includes(' f.c.')) {
          variants.push(lower.replace(/\s*f\.?c\.?\s*/g, ' ').trim());
          variants.push(lower.replace(/\s*f\.?c\.?$/g, '').trim());
      }
      
      // Handle United variations (but be careful - only if it's at the end)
      if (lower.endsWith(' united')) {
          variants.push(lower.replace(/\s+united$/g, '').trim());
      }
      
      // Handle Roman numerals at the end (II, III, etc)
      variants.push(lower.replace(/\s+i+$/g, '').trim());
      
      // Remove punctuation but keep spaces
      variants.push(lower.replace(/[^\w\s]/g, '').trim());
      
      // Remove duplicate spaces
      const cleaned = variants.map(v => v.replace(/\s+/g, ' ').trim());
      
      return [...new Set(cleaned)].filter(v => v.length > 0);
  }

  findTeamByNodeId(nodeId) {
      // Find the casa_team record with this page_node_id
      for (const casaTeam of this.data.teams.values()) {
          if (casaTeam.page_node_id === nodeId) {
              // Return the actual team object
              return this.data.teams.get(casaTeam.team_id);
          }
      }
      return null;
  }

  findTeamInStandings(teamName, divisionId) {
      // ONLY match teams that were scraped from standings
      // DO NOT create new teams - all teams must come from standings
      
      // 1. Try to find existing team by name (search ALL teams, not just this division)
      const existingName = this.findTeam(teamName);
      if (existingName) {
          // Find the team object by name
          return Array.from(this.data.teams.values()).find(t => t.name === existingName);
      }

      // 2. Team not found - log warning and return null
      this.log(`   ⚠️  Could not match schedule team to standings: "${teamName}"`);
      return null;
  }

  parseMatchFromApi(apiMatch, divisionName, divisionId) {
      const date = apiMatch.start_date_time || apiMatch.date || apiMatch.game_date;
      if (!date) return null;
      
      let homeTeamName = '';
      let awayTeamName = '';
      let homeTeamId = null;
      let awayTeamId = null;
      let homeScore = null;
      let awayScore = null;
      
      // Handle SportsEngine V3 Events API structure
      if (apiMatch.game_details) {
          const t1 = apiMatch.game_details.team_1;
          const t2 = apiMatch.game_details.team_2;
          
          if (t1 && t2) {
              if (t1.is_home_team) {
                  homeTeamName = t1.name;
                  homeTeamId = t1.id || t1.originator_id || t1.team_id;
                  homeScore = t1.score;
                  awayTeamName = t2.name;
                  awayTeamId = t2.id || t2.originator_id || t2.team_id;
                  awayScore = t2.score;
              } else {
                  homeTeamName = t2.name;
                  homeTeamId = t2.id || t2.originator_id || t2.team_id;
                  homeScore = t2.score;
                  awayTeamName = t1.name;
                  awayTeamId = t1.id || t1.originator_id || t1.team_id;
                  awayScore = t1.score;
              }
          }
      } 
      // Legacy/Other structures
      else {
          if (apiMatch.home_team) {
              homeTeamName = apiMatch.home_team.name || apiMatch.home_team.team_name || apiMatch.home_team.short_name;
          }
          
          if (apiMatch.away_team) {
              awayTeamName = apiMatch.away_team.name || apiMatch.away_team.team_name || apiMatch.away_team.short_name;
          }
          
          // Fallback
          if (!homeTeamName && apiMatch.home_team_name) homeTeamName = apiMatch.home_team_name;
          if (!awayTeamName && apiMatch.away_team_name) awayTeamName = apiMatch.away_team_name;
      }
      
      if (!homeTeamName || !awayTeamName) return null;
      
      // Try to find teams by ID first (most reliable), then fall back to name
      let homeTeamObj = homeTeamId ? this.findTeamByNodeId(homeTeamId) : null;
      if (!homeTeamObj) {
          homeTeamObj = this.findTeamInStandings(homeTeamName, divisionId);
      }
      
      let awayTeamObj = awayTeamId ? this.findTeamByNodeId(awayTeamId) : null;
      if (!awayTeamObj) {
          awayTeamObj = this.findTeamInStandings(awayTeamName, divisionId);
      }
      
      // Log warnings but still create match - better to have match data with null teams than skip it
      if (!homeTeamObj) {
          this.log(`   ⚠️  Could not match home team to standings: "${homeTeamName}" - match will be created with null home_team_id`);
      }
      if (!awayTeamObj) {
          this.log(`   ⚠️  Could not match away team to standings: "${awayTeamName}" - match will be created with null away_team_id`);
      }
      
      // Parse date and time
      const matchDate = date.split('T')[0]; // YYYY-MM-DD
      const matchTime = date.includes('T') ? date.split('T')[1].substring(0, 8) : null; // HH:MM:SS
      
      // Determine status based on scores
      let status = 'scheduled';
      if (homeScore !== null && homeScore !== undefined && homeScore !== '') {
          status = 'completed';
      }
      
      // Generate external match ID from API data
      const externalMatchId = apiMatch.id || apiMatch.game_id || apiMatch.event_id || null;
      
      // Map status to match_status_id (1=scheduled, 2=in_progress, 3=completed, 4=cancelled, 5=postponed)
      let matchStatusId = 1; // Default to scheduled
      if (status === 'completed') matchStatusId = 3;
      else if (status === 'cancelled') matchStatusId = 4;
      else if (status === 'postponed') matchStatusId = 5;
      
      // Return normalized matches table row object
      return {
          match_type_id: 1, // 1 = league match
          division_id: divisionId,
          home_team_id: homeTeamObj ? homeTeamObj.id : null,
          away_team_id: awayTeamObj ? awayTeamObj.id : null,
          match_date: matchDate,
          match_time: matchTime,
          venue_id: null, // CASA doesn't provide venue IDs
          title: null,
          description: null,
          match_status_id: matchStatusId,
          home_score: (homeScore !== null && homeScore !== undefined && homeScore !== '') ? parseInt(homeScore) : null,
          away_score: (awayScore !== null && awayScore !== undefined && awayScore !== '') ? parseInt(awayScore) : null,
          source_system_id: this.SOURCE_SYSTEM_ID,
          external_id: externalMatchId ? `casa-match-${externalMatchId}` : null,
          created_by_user_id: null,
          created_by_chat_id: null
      };
  }

  parseScheduleHtml(html) {
    const dom = new JSDOM(html);
    const doc = dom.window.document;
    const matches = [];
    
    // Find the container
    const container = doc.querySelector('.sm-schedule__events');
    if (!container) return matches;
    
    let currentDate = '';
    
    // Iterate through children
    for (const child of container.children) {
      const tagName = child.tagName.toLowerCase();
      
      if (tagName === 'sm-schedule-header') {
        const primary = child.querySelector('.sm-list-header__primary');
        const secondary = child.querySelector('.sm-list-header__secondary');
        if (primary && secondary) {
          currentDate = `${primary.textContent.trim()} ${secondary.textContent.trim()}`;
        }
      } else if (tagName === 'sm-schedule-event') {
        if (!currentDate) continue;
        
        const timeEl = child.querySelector('.sm-event__time');
        const time = timeEl ? timeEl.textContent.trim() : '';
        
        // Teams
        // In the HTML dump: away-team-name comes first, then home-team-name.
        // <sm-nav-link tag="away-team-name">...
        // <sm-nav-link tag="home-team-name">...
        let awayTeam = '';
        let homeTeam = '';
        
        const awayLink = child.querySelector('sm-nav-link[tag="away-team-name"] span');
        const homeLink = child.querySelector('sm-nav-link[tag="home-team-name"] span');
        
        const awayNavLink = child.querySelector('sm-nav-link[tag="away-team-name"]');
        if (awayNavLink) {
             this.log(`   DEBUG: Away Nav Link HTML: ${awayNavLink.outerHTML}`);
        }

        if (awayLink) awayTeam = awayLink.textContent.trim();
        if (homeLink) homeTeam = homeLink.textContent.trim();
        
        // Score
        const scoreEl = child.querySelector('.sm-event__scores');
        const score = scoreEl ? scoreEl.textContent.trim() : '';
        
        // Venue
        const venueEl = child.querySelector('se-fe-inline-list-item[data-cy="venue-name"]');
        const venue = venueEl ? venueEl.textContent.replace(/•/g, '').trim() : '';
        
        if (homeTeam && awayTeam) {
            matches.push({
                date: currentDate,
                time: time,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                score: score,
                venue: venue
            });
        }
      }
    }
    
    return matches;
  }

  parseScheduleText(text) {
    const data = [];
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
    let isoDate = null;
    try {
        // date format: "Sun Nov 9" or similar
        // time format: "3:00 PM EST - 4:45 PM EST" or just "3:00 PM"
        
        const monthMap = { Jan:0, Feb:1, Mar:2, Apr:3, May:4, Jun:5, Jul:6, Aug:7, Sep:8, Oct:9, Nov:10, Dec:11 };
        let monthStr, dayStr;
        
        // Try to extract Month and Day
        const dateParts = date.split(' ');
        // Expected: ["Sun", "Nov", "9"]
        if (dateParts.length >= 3) {
            monthStr = dateParts[1];
            dayStr = dateParts[2];
        } else if (dateParts.length === 2) {
            // Maybe "Nov 9"
            monthStr = dateParts[0];
            dayStr = dateParts[1];
        }
        
        if (monthStr && dayStr && monthMap.hasOwnProperty(monthStr)) {
            const month = monthMap[monthStr];
            const day = parseInt(dayStr);
            const year = new Date().getFullYear(); // Assume current year
            
            // Parse time
            let hours = 12; // Default noon
            let minutes = 0;
            
            if (time) {
                const timeMatch = time.match(/(\d{1,2}):(\d{2})\s*([AP]M)/i);
                if (timeMatch) {
                    hours = parseInt(timeMatch[1]);
                    minutes = parseInt(timeMatch[2]);
                    const period = timeMatch[3].toUpperCase();
                    
                    if (period === 'PM' && hours !== 12) hours += 12;
                    if (period === 'AM' && hours === 12) hours = 0;
                }
            }
            
            const d = new Date(year, month, day, hours, minutes);
            // Adjust for timezone if needed, but for now assume local/UTC match or ignore
            isoDate = d.toISOString().replace('T', ' ').substring(0, 19);
        }
    } catch (e) {
        this.logWarning(`Failed to parse date: ${date} ${time}`);
    }

    const eventDateTime = isoDate || date; // Fallback to original if parsing fails
    
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
      external_source: 'casa',
      competition_name: divisionName
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
        
        for (const [id, team] of this.data.teams) {
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
          
          // Generate player ID and external ID
          if (!this.playerSeq) this.playerSeq = 1;
          const playerId = this.playerSeq++;
          const fullName = `${firstName} ${lastName}`;
          const externalPlayerId = `casa-player-${firstName.toLowerCase()}-${lastName.toLowerCase()}`.replace(/\s+/g, '-');
          
          // Check if player already exists (by external_id)
          let existingPlayerId = null;
          for (const [id, player] of this.data.players) {
            if (player.external_id === externalPlayerId) {
              existingPlayerId = id;
              break;
            }
          }
          
          // Create or update player in normalized players table
          if (!existingPlayerId) {
            this.data.players.set(playerId, {
              id: playerId,
              full_name: fullName,
              first_name: firstName,
              middle_name: null,
              last_name: lastName,
              preferred_name: null,
              birth_date: null,
              birth_year: null,
              height_cm: null,
              nationality: null,
              photo_url: null,
              source_system_id: this.SOURCE_SYSTEM_ID,
              external_id: externalPlayerId
            });
          }
          
          const finalPlayerId = existingPlayerId || playerId;
          
          // Create team-player association in team_players junction table
          if (!this.teamPlayerSeq) this.teamPlayerSeq = 1;
          const teamPlayerId = this.teamPlayerSeq++;
          
          this.data.teamPlayers = this.data.teamPlayers || new Map();
          this.data.teamPlayers.set(teamPlayerId, {
            id: teamPlayerId,
            team_id: teamId,
            player_id: finalPlayerId,
            jersey_number: jerseyNumber || null,
            position: position || null,
            is_active: true,
            joined_at: null,
            left_at: null
          });

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
    
    // Remove common suffixes that don't add meaning
    const suffixes = ['fc', 'sc', 'scm', 'scr'];
    for (const suffix of suffixes) {
      normalized = normalized.replace(new RegExp(`\\s+${suffix}\\b`, 'gi'), '');
    }
    
    // Normalize variations
    normalized = normalized
      .replace(/\bphilly\b/g, 'philadelphia')
      .replace(/\bblack\s+stars\b/g, 'blackstars')
      .replace(/\bunited\b/g, '') // Remove "united" - it's often inconsistent
      .replace(/\bclub\b/g, '') // Remove "club"
      .replace(/\bclub\s+de\s+futbol\b/g, 'cf') // "Club de Futbol" -> "cf"
      .replace(/\bcf\b/g, '') // Then remove cf like other suffixes
      .replace(/\s+ii\b/g, ' 2') // Normalize II to 2
      .replace(/\s+i\b/g, ' 1'); // Normalize I to 1
    
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
      // Leagues (normalized table)
      {
        filename: '03b-leagues-casa.sql',
        data: this.data.leagues,
        options: {
          title: 'CASA Leagues',
          tableName: 'leagues',
          useInserts: true,
          conflictColumns: ['id']
        }
      },
      // Conferences (normalized table)
      {
        filename: '04b-conferences-casa.sql',
        data: this.data.conferences,
        options: {
          title: 'CASA Conferences',
          tableName: 'conferences',
          useInserts: true,
          conflictColumns: ['id']
        }
      },
      // Divisions (normalized table)
      {
        filename: '05b-league-divisions-casa.sql',
        data: this.data.divisions,
        options: {
          title: 'CASA Divisions',
          tableName: 'divisions',
          useInserts: true,
          conflictColumns: ['id']
        }
      },
      // Teams (normalized table)
      {
        filename: '21b-teams-casa.sql',
        data: this.data.teams,
        options: {
          title: 'CASA Teams',
          tableName: 'teams',
          useInserts: true,
          conflictColumns: ['external_id', 'source_system_id']
        }
      },
      // Team Divisions (junction table linking teams to league divisions)
      {
        filename: '22b-team-divisions-casa.sql',
        data: this.data.teamDivisions,
        options: {
          title: 'CASA Team Divisions',
          tableName: 'team_divisions',
          useInserts: true,
          conflictColumns: ['team_id', 'division_id']
        }
      },
      // Players (normalized table)
      {
        filename: '24b-players-casa.sql',
        data: this.data.players,
        options: {
          title: 'CASA Players',
          tableName: 'players',
          useInserts: true,
          conflictColumns: ['external_id', 'source_system_id']
        }
      },
      // Team Players (normalized junction table)
      {
        filename: '26b-team-players-casa.sql',
        data: this.data.teamPlayers,
        options: {
          title: 'CASA Team Players',
          tableName: 'team_players',
          useInserts: true,
          conflictColumns: ['team_id', 'player_id']
        }
      },
      // Matches (normalized table)
      {
        filename: '30b-schedule-casa.sql',
        data: this.data.matches,
        options: {
          title: 'CASA Schedule',
          tableName: 'matches',
          useInserts: true,
          conflictColumns: ['external_id', 'source_system_id']
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
