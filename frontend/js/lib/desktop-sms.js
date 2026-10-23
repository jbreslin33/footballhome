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

  window.DesktopSms = { open, isDesktop };
})();
