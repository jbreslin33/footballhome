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
  get calendarKindPills() { return false; }     // Games · Practices · Pickup · All — ☰ items on the Calendar
  get calendarViews()     { return ['week']; }
  get calendarKind()      { return 'all'; }     // fixed kind, null = theirs to pick
  get calendarRosterCounts() { return false; }   // 💤 inactive / ⛔ ineligible on a tile — roster info, coaches' (owner 11/18 "why is naranjo showing how many are inactive")
  // ⚠ Field clash banner over the week — silent when there is none (owner
  // 11/18 "'linux' like silence unless there is conflict then a red banner"
  // → "and coaches and admin can see it").
  get calendarClashes()   { return false; }
  get calendarMine()      { return false; }       // 👤 Mine under the calendar — its links are in ☰

  // ── an opened event (screens/event-screen.js and its kinds) ──
  // Owner 11/18: "when they click the event i want it to look sleek and clean
  // and uncluttered".  A player gets their answer, who's going, the coaches,
  // carpool — nothing to run the event with.
  get eventKindPills()    { return false; }       // Games · Practices · Pickup · All on an event
  // The big pill row, per kind; null = every pill the kind has.  A game: just
  // ⚔️ Starters & Bench (owner 11/18 "i see no need for anything but starters
  // and bench right now for game screen for players").
  eventPillKeys(ev)       { return ev && (ev.kind === 'match' || ev.kind === 'intrasquad') ? ['starters_bench'] : ['players']; }
  get eventLocationLine() { return true; }        // 📍 place on its own line (tap → map), not in the subtitle
  // An opened event (game AND practice — EventScreen, the parent of both):
  // no header (title · times · address · HOME-11v11) — the graphic says who
  // / when / where (owner 11/18 "do we need the info under the calender? …
  // that should just go in grphic underneath … informational for players").
  get eventHeader()       { return false; }
  // Everything under the graphic (🎯 match plan, 🚗 carpool, 🖨 rosters,
  // eligibility, who's coming …) lives in ☰; a pick shows that one under the
  // graphic (owner 11/18 "all the stuff under graphic sould go inside
  // hamburgert for game page" → "keep pace with practice … similar to game.
  // but it should be sibling oop wise of game page inheriting from parent").
  get eventExtrasInMenu() { return true; }
  // GOING / NOT GOING on the graphic itself (owner 11/18 "going or not going
  // button should be on graphic! i am seeing in vision how grahpic is the focus").
  get eventAvailOnGraphic() { return true; }
  // Money on an event (Dues on the lineup boxes …) — AdminViewer only
  // (owner 11/18 "the same except for financial data").
  get eventFinancial()    { return false; }
  get eventCardStanding() { return false; }       // 👻 Last RSVP / dues line on other people's cards — coaches'
  // 📝 Text view (owner 11/18 "if we can do the graphic as most of the work
  // of setting lineup and attendance then we do it … we can always have a
  // more 'text' based option that can be turned on in hamburger … stays on
  // over sessions until turned off"): the graphic is the workspace; Text
  // view brings back the card lists + toolbar under it.  Staff only.
  get eventTextViewToggle() { return false; }
  get eventTextView()     { return false; }
  get eventLineupDrafts() { return false; }       // Official · 📝 My draft · 🔀 Compare (owner 11/18 "get rid of lineup picker … not really used and clutters screen")
  // 📅 in the band takes them home from anywhere — the Calendar is their one
  // page — so event pages lose ← Back (owner 11/18 "they need a back button
  // but instead maybe a calendar button at top because that is the only item
  // on their universal menu").
  //
  // Since 11/18 (later) that is the menu bar's own 📅 Calendar pill, as an
  // admin sees it in a game (owner "we need calender 'menu' item like we
  // have on admin when your in game but that is all the players need right
  // now … game or practice. event basically"): menuBarPages = the menu_pages
  // codes on a player's bar, shown away from the Calendar only.  The band's
  // small 📅 icon is off — one Calendar button, not two.
  get showsCalendarButton() { return false; }
  get menuBarPages()      { return ['calendar']; }
  get homeScreens()       { return ['calendar', 'event-center', 'my', 'player-calendar']; }
  get eventBack()         { return false; }
  // Which people sections: ✓ going, 🎟 invited and 🧑‍🏫 coaches.  Not the
  // no-response / not-going / injured / inactive / suspended / ineligible folds.
  eventSection(key)       { return ['going', 'invited', 'coaches'].includes(key); }

  // ☰ the band's menu (owner 11/18 "a hamburger thingy then the other stuff
  // would be there … for players we want less options and clean interface.
  // for admin it will extend base class with more stuff").  The base list;
  // each child returns [...super.menuItems(), …more].  Sign out always last.
  // { code, tier (event_center copy), fb, route | null, panel | null }
  menuItems() {
    return [
      { code: 'rules',   tier: 'qlink_rules',   fb: '📋 Rules & fines', route: 'player-team-rules' },
      { code: 'alerts',  tier: 'qlink_alerts',  fb: '🔔 Alerts',        panel: 'alerts' },
      { code: 'signout', tier: 'qlink_signout', fb: '↪ Sign out' },
    ];
  }

  // ‹  This week · Nov 16 – Nov 22  ›  (green), Next / Last week, then the
  // range; "Back to this week" off it.  Month view (staff) the same:
  // ‹ This month · November 2026 ›.  Every tier gets this bar (owner 11/18
  // staff calendar piece by piece); Week · Month and the date picker are ☰
  // items for the viewers that have them (calendarViews / calendarDatePicker).
  // ctx: { start: Date, anchor: Date, view, label, cp(tier, tokens, fb), esc }.
  // Words: event_center wk_* (mig 1480), mo_* (mig 1512).
  calendarWeekNavHtml({ start, anchor, view, label, cp, esc }) {
    let off;
    if (view === 'month') {
      const now = new Date(), a = anchor || start;
      off = (a.getFullYear() - now.getFullYear()) * 12 + (a.getMonth() - now.getMonth());
    } else {
      const monday = (d) => { const m = new Date(d); m.setHours(0, 0, 0, 0); m.setDate(m.getDate() - ((m.getDay() + 6) % 7)); return m; };
      off = Math.round((monday(start).getTime() - monday(new Date()).getTime()) / (7 * 86400000));
    }
    const range = label;
    const p = view === 'month' ? 'mo' : 'wk';
    const unit = view === 'month' ? 'month' : 'week';
    const where = off === 0 ? cp(`${p}_this`, { range }, `This ${unit} · ${range}`)
      : off === 1 ? cp(`${p}_next`, { range }, `Next ${unit} · ${range}`)
      : off === -1 ? cp(`${p}_last`, { range }, `Last ${unit} · ${range}`) : range;
    return `<div style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center; justify-content:center; margin-bottom:var(--space-2);">
        <button type="button" class="ec-chip" data-ec-week="-1" aria-label="Previous ${unit}" style="font-size:1.1rem; padding:4px 14px;">‹</button>
        <span style="font-weight:800; min-width:12em; text-align:center; ${off === 0 ? 'color:#86efac;' : ''}">${esc(where)}</span>
        <button type="button" class="ec-chip" data-ec-week="1" aria-label="Next ${unit}" style="font-size:1.1rem; padding:4px 14px;">›</button>
        ${off === 0 ? '' : `<button type="button" class="ec-chip" data-ec-week="0">${esc(cp(`${p}_back`, {}, `Back to this ${unit}`))}</button>`}
      </div>`;
  }
  get calendarDatePicker() { return false; }    // 📆 Go to a date… in ☰
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
  // calendarHeader / calendarBack: inherited (off) — the lit 📅 Calendar pill
  // says where you are, and it is the home page, so no ← Back (owner 11/18
  // "first thing is back button. it don't need it right? also we don't need
  // 📅 Calendar Tap an event … because you have Calendar pill highlighted").
  get calendarKindPills() { return true; }
  get calendarViews()     { return ['week', 'month']; }   // ☰ items (mig 1512)
  get calendarDatePicker() { return true; }
  get calendarKind()      { return null; }
  get calendarRosterCounts() { return true; }
  get calendarClashes()   { return true; }
  // calendarMine: inherited (off) — 📋 Rules & fines, 🔔 Alerts and Sign out
  // are already in their ☰ (owner 11/18 staff calendar piece by piece).
  eventPillKeys()         { return null; }
  // eventKindPills / eventLocationLine / eventBack: inherited (off) — they
  // lived in the event header, which staff no longer get either; the menu
  // bar's lit 📅 Calendar pill is the way home.
  // eventHeader / eventExtrasInMenu / eventAvailOnGraphic: inherited — staff
  // get the player's clean, graphic-first event page (owner 11/18 "admin and
  // coaches … should be the same except for financial data"); their tools
  // are extra panels, so they land in ☰ with the rest.
  get eventCardStanding() { return true; }
  get eventTextViewToggle() { return true; }
  // Remembered on this device until turned off (Viewer.setTextView).
  get eventTextView()     { try { return localStorage.getItem(Viewer.TEXT_VIEW_KEY) === '1'; } catch { return false; } }
  // Off for everyone (owner 11/18 "so official, my draft, compare delete them"):
  // coaches edit the official lineup directly.  Flip here to bring drafts back.
  get eventLineupDrafts() { return false; }
  get showsCalendarButton() { return false; }   // staff have the menu bar
  get menuBarPages()      { return null; }       // the full bar
  eventSection()          { return true; }

  // ☰ = the player's list + 👤 Account (view-as, tactical board …), Sign out last.
  menuItems() {
    const base = super.menuItems();
    const out = base.filter(i => i.code !== 'signout');
    out.push({ code: 'account', tier: 'qlink_account', fb: '👤 Account', route: 'main-menu' });
    return out.concat(base.filter(i => i.code === 'signout'));
  }
}

class AdminViewer extends CoachViewer {
  get tier() { return 'admin'; }
  get rank() { return 2; }
  canAnswerFor() { return true; }
  get eventFinancial()    { return true; }   // the one thing an admin adds on an event page
}

const Viewer = {
  RANK: { player: 0, coach: 1, admin: 2 },
  TEXT_VIEW_KEY: 'fh.event.textView',
  setTextView(on) { try { if (on) localStorage.setItem(Viewer.TEXT_VIEW_KEY, '1'); else localStorage.removeItem(Viewer.TEXT_VIEW_KEY); } catch {} },
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
