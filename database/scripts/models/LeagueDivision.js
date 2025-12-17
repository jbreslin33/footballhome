class LeagueDivision {
  constructor(data) {
    this.id = data.id;
    this.conference_id = data.conference_id;
    this.name = data.name;
    this.display_name = data.display_name;
    this.slug = data.slug;
    this.tier = data.tier || 1;
    this.hierarchy_group = data.hierarchy_group || null;
    this.skill_level = data.skill_level || null;
    this.age_group = data.age_group || null;
    this.description = data.description || null;
    this.max_teams = data.max_teams || null;
    this.promotion_eligible = data.promotion_eligible !== undefined ? data.promotion_eligible : false;
    this.relegation_eligible = data.relegation_eligible !== undefined ? data.relegation_eligible : false;
    this.is_active = data.is_active !== undefined ? data.is_active : true;
  }

  toSQL() {
    const values = [
      this.id,
      this.conference_id,
      this.name,
      this.display_name,
      this.slug,
      this.tier,
      this.hierarchy_group,
      this.skill_level,
      this.age_group,
      this.description,
      this.max_teams,
      this.promotion_eligible,
      this.relegation_eligible,
      this.is_active
    ];

    const escapedValues = values.map(v => {
      if (v === null || v === undefined) return 'NULL';
      if (typeof v === 'boolean') return v ? 'true' : 'false';
      if (typeof v === 'number') return v;
      return `'${String(v).replace(/'/g, "''")}'`;
    });

    return `(${escapedValues.join(', ')})`;
  }
}

module.exports = LeagueDivision;
