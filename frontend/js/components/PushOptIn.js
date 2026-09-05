// PushOptIn — the one place that knows whether THIS browser can get
// Football Home push notifications, and the one tap that turns them on.
//
// Owner 2026-09-05: "build the notifications banner on calendar". Four
// people had push on because the only control was a 0.58rem pill in the
// chat header on #my. Magic-link recipients land on #calendar, which had
// no control at all. So: one component, two mount points (My Schedule
// and Soccer Calendar), and the pill on #my keeps working off the same
// state function.
//
// State is read from the browser, never guessed (see
// backend/src/services/WebPushService.h for why opt-in can never be
// automatic):
//   subscribed      → this browser already holds a push subscription
//   ready           → supported, permission not yet asked → show banner
//   blocked         → user denied for this site; only they can undo it
//   ios-safari      → iOS Push API only exists once "installed" via
//                     Add to Home Screen → show the how-to variant
//   unsupported     → anything else without the APIs → show nothing
//
// The banner is a <div> the caller owns. mount() fills it or empties it
// according to state; a dismissed banner stays hidden for 14 days on
// this device (localStorage) so it nudges without nagging. Every write
// still needs a tap: requestPermission() is only honoured inside a user
// gesture, and the click handler IS one.
(function () {
  const DISMISS_KEY = 'fh.pushOptIn.dismissedUntil';
  const DISMISS_DAYS = 14;

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

  function dismissedNow() {
    try {
      const until = Number(localStorage.getItem(DISMISS_KEY) || 0);
      return until > Date.now();
    } catch (_) { return false; }
  }
  function dismiss() {
    try { localStorage.setItem(DISMISS_KEY, String(Date.now() + DISMISS_DAYS * 86400000)); } catch (_) {}
  }

  // Reads + writes go through the caller's auth object. GET via
  // auth.fetch (impersonation rewrite applies); POST via raw fetch with
  // bearer + cookie so both auth paths flow — same split my.js uses.
  async function getJson(auth, url) {
    const res = await auth.fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json();
  }
  async function postJson(auth, url, body) {
    const headers = { 'Content-Type': 'application/json' };
    if (auth && auth.token) headers['Authorization'] = `Bearer ${auth.token}`;
    const res = await fetch(url, { method: 'POST', headers, credentials: 'include', body: JSON.stringify(body) });
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

  // Must be called from a click handler (user gesture).
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
    await postJson(auth, '/api/my/push-subscriptions', {
      endpoint: subJson.endpoint,
      keys: subJson.keys,
      userAgent: navigator.userAgent,
    });
    return { status: 'subscribed' };
  }

  const wrapStyle = 'display:flex; align-items:center; gap:10px; flex-wrap:wrap; '
    + 'padding:9px 12px; margin:0 0 8px; border-radius:8px; '
    + 'background:linear-gradient(90deg, rgba(37,99,235,0.28), rgba(37,99,235,0.10)); '
    + 'border:1px solid rgba(96,165,250,0.45);';
  const titleStyle = 'font-weight:700; font-size:0.86rem; line-height:1.2; color:#eff6ff;';
  const subStyle   = 'font-size:0.74rem; line-height:1.3; opacity:0.85; color:#dbeafe; margin-top:2px;';
  const btnStyle   = 'padding:6px 14px; border-radius:999px; border:none; background:#2563eb; '
    + 'color:#fff; font-weight:700; font-size:0.8rem; line-height:1; cursor:pointer; white-space:nowrap;';
  const linkStyle  = 'background:none; border:none; color:#bfdbfe; font-size:0.74rem; '
    + 'text-decoration:underline; cursor:pointer; padding:4px 6px; white-space:nowrap;';

  function readyHtml() {
    return `
      <div style="${wrapStyle}" data-push-banner="ready">
        <div style="font-size:1.4rem; line-height:1;">🔔</div>
        <div style="flex:1 1 200px; min-width:0;">
          <div style="${titleStyle}">Get game reminders on this phone</div>
          <div style="${subStyle}">One tap. We'll ping you when a game or practice is posted and when it's time to say Go or No.</div>
        </div>
        <div style="display:flex; align-items:center; gap:4px;">
          <button type="button" data-push-enable style="${btnStyle}">Turn on</button>
          <button type="button" data-push-dismiss style="${linkStyle}">Not now</button>
        </div>
      </div>`;
  }

  function iosHtml() {
    return `
      <div style="${wrapStyle}" data-push-banner="ios-safari">
        <div style="font-size:1.4rem; line-height:1;">📲</div>
        <div style="flex:1 1 200px; min-width:0;">
          <div style="${titleStyle}">Add Football Home to your Home Screen to get game reminders</div>
          <div style="${subStyle}">In Safari: tap <strong>Share</strong> (the box with the arrow) → <strong>Add to Home Screen</strong> → open it from there and tap Turn on.</div>
        </div>
        <button type="button" data-push-dismiss style="${linkStyle}">Got it</button>
      </div>`;
  }

  function doneHtml() {
    return `
      <div style="${wrapStyle}" data-push-banner="done">
        <div style="font-size:1.4rem; line-height:1;">✅</div>
        <div style="flex:1 1 200px; min-width:0;">
          <div style="${titleStyle}">Reminders are on for this phone</div>
        </div>
      </div>`;
  }

  // Fill `container` with the right banner for the current state, or
  // empty it. `onChange(state)` fires after a successful enable so the
  // host screen can refresh anything else that shows push status (the
  // #my pill). Safe to call again; it re-reads state every time.
  async function mount(container, auth, { onChange } = {}) {
    if (!container) return;
    container.innerHTML = '';
    if (dismissedNow()) return;
    const s = await state();
    if (s.status === 'ready')          container.innerHTML = readyHtml();
    else if (s.status === 'ios-safari') container.innerHTML = iosHtml();
    else return;   // subscribed / blocked / unsupported → nothing to show

    container.querySelector('[data-push-dismiss]')?.addEventListener('click', () => {
      dismiss();
      container.innerHTML = '';
    });
    const enableBtn = container.querySelector('[data-push-enable]');
    if (enableBtn) {
      enableBtn.addEventListener('click', async () => {
        enableBtn.disabled = true;
        enableBtn.textContent = 'Turning on…';
        try {
          const r = await enable(auth);
          if (r.status === 'subscribed') {
            container.innerHTML = doneHtml();
            setTimeout(() => { container.innerHTML = ''; }, 4000);
            if (typeof onChange === 'function') onChange(r);
          } else {
            // Denied at the prompt: nothing more we can do from here.
            container.innerHTML = '';
          }
        } catch (err) {
          console.error('[PushOptIn] enable failed:', err);
          enableBtn.disabled = false;
          enableBtn.textContent = 'Turn on';
        }
      });
    }
  }

  window.PushOptIn = { state, enable, mount, urlBase64ToUint8Array };
})();
