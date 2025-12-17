class LeagueConference {
  constructor(data) {
    this.id = data.id;
    this.league_id = data.league_id;
    this.name = data.name;
    this.display_name = data.display_name;
    this.slug = data.slug;
    this.description = data.description || null;
    this.contact_email = data.contact_email || null;
    this.contact_phone = data.contact_phone || null;
    this.is_active = data.is_active !== undefined ? data.is_active : true;
  }

  toSQL() {
    const values = [
      this.id,
      this.league_id,
      this.name,
      this.display_name,
      this.slug,
      this.description,
      this.contact_email,
      this.contact_phone,
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

module.exports = LeagueConference;
