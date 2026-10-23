// SmsOptInAsk — the "Get game reminders by text?" card shown after an
// RSVP (mig 647; owner 2026-10-23: "if they are not opted in when they
// click going or not going it prompts them to opt in" … "once for each
// event").  The server decides when to ask (fh_sms_opt_in_should_ask) and
// hands back sms_opt_in = {fh_event_id, url, copy} on the RSVP reply; this
// only draws it.  Consent is never taken here: "Yes" opens the
// footballhome.org/sms sign-up page pre-filled — the opt-in path the A2P
// campaign registers — where they tick the box themselves.
//
// Shared by #my, Game Center and the /rc roll call card, so it stands
// alone: plain DOM, the session token from localStorage.
(function () {
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  function answer(fhEventId, value) {
    let token = '';
    try { token = localStorage.getItem('token') || ''; } catch (_e) {}
    return fetch('/api/calendar/sms-opt-in-ask', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) },
      body: JSON.stringify({ fh_event_id: fhEventId, answer: value }),
    }).catch(() => {});
  }

  function show(ask) {
    if (!ask || !ask.url || !ask.copy || document.getElementById('fh-sms-ask')) return;
    const w = ask.copy;
    const card = document.createElement('div');
    card.id = 'fh-sms-ask';
    card.setAttribute('role', 'dialog');
    card.style.cssText = 'position:fixed; left:12px; right:12px; bottom:12px; z-index:10000; max-width:460px; margin:0 auto;'
      + 'padding:14px 16px; border-radius:14px; background:#0f172a; color:#f8fafc; border:1px solid #0284c7;'
      + 'box-shadow:0 10px 30px rgba(0,0,0,0.45); font-family:inherit;';
    const btn = 'border:0; border-radius:10px; padding:10px 14px; font-weight:800; font-size:0.95rem; cursor:pointer;';
    card.innerHTML = `
      <div style="font-weight:800; font-size:1.02rem; margin-bottom:4px;">📲 ${esc(w.title)}</div>
      <div style="font-size:0.88rem; opacity:0.9; line-height:1.35; margin-bottom:10px;">${esc(w.body)}</div>
      <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
        <a data-ask="opened" href="${esc(ask.url)}" target="_blank" rel="noopener"
           style="${btn} background:#0284c7; color:#fff; text-decoration:none;">${esc(w.yes)}</a>
        <button type="button" data-ask="later" style="${btn} background:#334155; color:#fff;">${esc(w.later)}</button>
        <button type="button" data-ask="never" style="border:0; background:none; color:#94a3b8; font-size:0.8rem;
                text-decoration:underline; cursor:pointer; padding:6px 4px;">${esc(w.never)}</button>
      </div>`;
    card.addEventListener('click', (e) => {
      const el = e.target.closest('[data-ask]');
      if (!el) return;
      answer(ask.fh_event_id, el.dataset.ask);
      card.remove();   // the link still opens: the anchor's default runs
    });
    document.body.appendChild(card);
  }

  window.SmsOptInAsk = { show };
})();
