// Event Center's type pills — 🏟️ Games · 🏃 Practices · ⚽ Pickup · 📅 All.
//
// Owner 2026-10-26: "instead of game center it could be event center … all
// in one with pills".  Event Center is one page to the coach: a game opens
// Game Center (screens/game-center.js, match-keyed), every other kind opens
// the event screen (screens/event-center.js, fh_event-keyed), and every
// pill fills Event Center's week calendar with its kind.  Both draw
// this strip at the top, so flipping type is one tap whichever is showing.
// Labels are DB copy: message_templates kind='event_center' (mig 738).
const EventKindSwitch = {
  KINDS: ['match', 'practice', 'pickup', 'all'],
  FALLBACK: { match: '🏟️ Games', practice: '🏃 Practices', pickup: '⚽ Pickup', all: '📅 All' },

  label(kind) {
    return (window.MessageCopy && MessageCopy.block('event_center', 'pill_' + kind)) || EventKindSwitch.FALLBACK[kind];
  },

  title() {
    return (window.MessageCopy && MessageCopy.block('event_center', 'title')) || '📋 Event Center';
  },

  // active: 'match' on Game Center, the list's kind on the event screen.
  html(active, escapeHtml) {
    const esc = escapeHtml || ((s) => String(s));
    return `<div role="tablist" aria-label="Event type"
                 style="flex:1 0 100%; min-width:0; display:flex; gap:6px; overflow-x:auto; margin-top:6px;">
      ${EventKindSwitch.KINDS.map(k => `<button type="button" role="tab" aria-selected="${k === active}" data-event-kind="${k}"
          class="btn ${k === active ? 'btn-primary' : 'btn-secondary'}"
          style="flex:0 0 auto; font-size:0.8rem; padding:6px 12px; white-space:nowrap;">${esc(EventKindSwitch.label(k))}</button>`).join('')}
    </div>`;
  },

  // A tap on the strip: Event Center's week calendar filled with that kind
  // (owner 2026-10-27: "cal with pills to populate cal") — games too; a
  // game tapped there opens Game Center.
  go(navigation, kind) {
    navigation.goTo('event-center', { pick: true, kind });
  },

  // Open one event on its own screen — the EventScreen family
  // (screens/event-screen.js): a game in Game Center, a practice or a
  // pickup in #practice, anything else in #event.  pill = the big pill to
  // light (the URL's last part); the screen falls back to its default.
  open(navigation, ev, pill) {
    if (!ev) return;
    const params = pill ? { event: ev, pill } : { event: ev };
    if (ev.kind === 'match' && ev.match_id != null) {
      navigation.goTo('game-center', params);
    } else if (ev.kind === 'practice' || ev.kind === 'pickup') {
      navigation.goTo('practice', params);
    } else {
      navigation.goTo('event', params);
    }
  },

  // ONE URL for an opened event, whatever its kind (owner 2026-11-03:
  // "games seem to have id in url but practice does not … the urls are
  // random in design"): #event/<fh_event_id>/<pill>.  The kind decides
  // which screen draws it, never the URL.
  SCREENS: ['event', 'practice', 'game-center'],
  hash(ev, pill) {
    if (!ev || ev.fh_event_id == null) return null;
    return `#event/${ev.fh_event_id}${pill ? '/' + pill : ''}`;
  },
  parseHash(hash) {
    const m = String(hash || '').match(/^#event\/(\d+)(?:\/([a-z_]+))?$/);
    return m ? { fhEventId: Number(m[1]), pill: m[2] || null } : null;
  },

  // The URL kept honest after a pill tap or a late event load —
  // replaceState, so Back still means "leave this event", not "undo my
  // last pill".  Only while one of the event screens is showing.
  syncHash(navigation, ev, pill) {
    const h = EventKindSwitch.hash(ev, pill);
    if (!h || !navigation || !EventKindSwitch.SCREENS.includes(navigation.currentState)) return;
    if (window.location.hash === h) return;
    try { window.history.replaceState(window.history.state, '', h); }
    catch (err) { console.warn('[event] hash sync failed (non-fatal):', err); }
  },

  // A cold start on #event/<id>/<pill> (a reload, a pasted link): fetch
  // the event, then open it by kind like a calendar tap.
  async openById(navigation, auth, fhEventId, pill) {
    if (window.BootLog) BootLog.begin('event');   // the boot log shows from the first fetch
    const res = await auth.fetch(`/api/calendar/events/${fhEventId}`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const body = await res.json();
    if (!body || !body.event) throw new Error('no event');
    EventKindSwitch.open(navigation, body.event, pill);
  },
};

window.EventKindSwitch = EventKindSwitch;
