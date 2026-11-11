// PlayerSheet — the ONE thing a player card opens, on every screen (owner
// 2026-11-11: "one button to bring up rest of player that is consistent" /
// "consistent sections by pill or tab … or we will be confused when
// entering it from screen to screen" / it replaces going into a separate
// player screen).
//
// Fixed tabs in a fixed order, always all of them:
//   👤 Person · 📇 Contact · ⚽ Teams · 🩹 Health · 💳 Money · ⚖️ Fines · 📅 Activity
// A tab never disappears — when it has nothing for this player it says so
// in place.  The screen it is opened from only picks the starting tab.
//
// Each tab = a CORE part the sheet draws itself, the same everywhere
// (identity + full profile, email/phone, team pills, the health control,
// the standing line), plus EXTRA html the opening screen adds from data it
// already holds (#payments: the dues hero, due date, LA / flag buttons, the
// fines boxes, dispute Approve / Deny).
//
//   PlayerSheet.button(key, { tab, flagged })   → the card's ⋯ button html
//   PlayerSheet.open({
//     host,        the screen element: the sheet mounts inside it so the
//                  screen's delegated click / change handlers keep working
//     auth,
//     resolve,     () → person { personId, laUserId, firstName, lastName,
//                  dob, email, phone } or null — re-run on refresh, so the
//                  sheet always shows the screen's latest row
//     tab,         starting tab key
//     extras,      (person) → { <tab>: html | { html, flag } }
//     onChange,    (what) after the sheet itself saved something ('health')
//   })
//   PlayerSheet.refresh()   the screen re-rendered — redraw from resolve()
//   PlayerSheet.close()
//   PlayerSheet.loadHealth(auth) / injuryFor(personId) — shared health data
//
// Words: message_templates kind 'player_sheet' (mig 1235); health words
// kind 'health' (mig 510).  Health saves: PUT /api/person-health, the same
// call the #teams control makes.
(function () {
  const TABS = ['person', 'contact', 'teams', 'health', 'money', 'fines', 'activity'];
  const TAB_FALLBACK = {
    person: '👤 Person', contact: '📇 Contact', teams: '⚽ Teams', health: '🩹 Health',
    money: '💳 Money', fines: '⚖️ Fines', activity: '📅 Activity',
  };
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const t = (tier, tokens, fb) =>
    (window.MessageCopy && MessageCopy.has && MessageCopy.has('player_sheet', tier))
      ? MessageCopy.block('player_sheet', tier, tokens || {}) : fb;
  const empty = (tier, fb) => `<div style="opacity:0.6; font-style:italic; padding:6px 0;">${esc(t(tier, {}, fb))}</div>`;

  // ── Health data, shared with any screen that groups by injury ──────
  const HEALTH = { statuses: [], copy: {}, people: {}, loaded: false };
  let healthPromise = null, healthAt = 0;
  // Re-read after a minute: an injury set on #teams, or one whose back-on
  // day arrived, shows on the next screen load.
  function loadHealth(auth, force) {
    if (healthPromise && !force && Date.now() - healthAt < 60000) return healthPromise;
    healthAt = Date.now();
    healthPromise = (async () => {
      try {
        const res = await auth.fetch('/api/person-health');
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const body = await res.json();
        HEALTH.statuses = Array.isArray(body && body.statuses) ? body.statuses : [];
        HEALTH.copy = (body && body.copy) || {};
        HEALTH.people = (body && body.people) || {};
        HEALTH.loaded = true;
      } catch (err) {
        console.warn('PlayerSheet: health unavailable', err);
      }
      return HEALTH;
    })();
    return healthPromise;
  }
  // The person's current injury { code, since, until, label } or null.
  function injuryFor(personId) {
    const mine = personId ? HEALTH.people[personId] : null;
    if (!mine) return null;
    const st = HEALTH.statuses.find(s => s.code === mine.code);
    return st && st.isInjured ? { ...mine, status: st } : null;
  }

  let state = null;   // { opts, tab, el }

  function button(key, opts = {}) {
    return `<button type="button" data-player-sheet="${esc(key)}"${opts.tab ? ` data-sheet-tab="${esc(opts.tab)}"` : ''}
      title="${esc(t('button_title', {}, 'Everything for this player'))}"
      style="min-width:34px; padding:2px 10px; border-radius:6px; cursor:pointer; font-size:1.05rem; font-weight:900; line-height:1.2;
             background:${opts.flagged ? '#c026d3' : '#334155'}; color:#fff; border:1px solid ${opts.flagged ? '#e879f9' : '#475569'};">⋯</button>`;
  }

  function clubDay(plusDays) {
    const today = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/New_York' }).format(new Date());
    const d = new Date(`${today}T12:00:00Z`);
    d.setUTCDate(d.getUTCDate() + (plusDays || 0));
    return d.toISOString().slice(0, 10);
  }

  // ── Core parts (the same on every screen) ──────────────────────────
  function core(tab, p) {
    const pid = p.personId;
    switch (tab) {
      case 'person': {
        const profile = window.PersonActions
          ? PersonActions.buttonsHtml({ personId: pid, leagueAppsUserId: p.laUserId, firstName: p.firstName,
              fullName: `${p.firstName || ''} ${p.lastName || ''}`.trim() }, { returnTo: p.returnTo || '', size: 'md' })
          : '';
        return `<div style="display:flex; flex-direction:column; gap:6px;">
          ${p.dob ? `<div>🎂 ${esc(p.dob)}</div>` : ''}
          ${profile ? `<div style="display:flex; gap:6px; flex-wrap:wrap;">${profile}</div>` : ''}
        </div>`;
      }
      case 'contact': {
        const bits = [];
        if (p.email) bits.push(`<div>✉️ <a href="mailto:${esc(p.email)}" style="color:#93c5fd;">${esc(p.email)}</a></div>`);
        if (p.phone) bits.push(`<div>📱 <a href="tel:${esc(p.phone)}" style="color:#93c5fd;">${esc(p.phoneLabel || p.phone)}</a></div>`);
        return bits.length ? `<div style="display:flex; flex-direction:column; gap:4px;">${bits.join('')}</div>` : '';
      }
      case 'teams':
        return pid && window.PersonStanding ? (PersonStanding.rosterHtml(pid) || '') : '';
      case 'health':
        return healthHtml(p);
      case 'money':
      case 'activity':
        return pid && window.PersonStanding ? (PersonStanding.html(pid) || '') : '';
      default:
        return '';
    }
  }

  function healthHtml(p) {
    if (!p.personId || !HEALTH.statuses.length) return '';
    const mine = HEALTH.people[p.personId] || null;
    const current = mine ? mine.code : ((HEALTH.statuses.find(s => !s.isInjured) || {}).code || '');
    const opts = HEALTH.statuses.map(s =>
      `<option value="${esc(s.code)}" ${current === s.code ? 'selected' : ''}>${esc((s.icon ? s.icon + ' ' : '') + s.displayName)}</option>`).join('');
    const field = (cls, label, value, bounds) => `
      <label class="ps-health-dates" style="display:${mine ? 'flex' : 'none'}; flex-direction:column; gap:2px; font-size:0.75rem; font-weight:700; opacity:0.85;">
        ${esc(label || '')}
        <input type="date" class="${cls}" value="${esc(value || '')}" ${bounds}
               style="padding:4px 6px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff; color-scheme:dark;">
      </label>`;
    return `<div class="ps-health" style="display:flex; flex-direction:column; gap:8px;">
      ${mine && mine.label ? `<div style="font-weight:700;">${esc(mine.label)}</div>` : ''}
      <select class="ps-health-select" title="${esc(HEALTH.copy.select_title || '')}"
              style="padding:6px 8px; border-radius:6px; border:1px solid #475569; background:#0f172a; color:#fff; font-weight:700; max-width:280px;">${opts}</select>
      <div style="display:flex; gap:12px; flex-wrap:wrap;">
        ${field('ps-health-since', HEALTH.copy.since_label || 'Injured since', mine && mine.since, `max="${clubDay(0)}"`)}
        ${field('ps-health-until', HEALTH.copy.until_label || 'Back on', mine && mine.until, `min="${clubDay(1)}"`)}
      </div>
    </div>`;
  }

  async function saveHealth(root) {
    const p = state && state.person;
    if (!p || !p.personId) return;
    const code = root.querySelector('.ps-health-select').value;
    const status = HEALTH.statuses.find(s => s.code === code);
    if (!status) return;
    // Picking an injury reveals the dates first; the save waits for none —
    // empty since = starts now, empty back-on = open-ended.
    root.querySelectorAll('.ps-health-dates').forEach(l => { l.style.display = status.isInjured ? 'flex' : 'none'; });
    const body = { person_id: p.personId, status: status.code };
    if (status.isInjured) {
      const since = root.querySelector('.ps-health-since').value;
      const until = root.querySelector('.ps-health-until').value;
      if (since) body.since = since;
      if (until) body.until = until;
    }
    root.querySelectorAll('select, input').forEach(el => { el.disabled = true; });
    try {
      const res = await state.opts.auth.fetch('/api/person-health', {
        method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      if (data.health) HEALTH.people[p.personId] = data.health; else delete HEALTH.people[p.personId];
      toast(t('health_saved', {}, 'Health saved.'));
      if (state.opts.onChange) state.opts.onChange('health');
    } catch (err) {
      toast(`Could not save: ${err.message}`, true);
    }
    draw();
  }

  function toast(msg, bad) {
    if (!state || !state.el) return;
    const n = document.createElement('div');
    n.textContent = msg;
    n.style.cssText = `position:absolute; left:50%; bottom:18px; transform:translateX(-50%); padding:8px 14px; border-radius:6px; font-weight:700; font-size:0.85rem; z-index:2;
                       background:${bad ? '#7f1d1d' : '#14532d'}; color:#fff;`;
    state.el.querySelector('.ps-panel').appendChild(n);
    setTimeout(() => n.remove(), 2200);
  }

  // ── Drawing ─────────────────────────────────────────────────────────
  function draw() {
    if (!state) return;
    const p = state.opts.resolve ? state.opts.resolve() : null;
    if (!p) { close(); return; }
    state.person = p;
    const extras = (state.opts.extras && state.opts.extras(p)) || {};
    const part = (k) => {
      const x = extras[k];
      return x == null ? { html: '', flag: false } : (typeof x === 'string' ? { html: x, flag: false } : { html: x.html || '', flag: !!x.flag });
    };
    const tabBtns = TABS.map((k) => {
      const on = k === state.tab;
      const flag = part(k).flag;
      return `<button type="button" data-ps-tab="${k}"
        style="flex:0 0 auto; padding:6px 12px; border-radius:999px; cursor:pointer; font-weight:800; font-size:0.82rem; white-space:nowrap; position:relative;
               background:${on ? '#0ea5e9' : 'transparent'}; color:${on ? '#fff' : '#e5e7eb'}; border:1px solid ${on ? '#0ea5e9' : '#374151'};">
        ${esc(t(`tab_${k}`, {}, TAB_FALLBACK[k]))}${flag ? '<span style="position:absolute; top:-3px; right:-3px; width:10px; height:10px; border-radius:50%; background:#e879f9;"></span>' : ''}
      </button>`;
    }).join('');
    const coreHtml = core(state.tab, p);
    const extraHtml = part(state.tab).html;
    const EMPTY = {
      person: null, health: null,
      contact: ['empty_contact', 'No email or phone on file.'], teams: ['empty_teams', 'Not on a team.'],
      money: ['empty_money', 'No dues on record.'], fines: ['empty_fines', 'No fines.'],
      activity: ['empty_activity', 'No RSVP or attendance on record.'],
    };
    const body = (coreHtml || extraHtml)
      ? `${coreHtml}${coreHtml && extraHtml ? '<div style="height:10px;"></div>' : ''}${extraHtml}`
      : (EMPTY[state.tab] ? empty(EMPTY[state.tab][0], EMPTY[state.tab][1]) : '');
    const name = `${p.firstName || ''} ${p.lastName || ''}`.trim() || '—';
    state.el.querySelector('.ps-name').textContent = name;
    state.el.querySelector('.ps-tabs').innerHTML = tabBtns;
    const bodyEl = state.el.querySelector('.ps-body');
    const keepScroll = bodyEl.dataset.tab === state.tab ? bodyEl.scrollTop : 0;
    bodyEl.innerHTML = body;
    bodyEl.dataset.tab = state.tab;
    bodyEl.scrollTop = keepScroll;
    // Team pills / standing line arrive once PersonStanding has the person:
    // one load per person per opening, then one redraw.
    if (p.personId && window.PersonStanding && !state.standingAsked) {
      state.standingAsked = true;
      const pid = p.personId;
      PersonStanding.load(state.opts.auth, [pid]).then(() => {
        if (state && state.person && state.person.personId === pid) draw();
      });
    }
  }

  function open(opts) {
    close();
    const host = opts.host || document.body;
    const el = document.createElement('div');
    el.className = 'player-sheet';
    el.style.cssText = 'position:fixed; inset:0; z-index:9000; background:rgba(0,0,0,0.55); display:flex; justify-content:flex-end;';
    el.innerHTML = `
      <div class="ps-panel" style="position:relative; width:min(620px, 100%); height:100%; background:var(--bg-secondary, #111827);
                                   border-left:1px solid var(--border-color, #374151); display:flex; flex-direction:column; color:var(--fg, #e5e7eb);">
        <div style="display:flex; align-items:center; gap:10px; padding:14px 16px 8px;">
          <div class="ps-name" style="flex:1; font-weight:800; font-size:1.15rem;"></div>
          <button type="button" data-ps-close title="${esc(t('close', {}, 'Close (Esc)'))}"
                  style="background:transparent; color:#e5e7eb; border:1px solid #374151; border-radius:6px; padding:2px 10px; cursor:pointer; font-size:1rem;">✕</button>
        </div>
        <div class="ps-tabs" style="display:flex; gap:6px; flex-wrap:wrap; padding:4px 16px 10px; border-bottom:1px solid var(--border-color, #374151);"></div>
        <div class="ps-body" style="flex:1; overflow-y:auto; padding:14px 16px 60px; font-size:0.9rem;"></div>
      </div>`;
    el.addEventListener('click', (e) => {
      if (e.target === el || e.target.closest('[data-ps-close]')) { close(); return; }
      const tb = e.target.closest('[data-ps-tab]');
      if (tb) { state.tab = tb.getAttribute('data-ps-tab'); draw(); }
    });
    el.addEventListener('change', (e) => {
      const h = e.target.closest('.ps-health');
      if (h) saveHealth(h);
    });
    host.appendChild(el);
    state = { opts, tab: TABS.includes(opts.tab) ? opts.tab : 'person', el, person: null };
    document.addEventListener('keydown', onKey);
    if (opts.auth) loadHealth(opts.auth).then(() => { if (state && state.el === el) draw(); });
    draw();
  }

  function onKey(e) { if (e.key === 'Escape' && !document.getElementById('fh-contact-popup')) close(); }

  function close() {
    document.removeEventListener('keydown', onKey);
    if (state && state.el) state.el.remove();
    state = null;
  }

  function refresh() { if (state) draw(); }
  function isOpen() { return !!state; }

  window.PlayerSheet = { TABS, button, open, close, refresh, isOpen, loadHealth, injuryFor, HEALTH };
})();
