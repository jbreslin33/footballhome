// The big pill row atop an opened event — one full-width row of equal
// buttons, each the event's next "moment" in its accent colour.
//
// Game Center's row (⚽ Game Announcement · 📋 20-Man Squad · ⚔️ Starters &
// Bench · 🏆 Match Result) and a practice's (👥 All Players · 🎽 Groups ·
// 📝 Practice Plan) are the same component: owner 2026-10-27, "same
// behaviour for practice and game except where we have to differ".  The
// first shared piece of the event base the two screens are moving toward.
//
//   pills   [{ key, icon, title, accent }]
//   active  the lit key
//   opts    { attr: 'data-…' the click attribute, escapeHtml,
//             mark: (pill) => '' — a second line under the title }
const EventPills = {
  button(p, on, opts = {}) {
    const esc = opts.escapeHtml || ((s) => String(s));
    const mark = opts.mark ? opts.mark(p) : '';
    return `
        <button type="button" ${opts.attr || 'data-event-pill'}="${esc(p.key)}" role="tab" aria-selected="${on}"
                style="flex:1 1 0; min-width:104px; font-size:0.72rem; font-weight:700; line-height:1.25; padding:6px 8px; white-space:nowrap;
                       border-radius:8px; cursor:pointer; color:#fff; border:2px solid ${on ? p.accent : '#475569'};
                       background:${on ? p.accent : '#0f172a'};">
          ${p.icon} ${esc(p.title)}
          ${mark ? `<br><span data-event-pill-mark style="font-size:0.64rem; font-weight:600; opacity:0.95;">${esc(mark)}</span>` : ''}
        </button>`;
  },

  // Just the buttons — for a container the screen owns and repaints.
  buttons(pills, active, opts = {}) {
    return pills.map(p => EventPills.button(p, p.key === active, opts)).join('');
  },

  // The row with its container.
  row(pills, active, opts = {}) {
    return `<div role="tablist" aria-label="${(opts.escapeHtml || String)(opts.label || 'Event')}"
                 style="display:flex; gap:6px; margin-bottom:10px; overflow-x:auto;">${EventPills.buttons(pills, active, opts)}</div>`;
  },
};

window.EventPills = EventPills;
