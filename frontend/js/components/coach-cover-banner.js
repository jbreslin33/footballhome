// CoachCoverBanner — the coach strip atop an event's page (migs 1640/1643).
// Owner 11/20: coaches "should just see calendar every time like players
// but theirs is coach enhanced" · "the coaches can request sub from their
// cal".  On an event:
//   🆘 who needs cover / 🔁 who covers, with ✋ I'll cover for other coaches;
//   🙋 Ask for a sub for a coach on it: pick coaches → Ask → one 💬 text
//   each (their own sign-in link landing on this event, built server-side;
//   the sms: href opens Messages on iPhone + Android) → Cancel ask.
// Coaches and admins only: the API answers 403 for anyone else.
//
//   GET  /api/coach-schedule/event/<fh_event_id>  { covers, past, me, me_on, coaches }
//   POST /api/coach-schedule/cover                { fh_event_id, ask }
//   POST /api/coach-schedule/cover/<id>/take | withdraw | text (→ sms_href)
//
// mount(body, screen): fills (or adds) a [data-cover-strip] at the top of
// the event body.  Words: message_templates kind coach_schedule.
(function () {
  const cache = new Map();   // fh_event_id → data | null (not a coach) | Promise
  const picking = new Map(); // fh_event_id → Set(coach_id) while choosing who to ask
  let wired = false;

  const t = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('coach_schedule', tier, tokens)) || fb;
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);
  const btn = (attr, label, bg, color = '#fff') =>
    `<button type="button" ${attr} style="padding:7px 12px; border-radius:8px; border:none; background:${bg}; color:${color}; font-weight:800; font-size:0.8rem; cursor:pointer;">${esc(label)}</button>`;
  const box = (tone, inner) => {
    const [bg, bd] = { red: ['rgba(248,113,113,0.15)', '#f87171'], green: ['rgba(34,197,94,0.15)', '#22c55e'], gold: ['rgba(250,204,21,0.12)', '#facc15'] }[tone];
    return `<div style="padding:10px 12px; margin-bottom:10px; border-radius:10px; background:${bg}; border:1px solid ${bd};">${inner}</div>`;
  };

  function html(id, data) {
    if (!data) return '';
    const me = data.me || {};
    const live = !data.past;
    let out = (data.covers || []).map(c => {
      const mine = c.coach_id === me.coach_id;
      let line;
      if (c.status === 'covered') line = t('cover_banner_done', { cover: c.cover, coach: c.coach }, `🔁 ${c.cover} is covering for ${c.coach}`);
      else if (mine) line = t('cover_banner_mine', {}, '🆘 You asked for cover — waiting');
      else if (c.asked_me) line = t('cover_banner_ask', { coach: c.coach }, `🆘 ${c.coach} asked you to cover this`);
      else line = t('cover_banner_open', { coach: c.coach }, `🆘 ${c.coach} needs cover for this`);
      let actions = '';
      if (live && c.status === 'open' && me.coach_id && !mine) actions += btn(`data-cover-take="${c.id}"`, t('take_cover', {}, "✋ I'll cover"), '#15803d');
      if (live && c.status === 'open' && (mine || me.is_admin)) {
        actions += (c.asked || []).map(a => btn(`data-cover-text="${c.id}" data-coach="${a.coach_id}"`,
          `${t('ask_text', { first: a.first }, `💬 Text ${a.first}`)}${a.texted ? ' ✓' : ''}`, '#1d4ed8')).join('');
      }
      if (live && (mine || me.is_admin)) actions += btn(`data-cover-withdraw="${c.id}"`, t('withdraw', {}, 'Cancel ask'), '#475569');
      return box(c.status === 'covered' ? 'green' : 'red', `<b style="font-size:0.9rem;">${esc(line)}</b>
        ${actions ? `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:8px;">${actions}</div>` : ''}`);
    }).join('');
    // 🙋 Ask for a sub — a coach on it with no ask of their own yet.
    const ownAsk = (data.covers || []).some(c => c.coach_id === me.coach_id);
    if (live && data.me_on && !ownAsk) {
      const picked = picking.get(id);
      if (!picked) out += `<div style="margin-bottom:10px;">${btn('data-cover-ask-open', t('ask_sub', {}, '🙋 Ask for a sub'), '#a16207')}</div>`;
      else {
        const chips = (data.coaches || []).map(c => {
          const on = picked.has(c.coach_id);
          return `<button type="button" data-cover-pick="${c.coach_id}" ${c.has_phone ? '' : 'disabled title="No phone on file"'}
            style="padding:5px 9px; border-radius:8px; font-size:0.78rem; font-weight:700; cursor:pointer; opacity:${c.has_phone ? 1 : 0.4};
                   border:1px solid ${on ? '#22c55e' : 'rgba(255,255,255,0.25)'}; background:${on ? '#15803d' : 'transparent'}; color:${on ? '#fff' : 'inherit'};">${esc(c.name)}</button>`;
        }).join(' ');
        out += box('gold', `<b style="font-size:0.88rem;">${esc(t('ask_sub_title', {}, 'Who could sub for you? Pick, then Ask.'))}</b>
          <div style="display:flex; gap:4px; flex-wrap:wrap; margin:8px 0;">${chips}</div>
          <div style="display:flex; gap:6px;">${btn(`data-cover-ask-send ${picked.size ? '' : 'disabled'}`, t('ask_send', {}, 'Ask them'), picked.size ? '#facc15' : '#475569', '#111827')}
          ${btn('data-cover-ask-close', '✕', '#475569')}</div>`);
      }
    }
    return out;
  }

  function paint(body, id) {
    const data = cache.get(id);
    let strip = body.querySelector('[data-cover-strip]');
    const inner = (data && !(data instanceof Promise)) ? html(id, data) : '';
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

  async function post(auth, url, body) {
    const res = await auth.fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body || {}) });
    const out = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(out.error || `HTTP ${res.status}`);
    return out;
  }

  function wire() {
    if (wired) return;
    wired = true;
    document.addEventListener('click', async (e) => {
      const b = e.target.closest && e.target.closest('[data-cover-strip] button');
      if (!b || b.disabled) return;
      const s = window.CoachCoverBanner._screen;
      if (!s || !s.ev) return;
      const id = Number(s.ev.fh_event_id);
      const body = () => s.find('#ec-body');
      const refresh = async (reloadEvent) => {
        cache.delete(id);
        if (reloadEvent && typeof s._loadEvent === 'function') { s._loadEvent(id); return; }
        await load(s.auth, id);
        paint(body(), id);
      };
      const d = b.dataset;
      try {
        if ('coverAskOpen' in d) { picking.set(id, new Set()); paint(body(), id); return; }
        if ('coverAskClose' in d) { picking.delete(id); paint(body(), id); return; }
        if ('coverPick' in d) {
          const set = picking.get(id); const c = Number(d.coverPick);
          if (set) { if (set.has(c)) set.delete(c); else set.add(c); }
          paint(body(), id); return;
        }
        b.disabled = true;
        if ('coverAskSend' in d) {
          await post(s.auth, '/api/coach-schedule/cover', { fh_event_id: id, ask: [...(picking.get(id) || [])] });
          picking.delete(id);
          await refresh(false);   // now a 💬 per asked coach
          return;
        }
        if ('coverText' in d) {
          const r = await post(s.auth, `/api/coach-schedule/cover/${d.coverText}/text`, { coach_id: Number(d.coach) });
          if (!r.sms_href) throw new Error('No text came back');
          if (window.DesktopSms && DesktopSms.isDesktop && DesktopSms.isDesktop()) DesktopSms.open(r.sms_href);
          else window.location.href = r.sms_href;
          setTimeout(() => refresh(false), 1500);   // ✓ on that coach
          return;
        }
        if ('coverTake' in d) { await post(s.auth, `/api/coach-schedule/cover/${d.coverTake}/take`); await refresh(true); return; }
        if ('coverWithdraw' in d) { await post(s.auth, `/api/coach-schedule/cover/${d.coverWithdraw}/withdraw`); await refresh(true); return; }
      } catch (err) {
        b.disabled = false;
        b.textContent = err.message;
      }
    });
  }

  function mount(body, screen) {
    const ev = screen && screen.ev;
    if (!body || !ev || !ev.fh_event_id || !screen.auth) return;
    const id = Number(ev.fh_event_id);
    wire();
    window.CoachCoverBanner._screen = screen;
    const had = cache.get(id);   // a minute old → ask again (someone may have taken it)
    if (had && !(had instanceof Promise) && Date.now() - had._at > 60000) cache.delete(id);
    if (!cache.has(id)) {
      cache.set(id, load(screen.auth, id).then(() => paint(screen.find('#ec-body') || body, id)));
      return;
    }
    paint(body, id);
  }

  window.CoachCoverBanner = { mount, _screen: null };
})();
