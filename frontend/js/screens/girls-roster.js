// GirlsRosterScreen — mirror of BoysRosterScreen with a girls-focused
// label + subtitle.  Girls currently play on boys teams, so the DATA
// on both boards is identical — same `/api/boys-roster` fetch, same
// buckets, same cards, same delinquency + drag/drop behaviour.  Only
// the header text differs so a coach clicking "Girls Roster" from
// the admin dashboard lands on a page that reads "girls" everywhere
// (they were confused by the "Boys Roster Board" title when they
// wanted the girls view — user directive 2026-07-07).
//
// Everything else is inherited unchanged from BoysRosterScreen: the
// only override is render(), which swaps the <h1> + subtitle and
// otherwise reuses the exact same DOM ids (#br-banner, #br-list,
// #br-refresh, etc.) so every parent method binds identically.
class GirlsRosterScreen extends BoysRosterScreen {
  render() {
    const el = super.render();
    const h1 = el.querySelector('.screen-header h1');
    if (h1) h1.textContent = '🎽 Girls Roster Board';
    const sub = el.querySelector('.screen-header .subtitle');
    if (sub) sub.textContent = 'Live from LeagueApps — Girls + Boys Club (both surfaced; girls play on boys teams for now)';
    return el;
  }
}
