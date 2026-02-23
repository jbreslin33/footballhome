const { JSDOM } = require('jsdom');
const Organization = require('../../domain/models/Organization');
const League = require('../../domain/models/League');
const Season = require('../../domain/models/Season');
const Conference = require('../../domain/models/Conference');
const Division = require('../../domain/models/Division');
const ScrapedTeam = require('../../domain/models/ScrapedTeam');

/**
 * APSL Standings Parser
 * 
 * Parses APSL standings page to extract:
 * - Organization (APSL)
 * - League (American Premier Soccer League)
 * - Season (2025/2026)
 * - Conferences (Mayflower, Constitution, etc.)
 * - Divisions (1 per conference - APSL business rule)
 */
class ApslStandingsParser {
  /**
   * Parse APSL standings HTML
   * @param {string} html - Raw HTML from standings page
   * @returns {Object} { organization, league, season, conferences, divisions, divisionTeams }
   */
  parse(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Extract organization
    const organization = new Organization({
      name: 'American Premier Soccer League',
      shortName: 'APSL',
      website: 'https://apslsoccer.com',
      isActive: true
    });
    
    // Extract league (for now, APSL only has one league)
    const league = new League({
      name: 'American Premier Soccer League',
      organizationId: null, // Will be filled by scraper
      isActive: true
    });
    
    // Extract season from first conference heading and dropdown
    let seasonName = null;
    let seasonExternalId = null;
    
    const firstHeading = document.querySelector('.leagueAccordTitle1');
    if (firstHeading) {
      // Extract "2025/2026" from "2025/2026 - Mayflower Conference"
      const match = firstHeading.textContent.match(/(\d{4}\/\d{4})/);
      if (match) {
        seasonName = match[1];
      }
    }
    
    // Map of season names to external IDs from APSL dropdown
    const SEASON_EXTERNAL_IDS = {
      '2022/2023': '396',
      '2023/2024': '2597',
      '2024/2025': '6020',
      '2025/2026': '7930'
    };
    
    seasonExternalId = SEASON_EXTERNAL_IDS[seasonName] || null;
    
    const season = new Season({
      name: seasonName || '2025/2026',
      leagueId: null, // Will be filled by scraper
      sourceSystemId: 1, // APSL
      externalId: seasonExternalId,
      isActive: true
    });
    
    // Extract conferences from dropdown
    const conferences = [];
    const options = document.querySelectorAll('select option[value]');
    
    // Known fake conferences: previous seasons masquerading as conferences
    // These appear in the season dropdown and should be filtered out
    const FAKE_CONFERENCE_IDS = Object.values(SEASON_EXTERNAL_IDS);
    
    for (const option of options) {
      const value = option.getAttribute('value');
      if (!value || value === '') continue; // Skip "All" option
      
      // Parse value: "17825,0" where 17825 is conference ID
      const [externalId] = value.split(',');
      
      // Skip fake conferences (previous seasons)
      if (FAKE_CONFERENCE_IDS.includes(externalId)) {
        continue;
      }
      
      // Parse text: "Mayflower Conference (8 Teams)"
      const text = option.textContent.trim();
      const nameMatch = text.match(/^(.+?)\s*\(/);
      const conferenceName = nameMatch ? nameMatch[1].trim() : text;
      
      try {
        const conference = new Conference({
          name: conferenceName,
          seasonId: null, // Will be filled by scraper
          sourceSystemId: 1, // APSL
          externalId: externalId,
          isActive: true
        });
        
        conferences.push(conference);
      } catch (error) {
        console.warn(`Skipping invalid conference: ${error.message}`);
      }
    }
    
    // Extract teams grouped by division
    const { divisionTeams, allTeams } = this.extractTeamsWithDivisions(document, conferences);
    
    return {
      organization,
      league,
      season,
      conferences,
      divisions: this.createDivisionsForConferences(conferences),
      teams: allTeams,
      divisionTeams: divisionTeams
    };
  }
  
  /**
   * Extract teams grouped by division from standings page
   * @param {Document} document - jsdom document
   * @param {Array} conferences - Conference models from dropdown
   * @returns {Object} { divisionTeams: [{conferenceName, teams, standings}], allTeams: [ScrapedTeam] }
   */
  extractTeamsWithDivisions(document, conferences) {
    const divisionTeams = [];
    const allTeamsMap = new Map(); // Track unique teams by name
    
    // Find all conference sections with class "leagueAccordTitle1"
    const conferenceSections = document.querySelectorAll('.leagueAccordTitle1');
    
    for (const titleElement of conferenceSections) {
      // Extract conference name from heading: "2025/2026 - Mayflower Conference"
      const fullText = titleElement.textContent.trim();
      const match = fullText.match(/^\d{4}\/\d{4}\s*-\s*(.+)$/);
      
      if (!match) continue;
      
      const conferenceName = match[1].trim();
      
      // Find the standings table following this heading
      // HTML structure: titleElement is inside a parent div, and accordBox is the next sibling of that parent
      // <div>
      //   <div class="leagueAccordTitle1">...</div>
      //   <div class="leagueAccordTitle2">...</div>
      // </div>
      // <div class="leagueAccordbox">...</div>
      let accordBox = titleElement.parentElement.nextElementSibling;
      while (accordBox && !accordBox.classList.contains('leagueAccordbox')) {
        accordBox = accordBox.nextElementSibling;
      }
      
      if (!accordBox) continue;
      
      // Extract teams and standings from this standings table
      const { teams, standings } = this.extractTeamsFromTable(accordBox, allTeamsMap);
      
      if (teams.length > 0) {
        divisionTeams.push({
          conferenceName: conferenceName,
          teams: teams,
          standings: standings
        });
      }
    }
    
    return {
      divisionTeams: divisionTeams,
      allTeams: Array.from(allTeamsMap.values())
    };
  }
  
  /**
   * Extract teams and standings from a standings table section
   * @param {Element} accordBox - The div.leagueAccordbox containing the standings table
   * @param {Map} allTeamsMap - Map to track unique teams (mutated)
   * @returns {Object} { teams: [ScrapedTeam], standings: [{teamName, stats}] }
   */
  extractTeamsFromTable(accordBox, allTeamsMap) {
    const teams = [];
    const standings = [];
    
    // Find all table rows (each row is a team with stats)
    const rows = accordBox.querySelectorAll('tr.TableRow0, tr.TableRow1');
    
    for (const row of rows) {
      // Extract position (rank)
      const positionCell = row.querySelector('td:first-child');
      if (!positionCell) continue;
      const position = parseInt(positionCell.textContent.trim()) || 0;
      
      // Extract team link and name
      const teamLink = row.querySelector('a[href*="/APSL/Team/"]');
      if (!teamLink) continue;
      
      const nameDiv = teamLink.querySelector('div[style*="margin-left"]');
      if (!nameDiv) continue;
      
      const teamName = nameDiv.textContent.trim();
      if (!teamName || teamName.length < 3) continue;
      
      // Extract external ID from href: /APSL/Team/114814
      const href = teamLink.getAttribute('href');
      const externalIdMatch = href.match(/\/Team\/(\d+)/);
      const externalId = externalIdMatch ? externalIdMatch[1] : null;
      
      // Extract standings stats from remaining cells
      const cells = Array.from(row.querySelectorAll('td'));
      // Format: Rank | Team | MP | W | D | L | GF | GA | GD | Pts
      // cells[0] = rank, cells[1] = team, cells[2+] = stats
      
      let played = 0, wins = 0, draws = 0, losses = 0;
      let goalsFor = 0, goalsAgainst = 0, goalDiff = 0, points = 0;
      
      if (cells.length >= 10) {
        played = parseInt(cells[2]?.textContent.trim()) || 0;
        wins = parseInt(cells[3]?.textContent.trim()) || 0;
        draws = parseInt(cells[4]?.textContent.trim()) || 0;
        losses = parseInt(cells[5]?.textContent.trim()) || 0;
        goalsFor = parseInt(cells[6]?.textContent.trim()) || 0;
        goalsAgainst = parseInt(cells[7]?.textContent.trim()) || 0;
        goalDiff = parseInt(cells[8]?.textContent.trim()) || 0;
        points = parseInt(cells[9]?.textContent.trim()) || 0;
      }
      
      // Create or reuse team model
      if (!allTeamsMap.has(teamName)) {
        const team = new ScrapedTeam({
          name: teamName,
          sourceSystemId: 1, // APSL
          externalId: externalId
        });
        allTeamsMap.set(teamName, team);
      }
      
      teams.push(allTeamsMap.get(teamName));
      
      // Store standings stats
      standings.push({
        teamName,
        externalId,
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
    
    return { teams, standings };
  }
  
  /**
   * Check if text looks like a team name
   * @param {string} text
   * @returns {boolean}
   */
  looksLikeTeamName(text) {
    // Must not be a conference name
    if (text.includes('Conference')) return false;
    
    // Must not be a common UI element
    const skipWords = ['Standings', 'Schedule', 'Table', 'Division', 'League', 'Season'];
    if (skipWords.some(word => text.includes(word))) return false;
    
    // Common team suffixes/keywords
    const teamIndicators = ['FC', 'SC', 'United', 'City', 'Athletic', 'Rovers', 'Wanderers', 
                            'AFC', 'CFC', 'RFC', 'Club', 'CF', 'AC', 'Real'];
    
    // Check if it contains any team indicator
    return teamIndicators.some(indicator => text.includes(indicator));
  }
  
  /**
   * Create 1 division per conference (APSL business rule)
   * Division name = conference name without "Conference" suffix
   * @param {Array} conferences - Conference models
   * @returns {Array} Division models
   */
  createDivisionsForConferences(conferences) {
    return conferences.map(conference => {
      // Strip "Conference" suffix from name
      const divisionName = conference.name.replace(/\s+Conference$/i, '').trim();
      
      return new Division({
        name: divisionName,
        conferenceId: null, // Will be filled by scraper after conference is saved
        seasonId: null,      // Will be filled by scraper
        externalId: conference.externalId, // Use same external_id as conference
        sourceSystemId: conference.sourceSystemId,
        divisionTypeId: 1,   // Standard league play
        isActive: true
      });
    });
  }
}

module.exports = ApslStandingsParser;
