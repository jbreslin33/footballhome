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
// boot is over) never shows.  The line waits 250 ms before it appears (a
// fast screen never flickers it), ends with "<screen> ready", and folds
// away.  Since 11/19 it is one thin line atop the page (see ensureEl), not
// a floating panel; it never takes a tap.
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
  const MAX_LINES = 9;       // steps shown inline on a wide screen

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

  // One thin line at the very top of the page (owner 11/19 "we need
  // something less intrusive then the linux loader … a thin line that
  // does not block anything like the view as and the reminders red bar …
  // on desktop it can show more if screen is wide").  It is the first row
  // of the sticky #top-banners stack, so it sits ABOVE the 🎭 view-as bar
  // and the status band instead of floating over them, and folds to 0 px
  // when the screen is ready.  Phone: the screen name + count + a fill.
  // Wide screens (≥ 900 px) add the steps inline: ✓ Calendar 120 ms · … Matches.
  const LINE = 18;           // px tall while loading
  function ensureEl() {
    if (el && document.body.contains(el)) return el;
    if (!document.getElementById('boot-log-style')) {
      const st = document.createElement('style');
      st.id = 'boot-log-style';
      st.textContent = '#boot-log .bl-steps { display:none; } @media (min-width: 900px) { #boot-log .bl-steps { display:flex; } }';
      document.head.appendChild(st);
    }
    el = document.createElement('div');
    el.id = 'boot-log';
    el.setAttribute('role', 'status');
    el.setAttribute('aria-live', 'polite');
    el.style.cssText = 'position:relative; height:0; overflow:hidden; pointer-events:none; background:#030712; color:#cbd5e1;'
      + ' font:11px/' + LINE + 'px ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; transition:height 0.2s;';
    const stack = document.getElementById('top-banners');
    if (stack) stack.insertBefore(el, stack.firstChild);
    else { el.style.position = 'fixed'; el.style.top = '0'; el.style.left = '0'; el.style.right = '0'; el.style.zIndex = '9999'; document.body.appendChild(el); }
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
      ? copy(failed ? 'fail' : 'ready', { screen: name }, failed ? `${name} loaded — something didn't load` : `${name} ready`)
      : copy('title', { screen: name, done: String(done), total: String(total), pct: String(pct) }, `⏳ Loading ${name} · ${done} of ${total} · ${pct}%`);
    const color = failed ? '#f87171' : '#4ade80';
    const tag = (st) => st === 'ok' ? '<span style="color:#4ade80;">✓</span>'
      : st === 'fail' ? '<span style="color:#f87171;">✗</span>'
      : '<span style="color:#fbbf24;">…</span>';
    const steps = boot.steps.slice(-MAX_LINES).map(s =>
      `<span style="white-space:nowrap;">${tag(s.state)} ${esc(s.label)}${s.ms != null ? `<span style="opacity:0.5;"> ${s.ms} ms</span>` : ''}</span>`).join('<span style="opacity:0.35;">·</span>');
    const w = finished ? 100 : Math.max(pct, 5);
    box.innerHTML = `
      <div style="position:absolute; left:0; bottom:0; height:2px; width:${w}%; background:${color}; transition:width 0.25s;"></div>
      <div style="display:flex; gap:14px; align-items:center; height:${LINE}px; padding:0 10px; white-space:nowrap; overflow:hidden;">
        <span style="flex:0 0 auto; font-weight:700; color:${finished ? color : '#e2e8f0'};">${esc(head)}</span>
        <span class="bl-steps" style="flex:1 1 auto; min-width:0; gap:8px; overflow:hidden; justify-content:flex-end; opacity:0.85;">${steps}</span>
      </div>`;
    box.style.height = LINE + 'px';
  }

  function hide() {
    if (!el) return;
    el.style.height = '0';
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
    if (el) el.style.height = '0';
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
