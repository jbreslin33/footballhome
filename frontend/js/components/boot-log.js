// BootLog — a screen's loading shown like a Linux boot (mig 1300).
//
// Owner 2026-11-12: "i need a 'loading' and a bar or something to come up
// when loading event center and an event. its just blank while loading. i
// always like idea of showing process in screen like a linux boot".
//
// Every screen gets it with no code of its own: opening a screen
// (navigation.goTo → BootLog.begin) starts a boot, and every Auth.fetch
// started while that boot is running becomes a line:
//
//   ⏳ Loading Event Center · 2 of 3 · 66%   ▓▓▓▓▓▓▓░░░
//   [  OK  ] Calendar · events          120 ms
//   [  OK  ] Eligibility · lineup       340 ms
//   [ .... ] Matches
//
// A fetch fired later in the background (polls, gcal refresh after the
// boot is over) never shows.  The panel waits 250 ms before it appears (a
// fast screen never flickers it), ends with [  OK  ] Ready, and fades.  It
// floats over the top of the page and never takes a tap.
//
// Line names: message_templates kind 'boot_log', tier = the API path with
// ids dropped and '/' → '_' (/api/calendar/events/123 → calendar_events);
// a path with no row prints its segments ("Calendar · events").  Screen
// names: tier 'screen_<name>'; the header lines: tiers title / ready / fail.
(function () {
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const copy = (tier, tokens, fb) =>
    (window.MessageCopy && MessageCopy.has && MessageCopy.has('boot_log', tier) && MessageCopy.block('boot_log', tier, tokens || {})) || fb;

  const SHOW_AFTER = 250;    // ms before the panel appears
  const GRACE = 1500;        // ms after begin() a fetch still joins the boot
  const FADE_AFTER = 500;    // ms the finished log stays up
  const MAX_LINES = 9;

  let boot = null;           // { id, screen, steps: [], started, shown, timer }
  let seq = 0;
  let el = null;

  function key(path) {
    const p = String(path || '').split('?')[0].replace(/^\/api\//, '');
    return p.split('/').filter(s => s && !/^\d+$/.test(s) && !/^[0-9a-f-]{16,}$/i.test(s)).join('_');
  }
  function label(path) {
    const k = key(path);
    const words = k.split('_').map(w => w.replace(/-/g, ' '));
    const fb = words.length ? words[0].charAt(0).toUpperCase() + words[0].slice(1) + (words.length > 1 ? ' · ' + words.slice(1).join(' · ') : '') : 'Data';
    return copy(k, {}, fb);
  }
  function screenName(state) {
    const fb = String(state || '').replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    return copy('screen_' + String(state || '').replace(/-/g, '_'), {}, fb);
  }

  function ensureEl() {
    if (el && document.body.contains(el)) return el;
    el = document.createElement('div');
    el.id = 'boot-log';
    el.setAttribute('role', 'status');
    el.setAttribute('aria-live', 'polite');
    el.style.cssText = 'position:fixed; top:8px; left:50%; transform:translateX(-50%); z-index:9999; width:min(560px, calc(100vw - 32px));'
      + ' background:rgba(3,7,18,0.94); border:1px solid #334155; border-radius:8px; padding:8px 10px; pointer-events:none;'
      + ' font:12px/1.45 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; color:#cbd5e1; box-shadow:0 6px 24px rgba(0,0,0,0.45);'
      + ' transition:opacity 0.3s; opacity:0; display:none;';
    document.body.appendChild(el);
    return el;
  }

  function paint() {
    if (!boot || !boot.shown) return;
    const box = ensureEl();
    const total = boot.steps.length;
    const done = boot.steps.filter(s => s.state !== 'run').length;
    const pct = total ? Math.round((done / total) * 100) : 0;
    const finished = boot.finished;
    const failed = boot.steps.some(s => s.state === 'fail');
    const name = screenName(boot.screen);
    const head = finished
      ? copy(failed ? 'fail' : 'ready', { screen: name }, failed ? `Loaded ${name} — something didn't load` : `${name} ready`)
      : copy('title', { screen: name, done: String(done), total: String(total), pct: String(pct) }, `⏳ Loading ${name} · ${done} of ${total} · ${pct}%`);
    const tag = (st) => st === 'ok' ? '<span style="color:#4ade80;">[  OK  ]</span>'
      : st === 'fail' ? '<span style="color:#f87171;">[ FAIL ]</span>'
      : '<span style="color:#fbbf24;">[ .... ]</span>';
    const lines = boot.steps.slice(-MAX_LINES).map(s =>
      `<div style="display:flex; gap:8px; white-space:nowrap; overflow:hidden;">${tag(s.state)}<span style="flex:1; overflow:hidden; text-overflow:ellipsis;">${esc(s.label)}</span>`
      + `<span style="opacity:0.55;">${s.ms != null ? `${s.ms} ms` : ''}</span></div>`).join('');
    const ready = finished ? `<div style="display:flex; gap:8px;">${tag(failed ? 'fail' : 'ok')}<span>${esc(head)}</span></div>` : '';
    box.innerHTML = `
      <div style="font-weight:700; color:#e2e8f0; margin-bottom:4px;">${esc(finished ? name : head)}</div>
      <div style="height:5px; border-radius:999px; background:rgba(148,163,184,0.2); overflow:hidden; margin-bottom:6px;">
        <div style="height:100%; width:${finished ? 100 : Math.max(pct, 5)}%; background:${failed ? '#f87171' : '#4ade80'}; transition:width 0.25s;"></div>
      </div>${lines}${ready}`;
    box.style.display = 'block';
    requestAnimationFrame(() => { box.style.opacity = '1'; });
  }

  function hide() {
    if (!el) return;
    el.style.opacity = '0';
    setTimeout(() => { if (el && (!boot || !boot.shown)) el.style.display = 'none'; }, 320);
  }

  function maybeFinish(b) {
    if (boot !== b || b.finished) return;
    if (b.steps.some(s => s.state === 'run')) return;
    if (Date.now() - b.started < 200) { setTimeout(() => maybeFinish(b), 200); return; }   // a screen's 2nd wave of fetches
    b.finished = true;
    clearTimeout(b.timer);
    if (!b.shown) { boot = null; return; }
    paint();
    setTimeout(() => { if (boot === b) { boot = null; hide(); } }, FADE_AFTER);
  }

  // A screen is opening: start a boot (replaces one still running).
  function begin(state) {
    // Opening an event fetches it first, then navigates: the screen it
    // lands on carries on the same boot under its own name.
    if (boot && !boot.finished && boot.steps.some(s => s.state === 'run')) { boot.screen = state; boot.started = Date.now(); paint(); return; }
    if (boot && boot.timer) clearTimeout(boot.timer);
    const b = { id: ++seq, screen: state, steps: [], started: Date.now(), shown: false, finished: false, timer: null };
    boot = b;
    if (el) { el.style.opacity = '0'; el.style.display = 'none'; }
    b.timer = setTimeout(() => { if (boot === b && !b.finished && b.steps.some(s => s.state === 'run')) { b.shown = true; paint(); } }, SHOW_AFTER);
    // Nothing fetched at all (a screen drawn from memory): end quietly.
    setTimeout(() => { if (boot === b && !b.steps.length) { b.finished = true; boot = null; } }, GRACE);
  }

  // Wrap one fetch: a line in the running boot, if it joined in time.
  function track(path, promise) {
    const b = boot;
    if (!b || b.finished || Date.now() - b.started > GRACE && !b.steps.some(s => s.state === 'run')) return promise;
    const step = { label: label(path), state: 'run', ms: null, t0: performance.now() };
    b.steps.push(step);
    paint();
    const end = (ok) => {
      step.state = ok ? 'ok' : 'fail';
      step.ms = Math.round(performance.now() - step.t0);
      paint();
      maybeFinish(b);
    };
    promise.then(res => end(!!(res && (res.ok || res.status === 304))), () => end(false));
    return promise;
  }

  // Every Auth.fetch goes through track (auth.js loads first).
  // (`class Auth` makes no window property — test the binding itself.)
  if (typeof Auth !== 'undefined' && Auth.prototype && Auth.prototype.fetch && !Auth.prototype.fetch._bootLog) {
    const orig = Auth.prototype.fetch;
    const wrapped = function (path, options) { return track(path, orig.call(this, path, options)); };
    wrapped._bootLog = true;
    Auth.prototype.fetch = wrapped;
  }

  window.BootLog = { begin, track };
})();
