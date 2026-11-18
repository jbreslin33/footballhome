// Viewer — how much one person gets on one event (docs/event-center-design.md).
//
// Owner 2026-11-14: "the coach screen should just be more enhanced then
// player/parent. the admin just more enhanced then coach" + "we just check
// what they are and have a class for each possibility … use correct class for
// each user to show what needs showing".
//
//   PlayerViewer  →  CoachViewer  →  AdminViewer
//
// Each child adds to its parent and never takes away, so nothing a player
// sees moves or changes when a coach opens the same event.  The tier is per
// event and comes from the server (viewer_tier on the calendar feed and the
// attendance GET — EventAccess / fh_event_viewer_tier, mig 1362); view-as is
// already folded in there.  Screens ask the viewer, never a role.
//
// What a team or section HAS (a GroupMe chat, carpool, dues …) is a separate
// question answered by DB rows, not by these classes.
//
// The same ladder also answers for the whole APP — the menu bar, the header
// line, how the Calendar draws (owner 11/18: players "only need calendar" →
// no Account, type pills, Back, header, Week·Month, date picker; "remember
// its always oop and should keep looking to extend from a base class").
// Viewer.account() picks the class for the signed-in account (its MainMenu
// access); Viewer.for(tier) stays the per-event pick.

class PlayerViewer {
  get tier() { return 'player'; }
  get rank() { return 0; }
  atLeast(tier) { return this.rank >= (Viewer.RANK[tier] ?? 99); }

  canMark()      { return false; }   // P/A/L/E attendance, ✓ mark all present
  canInvite()    { return false; }   // 🎟 invites / call-ins
  canRemind()    { return false; }   // 💬 reminders to no-response players
  canContact()   { return false; }   // ✉ CONTACT sheet on other people's cards
  canEdit()      { return false; }   // groups / teams / plans on the event
  canAnswerFor() { return false; }   // ✓/✗ RSVP for someone else

  // ── the app around the screens (account level, migs 1478–1480) ──
  get showsMenuBar()      { return false; }     // top bar (lib/main-menu.js) — the Calendar is their one page
  get showsContextLine()  { return false; }     // "User · Team" (navigation.js)
  get calendarHeader()    { return false; }     // "📅 Calendar / Tap an event…"
  get calendarBack()      { return false; }
  get calendarKindPills() { return false; }     // Games · Practices · Pickup · All
  get calendarViews()     { return ['week']; }
  get calendarKind()      { return 'all'; }     // fixed kind, null = theirs to pick

  // ‹  This week · Nov 16 – Nov 22  ›  (green), Next / Last week, then the
  // range; "Back to this week" off it.  null = the screen's full row.
  // ctx: { start: Date, label, cp(tier, tokens, fb), esc }.  Words: event_center wk_* (mig 1480).
  calendarWeekNavHtml({ start, label, cp, esc }) {
    const monday = (d) => { const m = new Date(d); m.setHours(0, 0, 0, 0); m.setDate(m.getDate() - ((m.getDay() + 6) % 7)); return m; };
    const off = Math.round((monday(start).getTime() - monday(new Date()).getTime()) / (7 * 86400000));
    const range = label;
    const where = off === 0 ? cp('wk_this', { range }, `This week · ${range}`)
      : off === 1 ? cp('wk_next', { range }, `Next week · ${range}`)
      : off === -1 ? cp('wk_last', { range }, `Last week · ${range}`) : range;
    return `<div style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center; justify-content:center; margin-bottom:var(--space-2);">
        <button type="button" class="ec-chip" data-ec-week="-1" aria-label="Previous week" style="font-size:1.1rem; padding:4px 14px;">‹</button>
        <span style="font-weight:800; min-width:12em; text-align:center; ${off === 0 ? 'color:#86efac;' : ''}">${esc(where)}</span>
        <button type="button" class="ec-chip" data-ec-week="1" aria-label="Next week" style="font-size:1.1rem; padding:4px 14px;">›</button>
        ${off === 0 ? '' : `<button type="button" class="ec-chip" data-ec-week="0">${esc(cp('wk_back', {}, 'Back to this week'))}</button>`}
      </div>`;
  }
}

class CoachViewer extends PlayerViewer {
  get tier() { return 'coach'; }
  get rank() { return 1; }
  canMark()    { return true; }
  canInvite()  { return true; }
  canRemind()  { return true; }
  canContact() { return true; }
  canEdit()    { return true; }

  // The full app: menu, header line, the Calendar's header, Back, type pills,
  // Week · Month and the date picker (the screen's own row).
  get showsMenuBar()      { return true; }
  get showsContextLine()  { return true; }
  get calendarHeader()    { return true; }
  get calendarBack()      { return true; }
  get calendarKindPills() { return true; }
  get calendarViews()     { return ['week', 'month']; }
  get calendarKind()      { return null; }
  calendarWeekNavHtml()   { return null; }
}

class AdminViewer extends CoachViewer {
  get tier() { return 'admin'; }
  get rank() { return 2; }
  canAnswerFor() { return true; }
}

const Viewer = {
  RANK: { player: 0, coach: 1, admin: 2 },
  CLASSES: { player: PlayerViewer, coach: CoachViewer, admin: AdminViewer },

  // The viewer for a server tier string; unknown / missing → player.
  for(tier) {
    const C = Viewer.CLASSES[tier] || PlayerViewer;
    return new C();
  },

  // The signed-in account's viewer (MainMenu access; a player until it has
  // loaded).  Marketing gets the coach's app chrome.
  account() {
    const a = (window.MainMenu && MainMenu._access) || {};
    if (a.admin) return new AdminViewer();
    if (a.coach || a.marketing) return new CoachViewer();
    return new PlayerViewer();
  },

  // From an attendance GET body.  Falls back to the older flags while a
  // backend without viewer_tier is still running.
  fromAttendance(body) {
    if (body && body.viewer_tier) return Viewer.for(body.viewer_tier);
    if (body && body.can_set_rsvp) return new AdminViewer();
    if (body && body.can_mark) return new CoachViewer();
    return new PlayerViewer();
  },
};

window.PlayerViewer = PlayerViewer;
window.CoachViewer  = CoachViewer;
window.AdminViewer  = AdminViewer;
window.Viewer       = Viewer;
