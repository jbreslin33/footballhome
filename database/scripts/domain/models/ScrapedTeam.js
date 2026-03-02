/**
 * Scraped Team Domain Model
 * 
 * Represents teams scraped from external sources (APSL, CASA, etc.)
 * These are simpler than internal club teams and link to clubs via club_id
 */
class ScrapedTeam {
  constructor({ 
    name,
    divisionId = null,
    clubId = null,
    city = null,
    logoUrl = null,
    sourceSystemId = null,
    externalId = null
  }) {
    this.name = name;
    this.divisionId = divisionId;
    this.clubId = clubId;
    this.city = city;
    this.logoUrl = logoUrl;
    this.sourceSystemId = sourceSystemId;
    this.externalId = externalId;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid team name: ${this.name}`);
    }
  }
  
  toDbRow() {
    return {
      name: this.name,
      division_id: this.divisionId,
      club_id: this.clubId,
      city: this.city,
      logo_url: this.logoUrl,
      source_system_id: this.sourceSystemId,
      external_id: this.externalId
    };
  }
  
  toString() {
    return this.name;
  }
}

module.exports = ScrapedTeam;
