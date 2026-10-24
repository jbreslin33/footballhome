// DesktopSms — "text from my phone" on a computer (mig 659; owner
// 2026-10-23: "i want to be able to text from my android online so i can
// text from desktop for those not opted into twilio").
//
// On a phone an sms: link opens the texting app pre-filled.  On a desktop
// it opens nothing useful, and Google Messages for Web (the paired
// Android) has no supported link that pre-fills a chat.  So on a desktop
// every sms: hand-off — a clicked sms: link anywhere in the app, or a
// screen calling DesktopSms.open(href) — shows a panel instead: the
// number(s) and the message, each with a Copy button, and a button that
// opens Google Messages in one reused tab.  Phones are untouched.
//
// Words: message_templates kind desktop_sms (read through MessageCopy).
(function () {
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const t = (tier, tokens, fallback) =>
    (window.MessageCopy && MessageCopy.block && MessageCopy.block('desktop_sms', tier, tokens)) || fallback;

  // A touch device with a phone-sized OS is a phone; everything else is a
  // computer.  iPads count as phones — they hand sms: to Messages.
  function isDesktop() {
    return !/Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent || '');
  }

  // sms:+1215…,+1484…?body=… → { to: [...], body }
  function parse(href) {
    const raw = String(href || '').replace(/^sms:/i, '');
    const q = raw.search(/[?&]/);
    const toPart = q < 0 ? raw : raw.slice(0, q);
    const params = new URLSearchParams(q < 0 ? '' : raw.slice(q + 1).replace(/^&/, ''));
    const to = decodeURIComponent(toPart).split(/[,;]/).map(s => s.trim()).filter(Boolean);
    return { to, body: params.get('body') || '' };
  }

  async function copy(text, btn) {
    try { await navigator.clipboard.writeText(text); }
    catch (_e) {
      const ta = document.createElement('textarea');
      ta.value = text; document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy'); } catch (_e2) {}
      ta.remove();
    }
    if (btn) { btn.textContent = t('copied', {}, '✓ copied'); btn.style.background = '#059669'; }
  }

  // The words come from MessageCopy, which a screen loads when it needs
  // it; a panel opened from any other screen loads it itself first.
  async function ensureCopy() {
    const mc = window.MessageCopy;
    if (!mc || !mc.load || mc.has('desktop_sms', 'title')) return;
    let token = '';
    try { token = localStorage.getItem('token') || ''; } catch (_e) {}
    const auth = { fetch: (url, opts = {}) => fetch(url, { ...opts,
      headers: { ...(opts.headers || {}), ...(token ? { Authorization: 'Bearer ' + token } : {}) } }) };
    try { await mc.load(auth); } catch (_e) { /* fallback words */ }
  }

  async function show(href) {
    await ensureCopy();
    const { to, body } = parse(href);
    document.getElementById('fh-desktop-sms')?.remove();
    const el = document.createElement('div');
    el.id = 'fh-desktop-sms';
    el.setAttribute('role', 'dialog');
    el.style.cssText = 'position:fixed; inset:0; z-index:10002; background:rgba(0,0,0,0.55); display:flex; align-items:center; justify-content:center;';
    const b = 'border:none; border-radius:8px; padding:6px 12px; font-weight:800; cursor:pointer; color:#fff; background:#334155; white-space:nowrap;';
    el.innerHTML = `
      <div style="width:100%; max-width:520px; max-height:90vh; overflow:auto; margin:12px; padding:16px 18px; border-radius:14px;
                  background:#0f172a; color:#f8fafc; border:1px solid #334155; font-size:0.9rem;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <b style="font-size:1.02rem;">${esc(t('title', {}, '💬 Text from your phone — on this computer'))}</b>
          <button type="button" data-ds-close style="border:none; background:none; color:#94a3b8; font-size:1.3rem; cursor:pointer;">×</button>
        </div>
        <div data-ds-relay></div>
        <div style="font-size:0.78rem; opacity:0.75; margin:4px 0 12px;">${esc(t('hint', {}, ''))}</div>
        <div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.6;">${esc(t('to', { n: to.length }, `To (${to.length})`).toUpperCase())}</div>
        <div style="display:flex; flex-direction:column; gap:4px; margin:4px 0 10px;">
          ${to.map(n => `<div style="display:flex; gap:8px; align-items:center;">
              <code style="flex:1; font-size:0.95rem;">${esc(n)}</code>
              <button type="button" data-ds-copy="${esc(n)}" style="${b}">${esc(t('copy', {}, 'Copy'))}</button></div>`).join('')}
          ${to.length > 1 ? `<button type="button" data-ds-copy="${esc(to.join(', '))}" style="${b} align-self:flex-end;">${esc(t('copy_all', {}, 'Copy all'))}</button>` : ''}
        </div>
        ${body ? `<div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.6;">${esc(t('message', {}, 'Message').toUpperCase())}</div>
        <pre style="white-space:pre-wrap; font-family:inherit; font-size:0.85rem; background:#1e293b; border-radius:8px; padding:8px 10px; margin:4px 0 6px; max-height:30vh; overflow:auto;">${esc(body)}</pre>
        <div style="text-align:right; margin-bottom:12px;"><button type="button" data-ds-copy-body style="${b}">${esc(t('copy', {}, 'Copy'))}</button></div>` : ''}
        <div style="display:flex; flex-direction:column; gap:8px;">
          <button type="button" data-ds-step1 style="${b} padding:12px; background:#0284c7; font-size:0.98rem;">${esc(t('step1', {}, '1 · Copy number & open Messages'))}</button>
          <div data-ds-hint1 style="display:none; font-size:0.78rem; color:#7dd3fc;">${esc(t('step1_hint', {}, 'In Messages: Start chat → paste (Ctrl+V) → Enter.'))}</div>
          ${body ? `<button type="button" data-ds-step2 style="${b} padding:12px; background:#7c3aed; font-size:0.98rem;">${esc(t('step2', {}, '2 · Copy message'))}</button>
          <div data-ds-hint2 style="display:none; font-size:0.78rem; color:#c4b5fd;">${esc(t('step2_hint', {}, 'Click the message box in Messages → paste (Ctrl+V) → send.'))}</div>` : ''}
          <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
            <span style="font-size:0.7rem; opacity:0.6;">${esc(t('tabs_hint', {}, ''))}</span>
            <button type="button" data-ds-close style="${b}">${esc(t('close', {}, 'Done'))}</button>
          </div>
        </div>
        <div style="margin-top:8px; text-align:center;"><a href="${esc(href)}" data-ds-native
          style="font-size:0.75rem; color:#94a3b8;">${esc(t('phone_app', {}, 'Open my texting app instead'))}</a></div>
      </div>`;
    el.addEventListener('click', (e) => {
      if (e.target === el || e.target.closest('[data-ds-close]')) { el.remove(); return; }
      const c = e.target.closest('[data-ds-copy]');
      if (c) { copy(c.dataset.dsCopy, c); return; }
      const cb = e.target.closest('[data-ds-copy-body]');
      if (cb) { copy(body, cb); return; }
      const s1 = e.target.closest('[data-ds-step1]');
      if (s1) {
        copy(to.join(', '), s1);
        openMessages();
        el.querySelector('[data-ds-hint1]').style.display = '';
        return;
      }
      const s2 = e.target.closest('[data-ds-step2]');
      if (s2) {
        copy(body, s2);
        el.querySelector('[data-ds-hint2]').style.display = '';
      }
    });
    document.body.appendChild(el);
    relaySection(el.querySelector('[data-ds-relay]'), to, body);
  }

  // ---- FH Texter (mig 667) ----
  // The coach's own Android, paired once, sends the text when they click
  // Send here — no pasting, no touching the phone.  Football Home checks
  // every guardrail (one recipient, spacing, daily cap, STOP); this only
  // shows the state and asks.
  const r = (tier, tokens, fb) =>
    (window.MessageCopy && MessageCopy.block && MessageCopy.block('phone_relay', tier, tokens)) || fb || '';

  function authFetch(url, opts = {}) {
    let token = '';
    try { token = localStorage.getItem('token') || ''; } catch (_e) {}
    return fetch(url, { ...opts, headers: { 'Content-Type': 'application/json', ...(opts.headers || {}),
                                             ...(token ? { Authorization: 'Bearer ' + token } : {}) } });
  }

  function ago(iso) {
    if (!iso) return 'never';
    const m = Math.round((Date.now() - new Date(iso).getTime()) / 60000);
    return m < 1 ? 'just now' : m < 60 ? `${m} min ago` : m < 1440 ? `${Math.round(m / 60)} h ago` : `${Math.round(m / 1440)} d ago`;
  }

  const big = 'border:none; border-radius:10px; padding:13px; font-weight:900; font-size:1rem; cursor:pointer; color:#fff; width:100%;';

  async function relaySection(slot, to, body) {
    if (!slot) return;
    let st;
    try {
      const res = await authFetch('/api/phone-relay/status');
      if (!res.ok) return;                       // not an admin: the paste path only
      st = await res.json();
    } catch (_e) { return; }
    const dev = (st.devices || [])[0];
    const counter = `<div style="font-size:0.72rem; opacity:0.65; margin-top:4px;">${esc(r('today', { n: st.today, cap: st.cap }))}</div>`;
    const off = (why) => `<div style="margin-bottom:12px; padding:10px; border-radius:10px; border:1px dashed #475569;">
        <div style="font-weight:800; opacity:0.55;">${esc(r('send', {}, '📱 Send from my phone'))}</div>
        <div style="font-size:0.78rem; color:#fbbf24; margin-top:3px;">⚠ ${esc(why)}</div>
        ${!dev ? `<button type="button" data-ds-setup style="border:none; background:none; color:#7dd3fc; text-decoration:underline; cursor:pointer; padding:6px 0 0; font-size:0.82rem;">${esc(r('setup'))}</button>` : counter}
      </div>`;
    if (!dev) slot.innerHTML = off(r('not_paired'));
    else if (!dev.online) slot.innerHTML = off(r('offline', { ago: ago(dev.last_seen_at) }));
    else if (to.length !== 1) slot.innerHTML = off(r('group'));
    else if (st.today >= st.cap) slot.innerHTML = off(r('cap', { n: st.today }));
    else slot.innerHTML = `<div style="margin-bottom:12px;">
        <button type="button" data-ds-relay-send style="${big} background:#059669;">${esc(r('send', {}, '📱 Send from my phone'))}</button>
        <div data-ds-relay-status style="font-size:0.8rem; margin-top:5px; color:#a7f3d0;">${esc(r('send_hint', { device: dev.name }))}</div>
        ${counter}
      </div>`;
    slot.onclick = (e) => {
      if (e.target.closest('[data-ds-setup]')) { e.stopPropagation(); setup(slot); return; }
      const btn = e.target.closest('[data-ds-relay-send]');
      if (btn && !btn.disabled) { e.stopPropagation(); sendViaPhone(slot, btn, to[0], body); }
    };
  }

  async function sendViaPhone(slot, btn, to, body) {
    btn.disabled = true;
    btn.style.opacity = '0.6';
    const line = slot.querySelector('[data-ds-relay-status]');
    const say = (text, color) => { if (line) { line.textContent = text; line.style.color = color || '#a7f3d0'; } };
    let res, data;
    try {
      res = await authFetch('/api/phone-relay/texts', { method: 'POST', body: JSON.stringify({ to, body }) });
      data = await res.json().catch(() => ({}));
    } catch (err) { data = { error: err.message }; }
    if (!res || !res.ok) {
      say('⚠ ' + (data.error || 'could not send'), '#fbbf24');
      btn.disabled = false; btn.style.opacity = '';
      return;
    }
    // Follow it until the phone reports back (or gives up).
    const words = (d) => d.status === 'failed' ? r('failed', { error: d.error || '?' }) : r(d.status, {}, d.status);
    say(words(data));
    const started = Date.now();
    const tick = async () => {
      try {
        const s = await (await authFetch(`/api/phone-relay/texts/${data.id}`)).json();
        const bad = s.status === 'failed' || s.status === 'expired';
        say((bad ? '⚠ ' : '') + words(s), bad ? '#f87171' : '#a7f3d0');
        if (s.status === 'delivered' || bad) return;
        if (s.status === 'sent') btn.textContent = r('sent', {}, 'sent ✓');
      } catch (_e) { /* keep trying */ }
      if (Date.now() - started < 5 * 60000 && document.body.contains(slot)) setTimeout(tick, 2000);
    };
    setTimeout(tick, 1500);
  }

  // One-time pairing: a code on this screen, typed into the app.
  async function setup(slot) {
    let data = {};
    try { data = await (await authFetch('/api/phone-relay/pair-code', { method: 'POST', body: '{}' })).json(); } catch (_e) {}
    if (!data.code) { slot.innerHTML = `<div style="color:#f87171;">⚠ ${esc(data.error || 'could not start setup')}</div>`; return; }
    slot.innerHTML = `<div style="margin-bottom:12px; padding:12px; border-radius:10px; border:1px solid #0284c7; background:rgba(2,132,199,0.12);">
        <div style="font-weight:900; margin-bottom:6px;">${esc(r('setup_title'))}</div>
        <div style="font-size:0.85rem; white-space:pre-line;">${esc(r('setup_steps', { url: data.apk_url }))}</div>
        <div style="font-family:monospace; font-size:2rem; font-weight:900; letter-spacing:0.25em; text-align:center; margin:10px 0;">${esc(data.code)}</div>
        <div data-ds-pair-status style="font-size:0.8rem; color:#7dd3fc;">${esc(r('setup_wait'))}</div>
      </div>`;
    const started = Date.now();
    const wait = async () => {
      if (!document.body.contains(slot)) return;
      try {
        const st = await (await authFetch('/api/phone-relay/status')).json();
        const dev = (st.devices || [])[0];
        if (dev) {
          const s = slot.querySelector('[data-ds-pair-status]');
          if (s) { s.textContent = r('setup_done', { device: dev.name }); s.style.color = '#34d399'; }
          return;
        }
      } catch (_e) {}
      if (Date.now() - started < 15 * 60000) setTimeout(wait, 3000);
    };
    setTimeout(wait, 3000);
  }

  // Google Messages in its own small window beside Football Home, named so
  // every text reuses it (a hand-opened Messages tab can't be reached).
  function openMessages() {
    const w = Math.min(560, Math.round(screen.availWidth * 0.4));
    const left = Math.max(0, screen.availWidth - w);
    const win = window.open('https://messages.google.com/web/conversations/new', 'fh-google-messages',
      `popup,width=${w},height=${screen.availHeight},left=${left},top=0`);
    if (win) win.focus();
  }

  // Screens hand an sms: href here instead of assigning location.href.
  function open(href) {
    if (!href) return;
    if (isDesktop()) show(href);
    else window.location.href = href;
  }

  // Any sms: link clicked on a desktop opens the panel instead — except
  // the panel's own "use my texting app" escape hatch.
  document.addEventListener('click', (e) => {
    const a = e.target.closest && e.target.closest('a[href^="sms:"]');
    if (!a || a.hasAttribute('data-ds-native') || !isDesktop()) return;
    e.preventDefault();
    show(a.getAttribute('href'));
  }, true);

  window.DesktopSms = { open, isDesktop, parse };
})();
