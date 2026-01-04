/**
 * Division Domain Model
 * Represents a competitive tier within a conference
 */
class Division {
  constructor({ 
    id = null, 
    seasonId = null,
    conferenceId = null,
    name, 
    divisionTypeId = 1, // Default: league play
    skillLevel = null,
    skillLabel = null,
    sourceSystemId = null,
    externalId = null,
    sortOrder = 0,
    isActive = true 
  }) {
    this.id = id;
    this.seasonId = seasonId;
    this.conferenceId = conferenceId;
    this.name = name;
    this.divisionTypeId = divisionTypeId;
    this.skillLevel = skillLevel;
    this.skillLabel = skillLabel;
    this.sourceSystemId = sourceSystemId;
    this.externalId = externalId;
    this.sortOrder = sortOrder;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim() === '') {
      throw new Error('Division name is required');
    }
    if (this.conferenceId !== null && typeof this.conferenceId !== 'number') {
      throw new Error('conferenceId must be a number or null');
    }
    if (this.seasonId !== null && typeof this.seasonId !== 'number') {
      throw new Error('seasonId must be a number or null');
    }
  }
  
  toDbRow() {
    return {
      season_id: this.seasonId,
      conference_id: this.conferenceId,
      name: this.name,
      division_type_id: this.divisionTypeId,
      skill_level: this.skillLevel,
      skill_label: this.skillLabel,
      source_system_id: this.sourceSystemId,
      external_id: this.externalId,
      sort_order: this.sortOrder
    };
  }
  
  toString() {
    return `Division(${this.id}, "${this.name}", conference_id=${this.conferenceId})`;
  }
}

module.exports = Division;
