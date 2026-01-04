const Country = require('../../domain/models/Country');

/**
 * REST Countries API Parser
 * 
 * Transforms REST Countries API response into Country domain models.
 * Handles continent name mapping to codes.
 */
class RestCountriesParser {
  constructor() {
    // Map REST Countries API continent names to our database codes
    this.continentMap = {
      'Africa': 'AF',
      'Antarctica': 'AN',
      'Asia': 'AS',
      'Europe': 'EU',
      'North America': 'NA',
      'Oceania': 'OC',
      'South America': 'SA'
    };
  }
  
  /**
   * Parse REST Countries API response
   * @param {Array} rawData - Array of country objects from API
   * @returns {Country[]} Array of Country domain models
   */
  parse(rawData) {
    const countries = [];
    
    for (const item of rawData) {
      try {
        // Skip if missing required data
        if (!item.cca3 || !item.name) continue;
        
        // Get primary continent (some countries span multiple)
        const continentName = item.continents?.[0];
        const continentCode = continentName ? this.continentMap[continentName] : null;
        
        // Create domain model (validates automatically)
        const country = new Country({
          code: item.cca3,
          name: item.name?.common || item.name?.official,
          fifaCode: item.fifa || null,
          continentCode: continentCode
        });
        
        countries.push(country);
      } catch (error) {
        // Log validation errors but continue processing
        console.warn(`Skipping invalid country: ${error.message}`);
      }
    }
    
    return countries;
  }
}

module.exports = RestCountriesParser;
