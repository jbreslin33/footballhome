// GirlsRosterScreen — BoysRosterScreen narrowed to the Girls Club.
// Girls play on boys teams, so both boards run the same
// `/api/boys-roster` fetch, buckets, cards, delinquency + drag/drop;
// the Boys board shows the whole team (girls included) and this one
// keeps only Girls Club players (owner 2026-09-24: "when we click boys
// it should always show girls but girls should only show girls").
// Before that the two boards were byte-for-byte the same data with a
// different title (user directive 2026-07-07).
//
// Overrides: keepPlayer() (the filter) and render(), which swaps the
// <h1> + subtitle and otherwise reuses the exact same DOM ids
// (#br-banner, #br-list, #br-refresh, etc.) so every parent method
// binds identically.
class GirlsRosterScreen extends BoysRosterScreen {
  boardScopeLabel() { return 'all girls'; }

  // `club` is set per player by BoysRoster.cpp shapePlayer from which LA
  // programme they are registered in ("Boys Club" / "Girls Club").
  keepPlayer(p) { return !!p && p.club === 'Girls Club'; }

  render() {
    const el = super.render();
    const h1 = el.querySelector('.screen-header h1');
    if (h1) h1.textContent = '🎽 Girls Teams';
    const sub = el.querySelector('.screen-header .subtitle');
    if (sub) sub.textContent = 'Live from LeagueApps — Girls Club only (girls play on boys teams; the Boys pill shows the whole team)';
    return el;
  }
}
