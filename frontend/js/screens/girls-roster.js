// GirlsRosterScreen — BoysRosterScreen narrowed to the Girls Club.
// Girls play on boys teams, so both boards run the same
// `/api/boys-roster` fetch, buckets, cards, delinquency + drag/drop;
// the Boys board shows the whole team (girls included) and this one
// keeps only Girls Club players (owner 2026-09-24: "when we click boys
// it should always show girls but girls should only show girls").
// Before that the two boards were byte-for-byte the same data with a
// different title (user directive 2026-07-07).
//
// Override: keepPlayer() (the filter); everything else, DOM ids
// included (#br-banner, #br-list, #br-refresh, …), is the parent's.
class GirlsRosterScreen extends BoysRosterScreen {
  boardScopeLabel() { return 'all girls'; }

  // `club` is set per player by BoysRoster.cpp shapePlayer from which LA
  // programme they are registered in ("Boys Club" / "Girls Club").
  keepPlayer(p) { return !!p && p.club === 'Girls Club'; }
}
