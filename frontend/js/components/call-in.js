// CallIn — 🙋 Request call-in (mig 1265), one implementation for every
// screen a player reaches a game from (#my cards, Game Center's "your
// availability" box).  Owner 2026-11-11: Liga 1 players see the APSL game
// with Request call-in instead of Go / No; "tell them what to do for that
// particular games set" — leave the first game when it ends, drive to the
// other, here by X (mig 1266/1268).
//
//   CallIn.loadDrive(auth)            → drive-times body (cached), for the plan line
//   CallIn.planText(ev, events, drive) → the "what to do" line for his two games
//   CallIn.panelHtml(ev, events, drive, { saving, past, compact })
//                                      → button / requested + take it back /
//                                        not this week, then the plan line
//   CallIn.send(auth, fhEventId, action) → POST, resolves the new my_callin
//
// Buttons carry data-callin="request|withdraw" data-fh-event-id — the
// screen's own click handler calls CallIn.send and repaints.
// Words: message_templates kind 'callin'.
(function () {
  const NY = 'America/New_York';
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const copy = (tier, fb, tokens = {}) =>
    (window.MessageCopy && MessageCopy.has && MessageCopy.has('callin', tier))
      ? MessageCopy.block('callin', tier, tokens) : fb;
  const ms = (iso) => new Date(iso).getTime();
  const day = (iso) => new Date(iso).toLocaleDateString('en-CA', { timeZone: NY });
  const clock = (t) => new Date(t).toLocaleTimeString('en-US', { timeZone: NY, hour: 'numeric', minute: '2-digit' });
  const city = (loc) => { const p = String(loc || '').split(',').map(x => x.trim()).filter(Boolean); return p.length >= 3 ? p[p.length - 3] : (p[0] || ''); };
  const venue = (loc) => String(loc || '').split(',')[0].trim();

  let drivePromise = null;
  function loadDrive(auth) {
    if (!drivePromise) {
      drivePromise = auth.fetch('/api/calendar/drive-times')
        .then(r => (r.ok ? r.json() : null)).catch(() => null);
    }
    return drivePromise;
  }

  // Door to door minutes (place_drive_times × traffic + parking buffer —
  // the #my clash check's sum, mig 526).  null = same place, undefined = unknown.
  function travelMinutes(a, b, d) {
    const la = String(a.location || '').trim(), lb = String(b.location || '').trim();
    if (la === lb) return null;
    const pol = (d && d.policy) || null;
    const ia = d && d.places ? d.places[la] : null, ib = d && d.places ? d.places[lb] : null;
    if (!pol || !ia || !ib) return undefined;
    if (ia === ib) return null;
    const raw = d.minutes[`${ia}-${ib}`];
    if (raw === undefined || raw === null) return undefined;
    if (raw <= pol.same_place_minutes) return null;
    return Math.ceil(raw * pol.traffic_factor + pol.buffer_minutes);
  }

  // His own game the same day (the Liga game), before or after this one →
  // exactly what to do.  No such game (or no drive time) → "you can do both".
  function planText(ev, events, d) {
    const c = ev.my_callin || {};
    const from = c.from || 'Liga 1';
    const kick = ms(ev.starts_at);
    const same = (events || [])
      .filter(o => o && o !== ev && o.fh_event_id !== ev.fh_event_id && o.kind === 'match' && !o.my_callin
                && o.my_role && o.my_role !== 'coach' && day(o.starts_at) === day(ev.starts_at))
      .sort((a, b) => Math.abs(ms(a.starts_at) - kick) - Math.abs(ms(b.starts_at) - kick))[0];
    const plain = copy('both_note', `You can do both — just leave after ${from} is over and head to APSL.`, { from });
    if (!same) return plain;
    const otherFirst = ms(same.starts_at) < kick;
    const first = otherFirst ? same : ev, second = otherFirst ? ev : same;
    const drive = first.ends_at ? travelMinutes(first, second, d) : undefined;
    if (drive === undefined) return plain;
    const step = ((d && d.policy && d.policy.round_to_minutes) || 5) * 60000;
    const end = ms(first.ends_at);
    const arrive = Math.ceil((end + (drive || 0) * 60000) / step) * step;
    if (otherFirst) {
      const to = venue(ev.location) || 'the APSL game';
      const t = { from, start: clock(ms(same.starts_at)), end: clock(end), place: city(same.location), to,
                  arrive: clock(arrive), minutes: String(drive || 0), kickoff: clock(kick) };
      return copy('after_game',
        `Play ${from} first (${t.start} in ${t.place}). Leave as soon as it ends (~${t.end}) and drive straight to ${to} (~${t.minutes} min). You'll get there about ${t.arrive} for the ${t.kickoff} kickoff — that's fine.`, t);
    }
    const t = { from, start: clock(kick), end: clock(end), place: venue(ev.location) || 'the APSL game',
                to: city(same.location) || venue(same.location), arrive: clock(arrive), minutes: String(drive || 0),
                kickoff: clock(ms(same.starts_at)) };
    return copy('before_game',
      `APSL is first (${t.start} at ${t.place}). Leave as soon as it ends (~${t.end}) and drive straight to ${from} in ${t.to} (~${t.minutes} min). You'll get there about ${t.arrive} for the ${t.kickoff} ${from} kickoff — that's fine.`, t);
  }

  function planHtml(ev, events, d, size = '0.6rem') {
    return `<div style="font-size:${size}; line-height:1.3; margin-top:3px; font-weight:700; color:#86efac;">${esc(planText(ev, events, d))}</div>`;
  }

  function chipHtml(c) {
    return `<span style="display:inline-block; margin-right:6px; padding:1px 6px; border-radius:999px; vertical-align:middle;
                   background:rgba(56,189,248,0.16); color:#7dd3fc; border:1px solid rgba(56,189,248,0.55);
                   font-size:0.56rem; font-weight:800; letter-spacing:0.03em;">${esc(copy('chip', 'CALL-IN', { from: (c && c.from) || '' }))}</span>`;
  }

  function requestButtonHtml(ev, { saving = false, big = false } = {}) {
    return `<button type="button" data-callin="request" data-fh-event-id="${ev.fh_event_id}" ${saving ? 'disabled' : ''}
        style="padding:${big ? '6px 14px' : '4px 10px'}; border-radius:${big ? 8 : 6}px; cursor:pointer; font-weight:800; font-size:${big ? '0.8rem' : '0.72rem'}; white-space:nowrap;
               background:#0369a1; color:#fff; border:1px solid #38bdf8; opacity:${saving ? 0.6 : 1};">${esc(copy('button', '🙋 Request call-in'))}</button>`;
  }

  // The state line under the button row (requested / not this week / the ask).
  function stateHtml(ev, { saving = false, size = '0.6rem' } = {}) {
    const c = ev.my_callin || {};
    const from = c.from || '';
    const line = (text, color) => `<div style="font-size:${size}; line-height:1.3; margin-top:3px; font-weight:700; color:${color};">${text}</div>`;
    if (c.state === 'requested') {
      return line(`${esc(copy('requested', '🙋 Call-in requested — the coach will let you know.', { from }))}
        <button type="button" data-callin="withdraw" data-fh-event-id="${ev.fh_event_id}" ${saving ? 'disabled' : ''}
          style="margin-left:6px; padding:1px 7px; border-radius:4px; cursor:pointer; font-size:0.9em; font-weight:700;
                 background:transparent; color:#cbd5e1; border:1px solid #475569;">${esc(copy('withdraw', 'Take it back'))}</button>`, '#7dd3fc');
    }
    if (c.state === 'declined') return line(esc(copy('declined', 'Not this week — thanks for putting your hand up.', { from })), '#94a3b8');
    return line(esc(copy('note', 'Want in for this one? Put your hand up and the coach will let you know.', { from })), 'rgba(255,255,255,0.8)');
  }

  // Everything for one game in one block (Game Center's box): the button
  // when he can still ask, the state line, then what to do with his two games.
  function panelHtml(ev, events, d, { saving = false, past = false, size = '0.78rem' } = {}) {
    const c = ev.my_callin || {};
    const btn = !past && c.state === 'open' ? `<div style="margin-top:4px;">${requestButtonHtml(ev, { saving, big: true })}</div>` : '';
    const declined = c.state === 'declined';
    return `${btn}${stateHtml(ev, { saving, size })}${past || declined ? '' : planHtml(ev, events, d, size)}`;
  }

  async function send(auth, fhEventId, action) {
    const headers = { 'Content-Type': 'application/json' };
    if (auth && auth.token) headers.Authorization = `Bearer ${auth.token}`;
    const res = await fetch(`/api/calendar/events/${fhEventId}/callin`, {
      method: 'POST', credentials: 'include', headers, body: JSON.stringify({ action }) });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body.callin || null;
  }

  window.CallIn = { loadDrive, travelMinutes, planText, planHtml, chipHtml, requestButtonHtml, stateHtml, panelHtml, send, copy };
})();
