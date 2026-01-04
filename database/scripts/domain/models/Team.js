/**
 * Team Domain Model
 * 
 * Near the end of hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class Team {
  constructor({ 
    name, 
    displayName, 
    sportDivisionId,
    clubId = null,
    homeVenueId = null,
    slug,
    isActive = true 
  }) {
    this.name = name;
    this.displayName = displayName;
    this.sportDivisionId = sportDivisionId;
    this.clubId = clubId;
    this.homeVenueId = homeVenueId;
    this.slug = slug;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid team name: ${this.name}`);
    }
    
    if (!this.sportDivisionId) {
      throw new Error(`Team must have a sport_division_id`);
    }
  }
  
  toDbRow() {
    return {
      name: this.name,
      display_name: this.displayName,
      sport_division_id: this.sportDivisionId,
      club_id: this.clubId,
      home_venue_id: this.homeVenueId,
      slug: this.slug,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.displayName || this.name}`;
  }
}

module.exports = Team;
