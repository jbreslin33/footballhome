const { JSDOM } = require('jsdom');
const Organization = require('../../domain/models/Organization');
const League = require('../../domain/models/League');
const Season = require('../../domain/models/Season');
const Conference = require('../../domain/models/Conference');
const Division = require('../../domain/models/Division');

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
   * @returns {Object} { organization, league, season, conferences, divisions }
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
          externalId: externalId,
          isActive: true
        });
        
        conferences.push(conference);
      } catch (error) {
        console.warn(`Skipping invalid conference: ${error.message}`);
      }
    }
    
    return {
      organization,
      league,
      season,
      conferences,
      divisions: this.createDivisionsForConferences(conferences)
    };
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
