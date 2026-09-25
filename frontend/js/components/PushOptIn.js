// PushOptIn — the one place that knows whether THIS browser can get
// Football Home push notifications, and the one control that turns them
// on or off: a thin toggle with the words next to it (owner 2026-09-25:
// "thin toggle that says next to it 'Game & Practice Reminders On' or
// '...Off' depending on toggle").  Replaced the 2026-09-05 banner.
//
// Two mount points — top of My Schedule (#my) and Soccer Calendar
// (#calendar) — one component.  Wording is message_templates kind
// 'push_toggle' (migration 435) via MessageCopy; the strings below are
// only the fallback when copy has not loaded.
//
// State is read from the browser, never guessed (see
// backend/src/services/WebPushService.h for why opt-in can never be
// automatic):
//   subscribed   → this browser holds a push subscription   → toggle ON
//   ready        → supported, not subscribed                → toggle OFF
//   blocked      → user denied for this site; only they can undo it
//   ios-safari   → iOS Push API only exists once "installed" via Add to
//                  Home Screen → toggle OFF, disabled, with the how-to
//   unsupported  → anything else without the APIs → nothing shown
//
// A subscription is per device/browser: the toggle says what THIS one
// does.  Every write is a tap: requestPermission() is only honoured
// inside a user gesture, and the change handler IS one.
(function () {
  const FALLBACK = {
    on:        'Game & Practice Reminders On',
    off:       'Game & Practice Reminders Off',
    busy:      'Game & Practice Reminders …',
    blocked:   'Reminders blocked — allow notifications for footballhome.org in your browser settings',
    ios:       'Game & Practice Reminders Off — add to Home Screen first',
    ios_howto: 'In Safari tap Share (the box with the arrow) → Add to Home Screen, open Football Home from there, then flip this on.',
    hint:      'On this device: a ping when a coach sends you an RSVP reminder for a game or practice, and for chat posts.',
  };
  function copy(tier) {
    const mc = window.MessageCopy;
    const s = mc && typeof mc.block === 'function' ? mc.block('push_toggle', tier) : '';
    return s || FALLBACK[tier] || '';
  }

  function isIOS() { return /iphone|ipad|ipod/i.test(navigator.userAgent); }
  function isStandalone() {
    return window.matchMedia('(display-mode: standalone)').matches
      || window.navigator.standalone === true;
  }

  function urlBase64ToUint8Array(base64Url) {
    const padding = '='.repeat((4 - (base64Url.length % 4)) % 4);
    const base64 = (base64Url + padding).replace(/-/g, '+').replace(/_/g, '/');
    const raw = atob(base64);
    const out = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
    return out;
  }

  // Reads + writes go through the caller's auth object. GET via
  // auth.fetch (impersonation rewrite applies); POST/DELETE via raw fetch
  // with bearer + cookie so both auth paths flow — same split my.js uses.
  async function getJson(auth, url) {
    const res = await auth.fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json();
  }
  async function sendJson(auth, method, url, body) {
    const headers = { 'Content-Type': 'application/json' };
    if (auth && auth.token) headers['Authorization'] = `Bearer ${auth.token}`;
    const res = await fetch(url, { method, headers, credentials: 'include', body: JSON.stringify(body) });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json().catch(() => ({}));
  }

  async function state() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      return { status: (isIOS() && !isStandalone()) ? 'ios-safari' : 'unsupported' };
    }
    if (Notification.permission === 'denied') return { status: 'blocked' };
    try {
      const reg = await navigator.serviceWorker.ready;
      const sub = await reg.pushManager.getSubscription();
      if (sub) return { status: 'subscribed' };
    } catch (err) {
      console.warn('[PushOptIn] subscription check failed:', err);
    }
    return { status: 'ready' };
  }

  // Must be called from a user gesture.
  async function enable(auth) {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return { status: 'blocked' };
    const { key } = await getJson(auth, '/api/push/vapid-public-key');
    const reg = await navigator.serviceWorker.ready;
    const sub = await reg.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(key),
    });
    const subJson = sub.toJSON();
    await sendJson(auth, 'POST', '/api/my/push-subscriptions', {
      endpoint: subJson.endpoint,
      keys: subJson.keys,
      userAgent: navigator.userAgent,
    });
    return { status: 'subscribed' };
  }

  // Drops this browser's subscription on both sides.  The server row goes
  // first so a failed browser unsubscribe can't leave a dead endpoint that
  // still gets sent to.
  async function disable(auth) {
    const reg = await navigator.serviceWorker.ready;
    const sub = await reg.pushManager.getSubscription();
    if (!sub) return { status: 'ready' };
    try { await sendJson(auth, 'DELETE', '/api/my/push-subscriptions', { endpoint: sub.endpoint }); }
    catch (err) { console.warn('[PushOptIn] server unsubscribe failed:', err); }
    await sub.unsubscribe();
    return { status: 'ready' };
  }

  const rowStyle   = 'display:flex; align-items:center; gap:8px; padding:4px 2px 6px; margin:0 0 6px; '
    + 'font-size:0.74rem; line-height:1.2; color:#dbeafe; flex-wrap:wrap;';
  const labelStyle = 'display:inline-flex; align-items:center; gap:8px; cursor:pointer; user-select:none;';
  const trackStyle = 'position:relative; width:30px; height:16px; border-radius:999px; flex:0 0 auto; '
    + 'background:rgba(148,163,184,0.35); border:1px solid rgba(148,163,184,0.5); transition:background .15s;';
  const knobStyle  = 'position:absolute; top:1px; left:1px; width:12px; height:12px; border-radius:50%; '
    + 'background:#fff; transition:transform .15s;';
  const noteStyle  = 'flex-basis:100%; font-size:0.68rem; opacity:0.8; margin-left:38px;';

  function html(s) {
    const on = s.status === 'subscribed';
    const disabled = s.status === 'blocked' || s.status === 'ios-safari';
    const text = s.status === 'subscribed' ? copy('on')
               : s.status === 'blocked'    ? copy('blocked')
               : s.status === 'ios-safari' ? copy('ios')
               : copy('off');
    const note = s.status === 'ios-safari' ? copy('ios_howto') : '';
    return `
      <div style="${rowStyle}" data-push-toggle="${s.status}">
        <label style="${labelStyle}${disabled ? ' cursor:default; opacity:0.75;' : ''}">
          <input type="checkbox" role="switch" data-push-switch ${on ? 'checked' : ''} ${disabled ? 'disabled' : ''}
                 aria-label="${text.replace(/"/g, '&quot;')}"
                 style="position:absolute; opacity:0; width:1px; height:1px; pointer-events:none;">
          <span data-push-track style="${trackStyle}${on ? ' background:#22c55e; border-color:#22c55e;' : ''}">
            <span style="${knobStyle}${on ? ' transform:translateX(14px);' : ''}"></span>
          </span>
          <span data-push-text style="font-weight:700;">${text}</span>
        </label>
        ${note ? `<div style="${noteStyle}">${note}</div>` : ''}
      </div>`;
  }

  // Fill `container` with the toggle for the current state, or empty it
  // when push is unsupported here.  `onChange(state)` fires after a
  // successful flip so the host screen can refresh anything else that
  // shows push status.  Safe to call again; it re-reads state every time.
  async function mount(container, auth, { onChange } = {}) {
    if (!container) return;
    if (window.MessageCopy && typeof MessageCopy.load === 'function' && auth) {
      try { await MessageCopy.load(auth); } catch (_) { /* fallback strings */ }
    }
    const s = await state();
    if (s.status === 'unsupported') { container.innerHTML = ''; return; }
    container.innerHTML = html(s);
    const input = container.querySelector('[data-push-switch]');
    if (!input || input.disabled) return;
    input.addEventListener('change', async () => {
      const text = container.querySelector('[data-push-text]');
      input.disabled = true;
      if (text) text.textContent = copy('busy');
      let result;
      try {
        result = input.checked ? await enable(auth) : await disable(auth);
      } catch (err) {
        console.error('[PushOptIn] toggle failed:', err);
        result = await state();
      }
      await mount(container, auth, { onChange });
      if (result && result.status === 'subscribed') {
        const hint = copy('hint');
        const row = container.querySelector('[data-push-toggle]');
        if (hint && row) {
          const n = document.createElement('div');
          n.setAttribute('style', noteStyle);
          n.textContent = hint;
          row.appendChild(n);
          setTimeout(() => { if (n.parentNode) n.parentNode.removeChild(n); }, 8000);
        }
      }
      if (typeof onChange === 'function') onChange(result || (await state()));
    });
  }

  window.PushOptIn = { state, enable, disable, mount, urlBase64ToUint8Array };
})();
