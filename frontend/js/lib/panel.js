// Panel — one block on an Event Center pill (docs/event-center-design.md,
// slice 4).
//
// Owner 2026-11-14: "the coach screen should just be more enhanced then
// player/parent. the admin just more enhanced then coach".  A screen lists
// its panels per pill; each says the LOWEST viewer tier that gets it and
// whether it exists for this event at all.  The screen keeps only the ones
// its viewer (lib/viewer.js) reaches, in order — so a coach sees exactly
// the player's page plus the coach panels, an admin the coach's plus theirs,
// and "👀 See as player" is just a lower viewer over the same list.
//
//   new Panel({ key, minTier, applies, html })
//     key      stable id (fold memory, tests)
//     minTier  'player' | 'coach' | 'admin'  (default player)
//     applies  (screen) → bool — does this panel exist for this event / team?
//              (a carpool on a practice, invites while it is still to come …)
//     html     (screen) → string — the panel's markup; '' = nothing to show
//
// Inside a panel, what a tier may DO on a row (mark P/A/L/E, answer for
// someone) still asks the viewer — Panel only decides what is on the page.
class Panel {
  constructor({ key, minTier = 'player', applies = null, html }) {
    this.key = key;
    this.minTier = minTier;
    this._applies = applies;
    this._html = html;
  }

  // Shown to this screen's viewer, for this event?
  shownTo(screen) {
    const v = screen.viewer;
    if (!v || !v.atLeast(this.minTier)) return false;
    return this._applies ? !!this._applies(screen) : true;
  }

  html(screen) { return this._html ? (this._html(screen) || '') : ''; }

  // The kept panels' markup, in list order.
  static render(panels, screen) {
    return (panels || []).filter(p => p && p.shownTo(screen)).map(p => p.html(screen)).join('');
  }
}

window.Panel = Panel;
