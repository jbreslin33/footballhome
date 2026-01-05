/**
 * Scraped Team Domain Model
 * 
 * Represents teams scraped from external sources (APSL, CASA, etc.)
 * These are simpler than internal club teams and link to clubs via club_id
 */
class ScrapedTeam {
  constructor({ 
    name,
    clubId = null,
    city = null,
    logoUrl = null,
    sourceSystemId = null,
    externalId = null,
    scrapeTargetId = null
  }) {
    this.name = name;
    this.clubId = clubId;
    this.city = city;
    this.logoUrl = logoUrl;
    this.sourceSystemId = sourceSystemId;
    this.externalId = externalId;
    this.scrapeTargetId = scrapeTargetId;
    
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
      club_id: this.clubId,
      city: this.city,
      logo_url: this.logoUrl,
      source_system_id: this.sourceSystemId,
      external_id: this.externalId,
      scrape_target_id: this.scrapeTargetId
    };
  }
  
  toString() {
    return this.name;
  }
}

module.exports = ScrapedTeam;
