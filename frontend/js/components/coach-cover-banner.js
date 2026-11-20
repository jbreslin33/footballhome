// CoachCoverBanner — the 🆘 cover ask strip atop an event's page (mig 1640).
// Owner 11/20: coaches "should just see calendar every time like players
// but theirs is coach enhanced" — a cover ask's text lands on the event
// (the coach's own sign-in link), and this strip says who needs cover with
// ✋ I'll cover.  Coaches and admins only: the API answers 403 for anyone
// else and the strip stays empty.
//
//   GET  /api/coach-schedule/event/<fh_event_id>  { covers, past, me }
//   POST /api/coach-schedule/cover/<id>/take
//
// mount(body, screen): fills (or adds) a [data-cover-strip] at the top of
// the event body.  One fetch per event; the screen re-renders often.
// Words: message_templates kind coach_schedule (cover_banner_*).
(function () {
  const cache = new Map();   // fh_event_id → { covers, past, me } | null (not a coach) | Promise
  let wired = false;

  const t = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('coach_schedule', tier, tokens)) || fb;
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);

  function html(data) {
    if (!data || !data.covers || !data.covers.length) return '';
    const me = data.me || {};
    return data.covers.map(c => {
      let line;
      if (c.status === 'covered') line = t('cover_banner_done', { cover: c.cover, coach: c.coach }, `🔁 ${c.cover} is covering for ${c.coach}`);
      else if (c.coach_id === me.coach_id) line = t('cover_banner_mine', {}, '🆘 You asked for cover — waiting');
      else if (c.asked_me) line = t('cover_banner_ask', { coach: c.coach }, `🆘 ${c.coach} asked you to cover this`);
      else line = t('cover_banner_open', { coach: c.coach }, `🆘 ${c.coach} needs cover for this`);
      const canTake = c.status === 'open' && !data.past && me.coach_id && c.coach_id !== me.coach_id;
      const btn = canTake ? `<button type="button" data-cover-take="${c.id}" style="padding:7px 14px; border-radius:8px; border:none; background:#15803d; color:#fff; font-weight:800; cursor:pointer;">${esc(t('take_cover', {}, "✋ I'll cover"))}</button>` : '';
      return `<div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; padding:10px 12px; margin-bottom:10px; border-radius:10px;
        background:${c.status === 'covered' ? 'rgba(34,197,94,0.15)' : 'rgba(248,113,113,0.15)'}; border:1px solid ${c.status === 'covered' ? '#22c55e' : '#f87171'};">
        <b style="font-size:0.9rem;">${esc(line)}</b>${btn}</div>`;
    }).join('');
  }

  function paint(body, id) {
    const data = cache.get(id);
    let strip = body.querySelector('[data-cover-strip]');
    const inner = (data && !(data instanceof Promise)) ? html(data) : '';
    if (!inner) { if (strip) strip.remove(); return; }
    if (!strip) {
      strip = document.createElement('div');
      strip.setAttribute('data-cover-strip', '');
      body.insertBefore(strip, body.firstChild);
    }
    strip.innerHTML = inner;
  }

  async function load(auth, id) {
    try {
      const res = await auth.fetch(`/api/coach-schedule/event/${id}`);
      const data = res.ok ? await res.json() : null;
      if (data) data._at = Date.now();
      cache.set(id, data);
    } catch (e) {
      cache.set(id, null);
    }
  }

  function mount(body, screen) {
    const ev = screen && screen.ev;
    if (!body || !ev || !ev.fh_event_id || !screen.auth) return;
    const id = Number(ev.fh_event_id);
    if (!wired) {   // one delegated listener for every event screen
      wired = true;
      document.addEventListener('click', async (e) => {
        const b = e.target.closest && e.target.closest('[data-cover-take]');
        if (!b || b.disabled) return;
        const s = window.CoachCoverBanner._screen;
        if (!s || !s.ev) return;
        b.disabled = true;
        b.textContent = '…';
        try {
          const res = await s.auth.fetch(`/api/coach-schedule/cover/${b.dataset.coverTake}/take`, { method: 'POST' });
          const out = await res.json().catch(() => ({}));
          if (!res.ok) throw new Error(out.error || `HTTP ${res.status}`);
          cache.delete(Number(s.ev.fh_event_id));
          // Now a coach on it: reload the event so their coach view opens.
          if (typeof s._loadEvent === 'function') s._loadEvent(Number(s.ev.fh_event_id));
          else mount(s.find('#ec-body'), s);
        } catch (err) {
          b.disabled = false;
          b.textContent = err.message;
        }
      });
    }
    window.CoachCoverBanner._screen = screen;
    const had = cache.get(id);   // a minute old → ask again (someone may have taken it)
    if (had && !(had instanceof Promise) && Date.now() - had._at > 60000) cache.delete(id);
    if (!cache.has(id)) {
      const p = load(screen.auth, id).then(() => paint(screen.find('#ec-body') || body, id));
      cache.set(id, p);
      return;
    }
    paint(body, id);
  }

  window.CoachCoverBanner = { mount, _screen: null };
})();
