// pyramid-model.js — the ONE source every #apsl-pyramid view draws from
// (migrations 819–836).  Owner 2026-10-29: "make sure they all draw from
// same source these are just views."
//
// Built from a single GET /api/pyramid response: competitions (APSL →
// conferences → affiliates), every mirrored table with its effective zones
// and standings, the links between tables (pyramid_links: promotion up,
// relegation down) and the zone kinds (label, colour, which way they move).
// Everything derived — which tables sit in which column and level, the
// arrows, counts, titles, where a zone's teams go — is computed here once,
// so the flow chart, the presentation and every later view agree.
class PyramidModel {
  constructor(data) {
    this.data = data || {};
    this.competitions = this.data.competitions || [];
    this.divisions = this.data.divisions || [];
    this.links = this.data.links || [];
    this.kinds = this.data.zone_kinds || [];
    this.totals = this.data.totals || {};
    this._comp = new Map(this.competitions.map((c) => [c.id, c]));
    this._div = new Map(this.divisions.map((d) => [d.id, d]));
    this._compOrder = new Map(this.competitions.map((c, i) => [c.id, i]));
    this._kind = new Map(this.kinds.map((k, i) => [k.code, { ...k, rank: i }]));
  }

  root() { return this._comp.get(this.data.root_id) || null; }
  comp(id) { return this._comp.get(id) || null; }
  division(id) { return this._div.get(id) || null; }
  conferences() { return this.competitions.filter((c) => c.kind === 'conference'); }
  label(c) { return c ? (c.short_name || c.name) : ''; }

  // ── zones (pyramid_zone_kinds, mig 827) ──────────────────────────────
  kindColor(code) { const k = this._kind.get(code); return k ? k.color : '#64748b'; }
  kindLabel(code) { const k = this._kind.get(code); return k ? k.label : code; }
  zoneOf(d, pos) { return (d.zones || []).find((z) => pos >= z.from && pos <= z.to) || null; }
  // Every kind in use, in pyramid_zone_kinds order (the legend).
  zonesInUse() {
    const seen = new Map();
    for (const d of this.divisions) for (const z of d.zones || []) if (!seen.has(z.kind)) seen.set(z.kind, z);
    return [...seen.values()].sort((a, b) => ((this._kind.get(a.kind) || {}).rank ?? 99) - ((this._kind.get(b.kind) || {}).rank ?? 99));
  }

  // Where a table's zone sends its teams, as model ids: up → the level
  // above along promoting links; down → every table linked below
  // (into this table, or into its whole conference).
  moveTargets(d, zone) {
    if (!zone || !zone.moves) return [];
    if (zone.moves === 'up')
      return this.links.filter((l) => l.lower === d.id && l.promotes)
        .map((l) => (l.upper_competition ? `c${l.upper_competition}` : `d${l.upper_division}`));
    return this.links.filter((l) => l.relegates && (l.upper_division === d.id || l.upper_competition === d.competition_id))
      .map((l) => `d${l.lower}`);
  }

  // Conferences a feeder table links into, other than `exceptConfId`.
  alsoFeeds(divId, exceptConfId) {
    return this.links.filter((l) => l.lower === divId && l.upper_competition && l.upper_competition !== exceptConfId)
      .map((l) => this.comp(l.upper_competition)).filter(Boolean);
  }

  // A conference's own tables are titled by the part after its name
  // ("Group A", "Chesapeake (Maryland)"); a single table needs none.
  confTableTitle(col, d) {
    return col.top.length > 1 ? (d.name.split(/\s-\s?/).slice(1).join(' - ') || d.name) : '';
  }

  // Clubs / teams a conference column counts: its own tables + every table
  // feeding it (shared ones too), counted tables only.
  columnCounts(col) {
    const counted = [...col.top, ...col.reach].filter((d) => d.counts);
    return {
      teams: counted.reduce((a, d) => a + d.teams.length, 0),
      clubs: new Set(counted.flatMap((d) => d.teams.map((t) => t.club))).size,
    };
  }

  // ── layout: conferences on one row, feeder levels below ──────────────
  // Each conference is a column; its feeders stack under it, level by level
  // (walking the links down).  A table that feeds two conferences sits in
  // the first one's column, once, with a link to each.  Rows are shared
  // across columns, so every level lines up.
  layout(confs) {
    const confIds = new Set(confs.map((c) => c.id));
    const mirrored = new Set(this.divisions.map((d) => d.competition_id));
    const placed = new Set();
    const edges = [];
    const byName = (a, b) => (this._compOrder.get(this.division(a).competition_id) - this._compOrder.get(this.division(b).competition_id))
      || this.division(a).name.localeCompare(this.division(b).name);
    const columns = confs.map((conf) => {
      const levels = [];
      let current = [...new Set(this.links.filter((l) => l.upper_competition === conf.id && this._div.has(l.lower)).map((l) => l.lower))]
        .filter((id) => !placed.has(id)).sort(byName);
      while (current.length) {
        current.forEach((id) => placed.add(id));
        levels.push(current);
        const next = [];
        for (const target of current)
          for (const l of this.links)
            if (l.upper_division === target && this._div.has(l.lower) && !placed.has(l.lower) && !next.includes(l.lower)) next.push(l.lower);
        current = next;
      }
      const reach = new Set(this.links.filter((l) => l.upper_competition === conf.id).map((l) => l.lower));
      for (let grew = true; grew;) {
        grew = false;
        for (const l of this.links) if (l.upper_division && reach.has(l.upper_division) && !reach.has(l.lower)) { reach.add(l.lower); grew = true; }
      }
      return {
        conf, levels,
        top: this.divisions.filter((d) => d.competition_id === conf.id),
        reach: [...reach].map((id) => this.division(id)).filter(Boolean),
        unmirrored: this.competitions.filter((c) => c.parent_id === conf.id && !mirrored.has(c.id)),
      };
    });
    // One arrow per link: head up if it promotes, head down if it relegates.
    for (const l of this.links) {
      if (!placed.has(l.lower)) continue;
      const e = { from: l.lower, up: l.promotes, down: l.relegates };
      if (l.upper_competition && confIds.has(l.upper_competition)) edges.push({ ...e, to: `c${l.upper_competition}` });
      else if (l.upper_division && placed.has(l.upper_division)) edges.push({ ...e, to: `d${l.upper_division}` });
    }
    return { columns, edges };
  }
}
window.PyramidModel = PyramidModel;
