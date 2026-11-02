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
//   screen:     the Screen, for its compose-link builders,
//   recipients: [{ personId, name, phone, email, forPersonId }],
//   messages:   [{ key, label, subject, body, smsBody, resolve, onSent }],
//   defaultKey, flagged (draw the button fuchsia), title,
//   vcard:      { href, filename }
// }
// resolve(recipient, 'email'|'sms') → { href, ... } is for words the
// server builds at send time (sign-in link, welcome).
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
    return `<button type="button" data-contact-popup="${esc(cfg.key)}" title="${esc(cfg.title || '')}"
      style="font-size:0.68rem; font-weight:800; line-height:1.2; padding:2px 6px; border-radius:3px; border:none; cursor:pointer; color:#fff;
             white-space:nowrap; background:${cfg.flagged ? '#c026d3' : '#334155'};">📇 ${esc(t('button', {}, 'CONTACT'))}</button>`;
  }

  // The FH Texter + club number state for one recipient.  A 403/404 means
  // this viewer does not get that route, never that the popup fails.
  async function loadRoutes(st, r) {
    const key = r.personId;
    if (st.relayLoaded === undefined) {
      st.relayLoaded = true;
      try {
        const res = await authFetch('/api/phone-relay/status');
        st.relay = res.ok ? await res.json() : null;
      } catch (_e) { st.relay = null; }
    }
    if (key && r.phone && !(key in st.consent)) {
      try {
        const res = await authFetch(`/api/phone-relay/contact-state?person_id=${encodeURIComponent(key)}&to=${encodeURIComponent(r.phone)}`);
        st.consent[key] = res.ok ? (await res.json()).consent : null;
      } catch (_e) { st.consent[key] = null; }
    }
  }

  function routes(st, r) {
    const dev = st.relay && (st.relay.devices || [])[0];
    const consent = st.consent[r.personId];
    const stopped = consent === 'stopped';
    const noPhone = r.phone ? '' : t('why_no_phone', {}, 'No mobile number on file');
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
    if (consent) {
      list.push({ key: 'club', label: t('via_club', {}, '🏢 Club text'),
        why: noPhone || (stopped ? t('why_stopped', {}, 'They replied STOP')
           : consent !== 'in' ? t('why_not_opted_in', {}, 'Not opted in to club texts') : '') });
    }
    return list;
  }

  // Default: the club number for someone opted in, then FH Texter, then
  // the texting app, then email (owner 2026-10-24).
  function defaultVia(list) {
    return ['club', 'relay', 'text', 'email'].find(k => (list.find(v => v.key === k) || { why: 'x' }).why === '') || null;
  }

  function open(cfg) {
    const st = { cfg, who: 0, msg: cfg.defaultKey || (cfg.messages[0] && cfg.messages[0].key), via: null,
                 edits: {}, consent: {}, note: '', noteBad: false, busy: false };
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
  }

  function draw(st, el) {
    const { cfg } = st;
    const r = recipient(st);
    const list = routes(st, r);
    if (!st.via || (list.find(v => v.key === st.via) || { why: 'x' }).why) st.via = defaultVia(list);
    const m = message(st);
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
    const tel = r.phone ? `<a href="tel:${esc(r.phone)}" style="${b}">${esc(t('call', {}, '📞 Call'))}</a>` : '';
    const save = cfg.vcard && cfg.vcard.href && st.who === 0
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
        <button type="button" data-cp-send ${st.via && !st.busy ? '' : 'disabled'}
                style="border:none; border-radius:10px; padding:13px; font-weight:900; font-size:1rem; cursor:pointer; color:#fff; width:100%; background:#059669; opacity:${st.via && !st.busy ? 1 : 0.5};">${esc(t('send', {}, 'Send'))}</button>
        ${tel || save ? `<div style="display:flex; gap:8px; justify-content:center; margin-top:10px;">${tel}${save}</div>` : ''}
      </div>`;
  }

  function onChange(e, st, el) {
    const d = e.target.dataset;
    if (d.cpWho !== undefined) { st.who = Number(d.cpWho); st.via = null; st.note = ''; refresh(st, el); return; }
    if (d.cpMsg !== undefined) { st.msg = d.cpMsg; st.note = ''; draw(st, el); return; }
    if (d.cpVia !== undefined) { st.via = d.cpVia; st.note = ''; draw(st, el); }
  }

  function onClick(e, st, el) {
    if (e.target === el || e.target.closest('[data-cp-close]')) { el.remove(); return; }
    if (e.target.closest('[data-cp-send]') && !st.busy) send(st, el);
  }

  async function send(st, el) {
    const r = recipient(st);
    const m = message(st);
    if (!m || !st.via) return;
    const via = st.via;
    const say = (note, bad) => { st.note = note; st.noteBad = !!bad; };
    st.busy = true; say(t('sending', {}, 'Sending…')); draw(st, el);
    try {
      const screen = st.cfg.screen;
      let href, resolved = null;
      if (m.resolve) {
        resolved = await m.resolve(r, via === 'email' ? 'email' : 'sms');
        href = resolved.href;
      } else if (via === 'email') {
        href = screen.buildGmailComposeHref({ to: r.email, subject: m.subject || '', body: wordsFor(st) });
      } else {
        href = screen.buildSmsComposeHref({ to: r.phone, body: Screen.withSmsLinkHint(wordsFor(st)) });
      }
      if (via === 'email') {
        window.open(href, '_blank', 'noopener');
        say(t('opened_email', {}, '✓ Email opened'));
      } else if (via === 'text') {
        if (window.DesktopSms) DesktopSms.open(href); else window.location.href = href;
        say(t('opened_text', {}, '✓ Text opened'));
      } else {
        const body = DesktopSms.parse(href).body;
        const url = via === 'club' ? '/api/phone-relay/club-text' : '/api/phone-relay/texts';
        const payload = via === 'club'
          ? { person_id: r.personId, to: r.phone, body, for_person_id: r.forPersonId || r.personId, purpose: `contact:${m.key}` }
          : { to: r.phone, body, for_person_id: r.forPersonId || r.personId, purpose: `contact:${m.key}` };
        const res = await authFetch(url, { method: 'POST', body: JSON.stringify(payload) });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
        say(via === 'club' ? t('sent_club', {}, '✓ Sent from the club number') : t('sent_relay', {}, '✓ Sent to your phone to send'));
      }
      if (m.onSent) m.onSent(resolved);
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
    b.closest('details[open]')?.removeAttribute('open');
    open(cfg);
  }, true);

  window.ContactPopup = { button, open, routes, defaultVia };
})();
