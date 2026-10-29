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
    this.clubs = this.data.clubs || [];
    this.seasons = this.data.seasons || [];
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

  // ── clubs on the map (mig 844) ───────────────────────────────────────
  // A club's point: its home ground when geocoded, else the point of the
  // league of its first table (approx = true — the league publishes no
  // address).  null = nowhere to put it yet.
  clubPoint(club) {
    if (club.lat != null && club.lon != null) return { lat: club.lat, lon: club.lon, approx: false };
    for (const id of club.divisions || []) {
      const d = this.division(id);
      const p = d && this.compPoint(d.competition_id);
      if (p) return { ...p, approx: true };
    }
    return null;
  }

  // A league's point: the middle of its clubs that have a home ground,
  // else its geocoded region (pyramid_competitions.lat/lon).
  compPoint(compId) {
    if (!this._compPoints) {
      this._compPoints = new Map();
      const sums = new Map();
      for (const club of this.clubs) {
        if (club.lat == null || club.lon == null) continue;
        for (const id of club.divisions || []) {
          const d = this.division(id);
          if (!d) continue;
          const a = sums.get(d.competition_id) || { lat: 0, lon: 0, n: 0 };
          a.lat += club.lat; a.lon += club.lon; a.n += 1;
          sums.set(d.competition_id, a);
        }
      }
      for (const [id, a] of sums) this._compPoints.set(id, { lat: a.lat / a.n, lon: a.lon / a.n });
    }
    if (this._compPoints.has(compId)) return this._compPoints.get(compId);
    const c = this.comp(compId);
    return c && c.lat != null && c.lon != null ? { lat: c.lat, lon: c.lon } : null;
  }

  // 'apsl' when the club has a team in an APSL conference table, else 'feeder'.
  clubTier(club) {
    return (club.divisions || []).some((id) => { const d = this.division(id); const c = d && this.comp(d.competition_id); return c && c.kind === 'conference'; })
      ? 'apsl' : 'feeder';
  }

  // The clubs of one conference column: its own tables + every feeder.
  columnClubs(col) {
    const ids = new Set([...col.top, ...col.reach].map((d) => d.id));
    return this.clubs.filter((c) => (c.divisions || []).some((id) => ids.has(id)));
  }

  // "League · table" names of a club's teams (the map popup).
  clubTables(club) {
    return (club.divisions || []).map((id) => this.division(id)).filter(Boolean)
      .map((d) => `${this.label(this.comp(d.competition_id))} · ${d.name}`);
  }

  // ── a club's way up (Club pathway view) ──────────────────────────────
  // Every route from a table up the promoting links to the top: arrays of
  // node ids from the table itself ("d<id>") to where it ends — a
  // conference ("c<id>") or a table nothing promotes out of.  A table with
  // two links up (North Jersey Liga 1 → Delaware River / Metropolitan) has
  // two routes.
  upRoutes(divId) {
    const out = [];
    const walk = (id, path) => {
      const ups = this.links.filter((l) => l.lower === id && l.promotes);
      if (!ups.length) { out.push(path); return; }
      for (const l of ups) {
        if (l.upper_competition) out.push([...path, `c${l.upper_competition}`]);
        else if (l.upper_division && !path.includes(`d${l.upper_division}`)) walk(l.upper_division, [...path, `d${l.upper_division}`]);
      }
    };
    walk(divId, [`d${divId}`]);
    return out;
  }

  // Steps a route climbs to reach an APSL conference (null = it never does).
  routeSteps(route) {
    const last = route[route.length - 1];
    if (last[0] === 'c') return route.length - 1;
    const d = this.division(Number(last.slice(1)));
    const c = d && this.comp(d.competition_id);
    return c && c.kind === 'conference' ? route.length - 1 : null;
  }

  clubByName(name) {
    const k = String(name || '').trim().toLowerCase();
    return this.clubs.find((c) => c.name.toLowerCase() === k) || null;
  }

  // ── seasons (Growth by season, mig 847) ──────────────────────────────
  // A league's seasons, oldest first, each with teams per competition.
  leagueSeasons(leagueId) {
    return this.seasons.filter((x) => x.league_id === leagueId).sort((a, b) => a.name.localeCompare(b.name));
  }
  seasonTeams(season, compId) {
    const e = (season.by_competition || []).find((x) => x.competition_id === compId);
    return e ? e.teams : 0;
  }
  // Sides that season in conferences that no longer exist (Northeast…).
  seasonFormer(season) {
    return (season.by_competition || []).filter((x) => x.kind === 'conference' && !x.active).reduce((a, x) => a + x.teams, 0);
  }
  seasonFormerNames(season) {
    return (season.by_competition || []).filter((x) => x.kind === 'conference' && !x.active).map((x) => x.name);
  }

  // Leagues other than the root that have past seasons stored.
  leaguesWithSeasons() {
    const root = this.root();
    return [...new Set(this.seasons.map((x) => x.league_id))].filter((id) => !root || id !== root.id).map((id) => this.comp(id)).filter(Boolean);
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
