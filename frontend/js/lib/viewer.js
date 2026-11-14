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
}

class CoachViewer extends PlayerViewer {
  get tier() { return 'coach'; }
  get rank() { return 1; }
  canMark()    { return true; }
  canInvite()  { return true; }
  canRemind()  { return true; }
  canContact() { return true; }
  canEdit()    { return true; }
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
