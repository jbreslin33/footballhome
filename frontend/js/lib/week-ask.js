// WeekAsk — "Set the rest of your week" (owner 2026-11-17: "after they set
// that we should have a popup that shows the rest of events that week
// (set and not set so they don't forget about the ones they set) then
// they can set them all right there or close box … so we send them to an
// event if they set it then we hit them with why not set all for week").
//
// A reminder (group or personal) lands on ONE event.  Once the viewer
// answers it there (EventScreen._setMyAvailability — every kind, every
// section), this opens over the page with every other event that week
// (Mon–Sun) the viewer or one of their kids can answer: the ones still
// unanswered first, then the ones already answered (so they see them and
// can change them).  Going / Not Going per person per event; tapping the
// lit answer clears it, as everywhere.  Nothing else open → no popup.
//
// Feed: GET /api/calendar/upcoming?start=<Monday>&days=7 — already scoped
// per viewer; the same rules the 📅 Calendar tiles follow: my_rsvp_eligible
// for your own row, guardian_targets for each kid (⛔ suspended skipped,
// mig 1077), 🙋 call-in games skipped (no Go / No), answers not open yet
// (rsvps_open_now false) and finished events skipped.
// Writes: POST|DELETE /api/calendar/rsvp ({person_id} for a kid).
// Words: message_templates kind event_center week_ask_* (mig 1433) and
// the tiles' me_status_* / kid_status_*.
// Once per event per page visit (sessionStorage), never while viewing as
// someone else.
(function () {
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens || {})) || fb;
  const ymd = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  const SEEN = 'fh-week-ask-seen';

  function monday(at) {
    const d = new Date(at);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
    return d;
  }

  function seen(id) {
    try { return (JSON.parse(sessionStorage.getItem(SEEN) || '[]')).includes(id); } catch (_) { return false; }
  }
  function markSeen(id) {
    try {
      const list = JSON.parse(sessionStorage.getItem(SEEN) || '[]');
      if (!list.includes(id)) list.push(id);
      sessionStorage.setItem(SEEN, JSON.stringify(list.slice(-50)));
    } catch (_) { /* private window — it may show again, fine */ }
  }

  async function call(auth, url, options = {}) {
    const headers = { ...(options.headers || {}) };
    if (options.method && options.method !== 'GET') headers['Content-Type'] = 'application/json';
    const res = await auth.fetch(url, { ...options, headers });
    let body = null;
    try { body = await res.json(); } catch (_) {}
    if (!res.ok) throw new Error((body && (body.message || body.error)) || `HTTP ${res.status}`);
    return body || {};
  }

  const isPast = (ev) => (window.EventLabels && EventLabels.isPast) ? EventLabels.isPast(ev)
    : new Date(ev.ends_at || ev.starts_at).getTime() < Date.now();

  // Every answerable row on one event: [{ personId (0 = you), name, response }].
  function rowsOf(ev) {
    if (isPast(ev) || ev.rsvps_open_now === false || ev.my_callin || ev.status === 'cancelled') return [];
    const rows = [];
    if (ev.my_rsvp_eligible === true && !ev.my_suspension) rows.push({ personId: 0, name: '', response: ev.my_rsvp || null });
    const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    for (const c of (Array.isArray(ev.guardian_targets) ? ev.guardian_targets : [])) {
      if (!c || !c.person_id || c.suspension) continue;
      const id = Number(c.person_id);
      const row = rsvps.find(r => r && Number(r.person_id) === id);
      rows.push({ personId: id, name: String(c.name || '').split(' ')[0] || 'Your player', response: (row && row.response) || null });
    }
    return rows;
  }

  // Open it for the week of `ev` (the event just answered).
  async function maybeShow(auth, ev) {
    if (!auth || !ev || !ev.starts_at || !ev.fh_event_id) return;
    if (auth.viewAsPersonId) return;
    if (seen(ev.fh_event_id) || document.getElementById('fh-week-ask')) return;
    markSeen(ev.fh_event_id);
    let events;
    try {
      const body = await call(auth, `/api/calendar/upcoming?start=${encodeURIComponent(ymd(monday(ev.starts_at)))}&days=7`);
      events = (Array.isArray(body.events) ? body.events : [])
        .filter(x => x.fh_event_id !== ev.fh_event_id)
        .map(x => ({ ev: x, rows: rowsOf(x) }))
        .filter(x => x.rows.length)
        .sort((a, b) => new Date(a.ev.starts_at) - new Date(b.ev.starts_at));
    } catch (err) {
      console.warn('[week-ask] week load failed:', err);
      return;
    }
    if (!events.length) return;
    open(auth, events);
  }

  function open(auth, events) {
    const shade = document.createElement('div');
    shade.id = 'fh-week-ask';
    shade.style.cssText = 'position:fixed; inset:0; z-index:10000; background:rgba(0,0,0,0.55);'
      + 'display:flex; align-items:center; justify-content:center; padding:16px;';
    const saving = new Set();
    const note = {};
    const btnCss = 'border:0; border-radius:10px; padding:10px 16px; font-weight:800; font-size:0.95rem; cursor:pointer;';

    const open_ = () => events.filter(x => x.rows.some(r => !r.response));
    const answered = () => events.filter(x => x.rows.every(r => r.response));
    const when = (ev) => {
      const d = new Date(ev.starts_at);
      return isNaN(d) ? '' : d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })
        + ', ' + d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    };
    const title = (ev) => (window.EventLabels && EventLabels.title) ? EventLabels.title(ev) : (ev.title || 'Event');

    const rowHtml = (x, r) => {
      const key = `${x.ev.fh_event_id}:${r.personId}`;
      const busy = saving.has(key);
      const [tier, fb, colour] = r.personId
        ? (r.response === 'yes' ? ['kid_status_yes', `✓ ${r.name} is going`, '#22c55e']
          : r.response === 'no' ? ['kid_status_no', `✗ ${r.name} is not going`, '#ef4444']
          : ['kid_status_none', `${r.name} hasn't answered yet`, '#fbbf24'])
        : (r.response === 'yes' ? ['me_status_yes', "✓ You're going", '#22c55e']
          : r.response === 'no' ? ['me_status_no', "✗ You're not going", '#ef4444']
          : ['me_status_none', "You haven't answered yet", '#fbbf24']);
      const b = (resp, label, c) => {
        const on = r.response === resp;
        return `<button type="button" data-wa="${resp}" data-wa-event="${x.ev.fh_event_id}" data-wa-person="${r.personId}" ${busy ? 'disabled' : ''}
                  style="padding:6px 12px; border-radius:8px; font-weight:800; font-size:0.78rem; cursor:pointer; opacity:${busy ? 0.5 : 1};
                         border:2px solid ${c}; color:#fff; background:${on ? c : 'transparent'};">${esc(label)}</button>`;
      };
      return `
        <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; margin-top:4px;">
          <span style="font-size:0.8rem; font-weight:700; color:${colour};">${esc(cp(tier, { name: r.name }, fb))}</span>
          <span style="display:flex; gap:6px;">${b('yes', cp('week_ask_going', {}, 'Going'), '#16a34a')}${b('no', cp('week_ask_not_going', {}, 'Not Going'), '#dc2626')}</span>
        </div>
        ${note[key] ? `<div style="font-size:0.72rem; color:#f87171;">${esc(note[key])}</div>` : ''}`;
    };
    const card = (x) => `
      <div style="padding:8px 10px; border-radius:10px; border:1px solid #334155; margin-top:8px;">
        <div style="font-size:0.75rem; font-weight:800; color:#93c5fd;">${esc(when(x.ev))}</div>
        <div style="font-weight:700; font-size:0.92rem;">${esc(title(x.ev))}</div>
        ${x.rows.map(r => rowHtml(x, r)).join('')}
      </div>`;
    const head = (text) => `<div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.7; margin-top:12px; text-transform:uppercase;">${esc(text)}</div>`;

    const paint = () => {
      const todo = open_();
      const done = answered();
      shade.innerHTML = `
        <div role="dialog" aria-modal="true" style="max-width:460px; width:100%; max-height:85vh; overflow-y:auto; padding:16px 18px; border-radius:14px;
             background:#0f172a; color:#f8fafc; border:2px solid ${todo.length ? '#fbbf24' : '#22c55e'}; box-shadow:0 10px 30px rgba(0,0,0,0.5); font-family:inherit;">
          <div style="display:flex; justify-content:space-between; gap:8px; align-items:flex-start;">
            <div style="font-weight:800; font-size:1.08rem;">${esc(todo.length
              ? cp('week_ask_title', { n: String(todo.length) }, `📅 Thanks! ${todo.length} more this week`)
              : cp('week_ask_all_set', {}, '✅ All set for the week'))}</div>
            <button type="button" data-wa-close aria-label="Close" style="border:0; background:transparent; color:#f8fafc; font-size:1.2rem; cursor:pointer; line-height:1;">✕</button>
          </div>
          <div style="font-size:0.88rem; opacity:0.85; line-height:1.4; margin-top:4px;">${esc(todo.length
            ? cp('week_ask_body', {}, 'Set the rest of your week while you are here — the coaches plan off every answer.')
            : cp('week_ask_all_set_body', {}, 'Every event this week has an answer. Change any of them here or on the calendar.'))}</div>
          ${todo.length ? head(cp('week_ask_open', {}, 'Still to answer')) + todo.map(card).join('') : ''}
          ${done.length ? head(cp('week_ask_done', {}, 'Already answered')) + done.map(card).join('') : ''}
          <div style="margin-top:14px; display:flex; justify-content:flex-end;">
            <button type="button" data-wa-close style="${btnCss} background:#334155; color:#fff;">${esc(cp('week_ask_close', {}, 'Done'))}</button>
          </div>
        </div>`;
    };

    const set = async (eventId, personId, response) => {
      const x = events.find(e => e.ev.fh_event_id === eventId);
      const r = x && x.rows.find(y => y.personId === personId);
      if (!r) return;
      const key = `${eventId}:${personId}`;
      if (saving.has(key)) return;
      saving.add(key);
      delete note[key];
      paint();
      const clear = r.response === response;
      const payload = { fh_event_id: eventId };
      if (personId) payload.person_id = personId;
      try {
        if (clear) {
          await call(auth, '/api/calendar/rsvp', { method: 'DELETE', body: JSON.stringify(payload) });
          r.response = null;
        } else {
          const body = await call(auth, '/api/calendar/rsvp', { method: 'POST', body: JSON.stringify({ ...payload, response }) });
          r.response = (body && body.rsvp && body.rsvp.response) || response;
          if (!personId && body && body.reg_ask && window.RegAsk) RegAsk.show(body.reg_ask);   // 📝 mig 725 (sits on top)
        }
      } catch (err) {
        note[key] = err.message;
      } finally {
        saving.delete(key);
      }
      paint();
    };

    shade.addEventListener('click', (e) => {
      if (e.target === shade || e.target.closest('[data-wa-close]')) { shade.remove(); return; }
      const b = e.target.closest('[data-wa]');
      if (b && !b.disabled) set(Number(b.dataset.waEvent), Number(b.dataset.waPerson) || 0, b.dataset.wa);
    });
    paint();
    document.body.appendChild(shade);
  }

  window.WeekAsk = { maybeShow };
})();
