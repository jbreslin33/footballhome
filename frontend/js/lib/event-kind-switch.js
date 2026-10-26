// Event Center's type pills — 🏟️ Games · 🏃 Practices · ⚽ Pickup · 📅 All.
//
// Owner 2026-10-26: "instead of game center it could be event center … all
// in one with pills".  Event Center is one page to the coach: a game opens
// Game Center (screens/game-center.js, match-keyed), every other kind opens
// the event screen (screens/event-center.js, fh_event-keyed).  Both draw
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

  // A tap on the strip.  Games = Game Center's own entry (it lands on the
  // next game); anything else = the event list filtered to that kind.
  go(navigation, kind) {
    if (kind === 'match') navigation.goTo('game-center', { pick: true });
    else navigation.goTo('event-center', { pick: true, kind });
  },
};

window.EventKindSwitch = EventKindSwitch;
