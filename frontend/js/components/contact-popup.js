// ContactPopup — the one stop for contacting someone (owner 2026-11-02:
// "should be one contact button", "default to the context of screen it
// was clicked from but allow for diff messages and send types").
//
// A screen registers a config and draws ContactPopup.button(config).  The
// popup offers who (each parent separately), which message (the screen's
// context preselected), the words (editable) and how it goes: email, FH
// Texter, regular text, club text, call, save contact.
//
// config = {
//   key:        stable string, redraws overwrite,
//   screen:     the Screen, for its compose-link builders (optional),
//   recipients: [{ personId, name, phone, email, forPersonId, noText, noCall }],
//   messages:   [{ key, label, subject, body, smsBody, resolve, onSent, noClub, beforeEmail, copyOk }],
//   defaultKey, flagged (draw the button fuchsia), big (full-size button),
//   label (button words, when a row has several people), title,
//   vcard:      { href, filename }, or onSave(recipient) when the screen builds it,
//   onCall(recipient): runs as the dialer opens, for the screen's tracking
// }
// resolve(recipient, 'email'|'sms') → { href, ... } is for words the
// server builds at send time (sign-in link, welcome).  onSent(resolved,
// via, words) runs after a send, for the screen's own tracking.  noClub
// keeps a message off the club number (dues notices).  purpose names a
// FH Texter / club send for the screen's delivery marks (game_link:<id>);
// sendClub(recipient) replaces the generic club text with the screen's
// own tracked one (a game link from the club number).  📋 Copy puts the
// words on the clipboard — any typed message, and a resolve message only
// when it says copyOk (its resolve then takes channel 'copy' and answers
// sms_body; a 🎟 call-up for someone with no phone or email).  beforeEmail(words)
// runs in the click's own tick, just before Gmail opens, for work the
// browser only allows there (the clipboard).  A recipient with no
// personId (a lead) still gets email and texts; the club number stays off
// until they are a person who opted in.
//
// Words: message_templates kind contact_popup (read through MessageCopy).
(function () {
  const registry = new Map();
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const t = (tier, tokens, fallback) =>
    (window.MessageCopy && MessageCopy.block && MessageCopy.block('contact_popup', tier, tokens || {})) || fallback;

  function authFetch(url, opts = {}) {
    let token = '';
    try { token = localStorage.getItem('token') || ''; } catch (_e) {}
    return fetch(url, { ...opts, headers: { 'Content-Type': 'application/json', ...(opts.headers || {}),
                                             ...(token ? { Authorization: 'Bearer ' + token } : {}) } });
  }

  function button(cfg) {
    registry.set(cfg.key, cfg);
    const size = cfg.big ? 'flex:1; font-size:0.82rem; padding:7px 10px; border-radius:6px;'
                         : 'font-size:0.68rem; padding:2px 6px; border-radius:3px;';
    return `<button type="button" data-contact-popup="${esc(cfg.key)}" title="${esc(cfg.title || '')}"
      style="${size} font-weight:800; line-height:1.2; border:none; cursor:pointer; color:#fff;
             white-space:nowrap; background:${cfg.flagged ? '#c026d3' : '#334155'};">📇 ${esc(cfg.label || t('button', {}, 'CONTACT'))}</button>`;
  }

  // The FH Texter + club number state for one recipient.  A 403/404 means
  // this viewer does not get that route, never that the popup fails.
  const consentKey = (r) => r.personId || `phone:${r.phone || ''}`;
  async function loadRoutes(st, r) {
    const key = consentKey(r);
    if (st.relayLoaded === undefined) {
      st.relayLoaded = true;
      try {
        const res = await authFetch('/api/phone-relay/status');
        st.relay = res.ok ? await res.json() : null;
      } catch (_e) { st.relay = null; }
    }
    if (r.phone && !(key in st.consent)) {
      try {
        const res = await authFetch(`/api/phone-relay/contact-state?person_id=${encodeURIComponent(r.personId || 0)}&to=${encodeURIComponent(r.phone)}`);
        st.consent[key] = res.ok ? (await res.json()).consent : null;
      } catch (_e) { st.consent[key] = null; }
    }
  }

  function routes(st, r, m) {
    const dev = st.relay && (st.relay.devices || [])[0];
    const consent = st.consent[consentKey(r)];
    const stopped = consent === 'stopped';
    const noPhone = !r.phone ? t('why_no_phone', {}, 'No mobile number on file')
                  : r.noText ? t('why_no_text', {}, 'This number does not take texts') : '';
    const list = [{ key: 'email', label: t('via_email', {}, '✉ Email'),
                    why: r.email ? '' : t('why_no_email', {}, 'No email on file') }];
    if (st.relay) {
      list.push({ key: 'relay', label: t('via_relay', {}, '📱 FH Texter'),
        why: noPhone || (stopped ? t('why_stopped', {}, 'They replied STOP')
           : !dev ? t('why_unpaired', {}, 'FH Texter is not set up')
           : !dev.online ? t('why_offline', {}, 'Your phone is offline')
           : st.relay.today >= st.relay.cap ? t('why_cap', {}, "Today's limit is used") : '') });
    }
    list.push({ key: 'text', label: t('via_text', {}, '💬 Regular text'), why: noPhone });
    if (consent && !(m && m.noClub)) {
      list.push({ key: 'club', label: t('via_club', {}, '🏢 Club text'),
        why: noPhone || (stopped ? t('why_stopped', {}, 'They replied STOP')
           : consent !== 'in' ? t('why_not_opted_in', {}, 'Not opted in to club texts') : '') });
    }
    if (m && (!m.resolve || m.copyOk)) list.push({ key: 'copy', label: t('via_copy', {}, '📋 Copy'), why: '' });
    return list;
  }

  // Default: the club number for someone opted in, then FH Texter, then
  // the texting app, then email (owner 2026-10-24); copy only when nothing
  // else works.
  function defaultVia(list) {
    return ['club', 'relay', 'text', 'email', 'copy'].find(k => (list.find(v => v.key === k) || { why: 'x' }).why === '') || null;
  }

  function open(cfg) {
    const st = { cfg, who: 0, msg: cfg.defaultKey || (cfg.messages[0] && cfg.messages[0].key), via: null,
                 edits: {}, consent: {}, note: '', noteBad: false, busy: false,
                 status: [],                                   // live lines after Send (mig 1085)
                 log: { open: false, rows: null, key: '' } };  // ▸ Recent messages
    document.getElementById('fh-contact-popup')?.remove();
    const el = document.createElement('div');
    el.id = 'fh-contact-popup';
    el.setAttribute('role', 'dialog');
    el.style.cssText = 'position:fixed; inset:0; z-index:10001; background:rgba(0,0,0,0.55); display:flex; align-items:center; justify-content:center;';
    el.addEventListener('click', (e) => onClick(e, st, el));
    el.addEventListener('change', (e) => onChange(e, st, el));
    el.addEventListener('input', (e) => {
      if (e.target.matches('[data-cp-body]')) st.edits[editKey(st)] = e.target.value;
    });
    document.body.appendChild(el);
    refresh(st, el);
  }

  const recipient = (st) => st.cfg.recipients[st.who];
  const message = (st) => st.cfg.messages.find(m => m.key === st.msg) || st.cfg.messages[0];
  const isEmail = (st) => st.via === 'email';
  const editKey = (st) => `${st.msg}:${isEmail(st) ? 'email' : 'sms'}`;
  const wordsFor = (st) => {
    const m = message(st);
    if (!m) return '';
    const k = editKey(st);
    if (k in st.edits) return st.edits[k];
    return isEmail(st) ? (m.body || '') : (m.smsBody || m.body || '');
  };

  async function refresh(st, el) {
    if (window.MessageCopy && MessageCopy.load && !MessageCopy.has('contact_popup', 'title')) {
      try { await MessageCopy.load({ fetch: authFetch }); } catch (_e) { /* fallback words */ }
    }
    await loadRoutes(st, recipient(st));
    draw(st, el);
    loadLog(st, el);
  }

  // ── ▸ Recent messages (mig 1085, owner 2026-11-05: "a log of last
  // messages sent to that contact … method and message") ──────────────
  async function loadLog(st, el) {
    const r = recipient(st);
    const key = `${r.personId || ''}|${r.phone || ''}|${r.email || ''}`;
    st.log.key = key;
    try {
      const q = new URLSearchParams({ person_id: r.personId || '', phone: r.phone || '', email: r.email || '' });
      const res = await authFetch(`/api/phone-relay/history?${q}`);
      if (st.log.key !== key) return;
      st.log.rows = res.ok ? ((await res.json()).messages || []) : null;
    } catch (_e) { st.log.rows = null; }
    if (document.body.contains(el)) draw(st, el);
  }

  const when = (iso) => {
    const d = new Date(iso);
    return isNaN(d) ? '' : d.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
  };
  const clock = (iso) => {
    const d = new Date(iso);
    return isNaN(d) ? '' : d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  };
  // A send's purpose tag → the message's name ("game_link:9295" → Game link).
  function purposeLabel(label) {
    const v = String(label || '');
    const m = v.match(/^contact:([^:]+)(?::(.*))?$/);
    if (m) {
      if (m[1] === 'reg' && m[2]) return m[2];
      return t(`msg_${m[1]}`, {}, m[2] || m[1]);
    }
    const k = v.split(':')[0];
    const named = { game_link: 'what_game', remind: 'what_remind', reg_link: 'what_reg', dues: 'what_dues', callup: 'msg_callup' }[k];
    if (named) return (window.MessageCopy && (MessageCopy.block('contact_popup', named) || MessageCopy.block('contact_box', named) || MessageCopy.block('game_center', named))) || k.replace('_', ' ');
    return v;
  }
  function logHtml(st) {
    const rows = st.log.rows;
    if (!rows) return '';
    const viaName = { club: t('log_via_club', {}, '🏢 Club text'), relay: t('log_via_relay', {}, '📱 FH Texter'),
                      email: t('log_via_email', {}, '✉ Email'), text: t('log_via_text', {}, '💬 Regular text') };
    const statusChip = (m) => {
      const s = String(m.status || '');
      if (m.via === 'email' || m.via === 'text') return '';
      const bad = s === 'failed' || s === 'undelivered';
      const color = s === 'delivered' ? '#22c55e' : bad ? '#f87171' : '#fbbf24';
      return `<span style="color:${color}; font-weight:800;">${esc(s || '—')}${bad && m.error ? ' · ' + esc(m.error) : ''}</span>`;
    };
    const items = rows.map(m => `
      <details style="border-top:1px solid #1e293b; padding:4px 0;">
        <summary style="cursor:pointer; font-size:0.78rem; line-height:1.35;">
          <b>${esc(when(m.at))}</b> · ${esc(viaName[m.via] || m.via)} · ${esc(purposeLabel(m.label))}
          ${statusChip(m)}${m.opened_at ? ` · <span style="color:#38bdf8; font-weight:800;">👀 ${esc(when(m.opened_at))}</span>` : ''}
        </summary>
        <div style="font-size:0.78rem; white-space:pre-wrap; overflow-wrap:anywhere; opacity:0.9; padding:4px 0 2px;">${m.subject ? '<b>' + esc(m.subject) + '</b>\n' : ''}${esc(m.body || '')}</div>
        ${m.contact ? `<div style="font-size:0.7rem; opacity:0.6;">→ ${esc(m.contact)}</div>` : ''}
      </details>`).join('');
    return `
      <div style="margin-top:12px; border-top:1px solid #334155; padding-top:8px;">
        <button type="button" data-cp-log style="border:none; background:none; color:#cbd5e1; font-weight:800; cursor:pointer; padding:0; font-size:0.85rem;">
          ${st.log.open ? '▾' : '▸'} ${esc(t('log_toggle', { n: rows.length }, `Recent messages (${rows.length})`))}</button>
        ${st.log.open ? (rows.length ? items : `<div style="font-size:0.8rem; opacity:0.6; padding:4px 0;">${esc(t('log_empty', {}, 'Nothing sent to this contact yet.'))}</div>`) : ''}
      </div>`;
  }

  // ── Live status after Send (mig 1085, owner 2026-11-05: "i need status
  // after send") ─────────────────────────────────────────────────────
  function statusLines(st, data) {
    const tr = st.track;
    const lines = [];
    let final = true;
    if (tr.via === 'club') {
      const c = data && data.club;
      const s = c && c.status;
      if (s === 'delivered') lines.push([t('st_delivered', { time: clock(c.updated_at) }, `✓ Delivered ${clock(c.updated_at)}`), '#22c55e']);
      else if (s === 'failed' || s === 'undelivered') lines.push([t('st_failed', { why: c.error_code || s }, `⚠ Not delivered — ${c.error_code || s}`), '#f87171']);
      else { final = false; lines.push([s === 'sent' ? t('st_club_sent', {}, '🏢 Sent — waiting for the phone to confirm…') : t('st_club_queued', {}, '🏢 Club text queued…'), '#fbbf24']); }
    } else if (tr.via === 'relay') {
      const r = data && data.relay;
      const s = r && r.status;
      if (s === 'delivered') lines.push([t('st_delivered', { time: clock(r.delivered_at) }, `✓ Delivered ${clock(r.delivered_at)}`), '#22c55e']);
      else if (s === 'failed') lines.push([t('st_failed', { why: r.error || s }, `⚠ Not delivered — ${r.error || s}`), '#f87171']);
      else if (s === 'sent') { final = false; lines.push([t('st_relay_sent', { time: clock(r.sent_at) }, `📱 Sent from your phone ${clock(r.sent_at)}, waiting for delivery…`), '#fbbf24']); }
      else { final = false; lines.push([t('st_relay_queued', {}, '📱 Waiting for your phone to send it…'), '#fbbf24']); }
    } else if (tr.via === 'email') {
      lines.push([t('st_email_device', {}, "✉ Opened in Gmail — FH can't see whether you pressed Send there."), '#cbd5e1']);
    } else if (tr.via === 'text') {
      lines.push([t('st_text_device', {}, "💬 Opened in your texting app — FH can't see whether you pressed Send there."), '#cbd5e1']);
    } else if (tr.via === 'copy') {
      return { lines, final: true };
    }
    if (tr.tokenId) {
      const o = data && data.link && data.link.opened_at;
      if (o) lines.push([t('st_link_opened', { time: clock(o) }, `👀 Link opened ${clock(o)}`), '#38bdf8']);
      else { final = false; lines.push([t('st_link_waiting', {}, 'Link not opened yet'), '#94a3b8']); }
    }
    return { lines, final };
  }

  async function poll(st, el, n = 0) {
    if (!st.track || !document.body.contains(el)) return;
    const tr = st.track;
    let data = null;
    if (tr.relayId || tr.sid || tr.tokenId) {
      try {
        const q = new URLSearchParams({ relay_id: tr.relayId || '', sid: tr.sid || '', token_id: tr.tokenId || '' });
        const res = await authFetch(`/api/phone-relay/send-status?${q}`);
        data = res.ok ? await res.json() : null;
      } catch (_e) { data = null; }
    }
    if (st.track !== tr) return;   // a newer send took over
    const { lines, final } = statusLines(st, data);
    st.status = lines;
    if (document.body.contains(el)) draw(st, el);
    // Every 3 s for 2 minutes, then every 15 s for the next 10 — a link can
    // be opened long after delivery.
    if (!final && n < 50) setTimeout(() => poll(st, el, n + 1), n < 40 ? 3000 : 15000);
    // The log picks the send up (its own row, or the final status).
    if (n === 0 || final) setTimeout(() => loadLog(st, el), 800);
  }

  function draw(st, el) {
    const { cfg } = st;
    const r = recipient(st);
    const m = message(st);
    const list = routes(st, r, m);
    if (!st.via || (list.find(v => v.key === st.via) || { why: 'x' }).why) st.via = defaultVia(list);
    const b = 'border:none; border-radius:8px; padding:7px 12px; font-weight:800; cursor:pointer; color:#fff; background:#334155; text-decoration:none; font-size:0.85rem;';
    const head = (s) => `<div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.6; margin-top:12px;">${esc(s)}</div>`;
    const radio = (group, key, label, on, why) => `
      <label style="display:flex; align-items:flex-start; gap:8px; padding:6px 8px; border-radius:8px; cursor:${why ? 'not-allowed' : 'pointer'};
                    background:${on ? 'rgba(2,132,199,0.18)' : 'transparent'}; opacity:${why ? 0.55 : 1};">
        <input type="radio" name="cp-${group}" data-cp-${group}="${esc(key)}" ${on ? 'checked' : ''} ${why ? 'disabled' : ''} style="margin-top:2px;">
        <span style="flex:1;">${esc(label)}${why ? `<br><span style="font-size:0.75rem; font-weight:700; color:#fbbf24;">⚠ ${esc(why)}</span>` : ''}</span>
      </label>`;
    const body = m && m.resolve
      ? `<div style="font-size:0.82rem; opacity:0.8; padding:8px 10px; border-radius:8px; background:#1e293b;">${esc(t('built_on_send', {}, 'Written when you send, with their own sign-in link.'))}</div>`
      : `<textarea data-cp-body rows="5" style="width:100%; box-sizing:border-box; font:inherit; font-size:0.85rem; padding:8px 10px; border-radius:8px; border:1px solid #334155; background:#1e293b; color:#f8fafc; resize:vertical;">${esc(wordsFor(st))}</textarea>`;
    const tel = (r.phone && !r.noCall) ? `<a href="tel:${esc(String(r.phone).replace(/[^\d+]/g, ''))}" data-cp-call style="${b}">${esc(t('call', {}, '📞 Call'))}</a>` : '';
    const save = cfg.onSave
      ? `<button type="button" data-cp-save style="${b}">${esc(t('save', {}, '👤 Save contact'))}</button>`
      : cfg.vcard && cfg.vcard.href && st.who === 0
      ? `<a href="${esc(cfg.vcard.href)}" download="${esc(cfg.vcard.filename || 'contact.vcf')}" style="${b}">${esc(t('save', {}, '👤 Save contact'))}</a>` : '';
    el.innerHTML = `
      <div style="width:100%; max-width:480px; max-height:90vh; overflow:auto; margin:12px; padding:16px 18px; border-radius:14px; background:#0f172a; color:#f8fafc; border:1px solid #334155; font-size:0.9rem; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <b style="font-size:1.02rem;">${esc(t('title', { name: r.name || '' }, `📇 Contact ${r.name || ''}`))}</b>
          <button type="button" data-cp-close style="border:none; background:none; color:#94a3b8; font-size:1.3rem; cursor:pointer;">×</button>
        </div>
        ${cfg.recipients.length > 1 ? head(t('who', {}, 'WHO')) + cfg.recipients.map((x, i) => radio('who', i, x.name, i === st.who, '')).join('') : ''}
        ${head(t('message', {}, 'MESSAGE'))}
        ${cfg.messages.map(x => radio('msg', x.key, x.label, x.key === st.msg, '')).join('')}
        ${head(t('words', {}, 'WORDS'))}
        <div style="margin-top:4px;">${body}</div>
        ${head(t('how', {}, 'SEND BY'))}
        ${list.map(v => radio('via', v.key, v.label, v.key === st.via, v.why)).join('')}
        <div data-cp-note style="min-height:1em; font-size:0.8rem; margin:6px 0; color:${st.noteBad ? '#fbbf24' : '#a7f3d0'};">${esc(st.note)}</div>
        ${st.status.length ? `<div data-cp-status style="display:flex; flex-direction:column; gap:2px; font-size:0.8rem; font-weight:700; margin:0 0 8px;">${
          st.status.map(([text, color]) => `<span style="color:${color};">${esc(text)}</span>`).join('')}</div>` : ''}
        <button type="button" data-cp-send ${st.via && !st.busy ? '' : 'disabled'}
                style="border:none; border-radius:10px; padding:13px; font-weight:900; font-size:1rem; cursor:pointer; color:#fff; width:100%; background:#059669; opacity:${st.via && !st.busy ? 1 : 0.5};">${esc(t('send', {}, 'Send'))}</button>
        ${tel || save ? `<div style="display:flex; gap:8px; justify-content:center; margin-top:10px;">${tel}${save}</div>` : ''}
        ${logHtml(st)}
      </div>`;
  }

  function onChange(e, st, el) {
    const d = e.target.dataset;
    if (d.cpWho !== undefined) { st.who = Number(d.cpWho); st.via = null; st.note = ''; st.status = []; st.track = null; st.log.rows = null; refresh(st, el); return; }
    if (d.cpMsg !== undefined) { st.msg = d.cpMsg; st.note = ''; draw(st, el); return; }
    if (d.cpVia !== undefined) { st.via = d.cpVia; st.note = ''; draw(st, el); }
  }

  function onClick(e, st, el) {
    if (e.target === el || e.target.closest('[data-cp-close]')) { el.remove(); return; }
    if (e.target.closest('[data-cp-send]') && !st.busy) send(st, el);
    if (e.target.closest('[data-cp-log]')) { st.log.open = !st.log.open; draw(st, el); }
    if (e.target.closest('[data-cp-call]') && st.cfg.onCall) st.cfg.onCall(recipient(st));
    if (e.target.closest('[data-cp-save]') && st.cfg.onSave) st.cfg.onSave(recipient(st));
  }

  async function send(st, el) {
    const r = recipient(st);
    const m = message(st);
    if (!m || !st.via) return;
    const via = st.via;
    const say = (note, bad) => { st.note = note; st.noteBad = !!bad; };
    st.busy = true; say(t('sending', {}, 'Sending…')); draw(st, el);
    try {
      const screen = st.cfg.screen || Screen.prototype;
      let href, resolved = null;
      if (via === 'copy') {
        if (m.resolve) resolved = await m.resolve(r, 'copy');
        const text = resolved ? (resolved.sms_body || resolved.url || '') : wordsFor(st);
        try { await navigator.clipboard.writeText(text); } catch (_e) { window.prompt(t('copied', {}, 'Copy this:'), text); }
        say(t('copied', {}, '✓ Copied'));
        if (m.onSent) m.onSent(resolved, via, text);
        st.busy = false;
        draw(st, el);
        return;
      }
      if (via === 'club' && m.sendClub) {
        href = '';
      } else if (m.resolve) {
        resolved = await m.resolve(r, via === 'email' ? 'email' : 'sms');
        href = resolved.href;
      } else if (via === 'email') {
        href = screen.buildGmailComposeHref({ to: r.email, subject: m.subject || '', body: wordsFor(st) });
      } else {
        href = screen.buildSmsComposeHref({ to: r.phone, body: Screen.withSmsLinkHint(wordsFor(st)) });
      }
      const words = wordsFor(st);
      const tokenId = resolved && (resolved.token_id || resolved.tokenId) || null;
      // What gets tracked after Send (mig 1085): the club text's Twilio SID,
      // the FH Texter row, or — for ✉ / 💬, which open the sender's own app —
      // just the sign-in link, plus a contact_sends row for the log.
      const track = { via, tokenId, sid: null, relayId: null };
      const logDevice = (kind) => {
        let subject = m.subject || '', body = words;
        try {
          if (kind === 'email' && href) { const u = new URL(href); body = u.searchParams.get('body') || body; subject = u.searchParams.get('su') || subject; }
          if (kind === 'text' && href && window.DesktopSms) body = DesktopSms.parse(href).body || body;
        } catch (_e) { /* keep the typed words */ }
        authFetch('/api/phone-relay/device-send', { method: 'POST', body: JSON.stringify({
          person_id: r.personId || null, for_person_id: r.forPersonId || null, via: kind,
          contact: kind === 'email' ? r.email : r.phone, label: m.label || m.key, subject, body,
          token_id: tokenId }) }).catch(() => {});
      };
      if (via === 'email') {
        if (m.beforeEmail) m.beforeEmail(words);
        screen.openGmailCompose(href);
        say(t('opened_email', {}, '✓ Email opened'));
        logDevice('email');
      } else if (via === 'text') {
        if (window.DesktopSms) DesktopSms.open(href); else window.location.href = href;
        say(t('opened_text', {}, '✓ Text opened'));
        logDevice('text');
      } else {
        const purpose = m.purpose || `contact:${m.key}`;
        if (via === 'club' && m.sendClub) {
          const sent = await m.sendClub(r);          // the screen's own tracked club send (a game link)
          track.sid = (sent && (sent.sid || (sent.sends && sent.sends[0] && sent.sends[0].sid))) || null;
        } else {
          const body = DesktopSms.parse(href).body;
          const url = via === 'club' ? '/api/phone-relay/club-text' : '/api/phone-relay/texts';
          const payload = via === 'club'
            ? { person_id: r.personId, to: r.phone, body, for_person_id: r.forPersonId || r.personId, purpose }
            : { to: r.phone, body, for_person_id: r.forPersonId || r.personId, purpose, ...(tokenId ? { magic_link_token_id: tokenId } : {}) };
          const res = await authFetch(url, { method: 'POST', body: JSON.stringify(payload) });
          const data = await res.json().catch(() => ({}));
          if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
          if (via === 'club') track.sid = data.sid || null; else track.relayId = data.id || null;
        }
        say(via === 'club' ? t('sent_club', {}, '✓ Sent from the club number') : t('sent_relay', {}, '✓ Sent to your phone to send'));
      }
      if (m.onSent) m.onSent(resolved, via, words);
      st.track = track;
      st.status = [];
      setTimeout(() => poll(st, el), via === 'email' || via === 'text' ? 0 : 1500);
    } catch (err) {
      say(`⚠ ${err.message}`, true);
    }
    st.busy = false;
    draw(st, el);
  }

  document.addEventListener('click', (e) => {
    const b = e.target.closest && e.target.closest('[data-contact-popup]');
    if (!b) return;
    const cfg = registry.get(b.dataset.contactPopup);
    if (!cfg) return;
    e.preventDefault();
    e.stopPropagation();
    // Fold the ⋯ menu the button sat in (#teams cards) — never a section
    // fold like No response (owner 11/3: "i hate that you close what i had
    // open when i do contact").
    b.closest('details.roster-move-details[open]')?.removeAttribute('open');
    open(cfg);
  }, true);

  // The plain hello every screen offers (contact_email / contact_sms).
  function helloMessage(tier, first, tokens = {}) {
    const fill = { first: first || '', ...tokens };
    const copy = window.MessageCopy && MessageCopy.render('contact_email', tier, fill);
    if (!copy) return null;
    return { key: 'hello', label: t('msg_hello', {}, '💬 Message'), subject: copy.subject, body: copy.body,
             smsBody: MessageCopy.block('contact_sms', tier, fill) };
  }

  // Nothing pre-written: the sender's own words.
  function blankMessage() {
    return { key: 'blank', label: t('msg_blank', {}, '✏️ Blank'), subject: '', body: '' };
  }

  // A sign-in link for this recipient, written when it is sent.
  function signInMessage() {
    return {
      key: 'signin',
      label: t('msg_signin', {}, '🔗 Sign-in link'),
      resolve: async (r, channel) => {
        const res = await authFetch('/api/auth/magic-link/mint', { method: 'POST', body: JSON.stringify({
          person_id: r.personId, channel, contact: channel === 'email' ? r.email : r.phone }) });
        if (!res.ok) throw new Error((await res.text()).slice(0, 200) || `HTTP ${res.status}`);
        const data = await res.json();
        const href = channel === 'email' ? (data.gmail_href || data.mailto_href) : data.sms_href;
        if (!href) throw new Error('No message came back');
        return { ...data, href };
      },
    };
  }

  window.ContactPopup = { button, open, routes, defaultVia, helloMessage, blankMessage, signInMessage };
})();
