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
//   PlayerSheet.button(key, { tab, flagged, compact })   → the card's ⋯ button html
//                (compact = #teams-size cards)
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
//   PlayerSheet.page({ container, auth, person, tab, sections, onTab })
//                → the same tabs drawn inline: the full page #person
//                  (PersonScreen), its cards handed over per tab as nodes
//   PlayerSheet.openFull(person, tab) — the popup's ⤢ → #person/<id>/<tab>
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

  // ── ⚽ Teams pills (mig 1307) ──────────────────────────────────────
  // Owner 2026-11-13: "a move section that has pills for all the teams.
  // then if i click another team it asks do we want to move or add them"
  // / "have consistency between screens".  Drawn by the sheet itself, so
  // every screen that opens it (popup or #person page) gets the same
  // pills.  A lit pill = on that team.  Tap an unlit one → Move here (off
  // <team>) per team he is on / Add / Cancel; tap a lit one → Take off?
  // 🔒 = on the league's own list for that team — only the league takes
  // him off.  Greyed = a team this viewer doesn't coach.
  // GET/POST /api/person-teams (PersonTeamsController).
  const MOVES = { board: {}, asked: {}, ask: null, busy: false };
  function loadMoves(auth, pid, force) {
    if (!auth || !pid) return Promise.resolve(null);
    if (!force && MOVES.asked[pid]) return MOVES.asked[pid];
    MOVES.asked[pid] = (async () => {
      try {
        const res = await auth.fetch(`/api/person-teams?person_id=${encodeURIComponent(pid)}`);
        if (!res.ok) { MOVES.board[pid] = null; return null; }
        MOVES.board[pid] = await res.json();
      } catch (_e) { MOVES.board[pid] = null; }
      return MOVES.board[pid];
    })();
    return MOVES.asked[pid];
  }

  function movesHtml(p) {
    const pid = p && p.personId;
    const b = pid ? MOVES.board[pid] : null;
    if (!b || !Array.isArray(b.teams) || !b.teams.length) return '';
    const name = (p.firstName || '').trim() || t('teams_they', {}, 'them');
    const domains = [...new Set(b.teams.map(x => x.domain))];
    const pill = (x) => {
      const ask = MOVES.ask && MOVES.ask.pid === pid && MOVES.ask.teamId === x.teamId;
      const tip = !x.canManage ? t('teams_no_rights_tip', {}, "You don't run this team")
        : (x.on && x.locked) ? t('teams_locked_tip', {}, "On the league's list — only the league takes them off")
        : x.on ? t('teams_on_tip', { team: x.label }, `On ${x.label} — tap to take off`)
        : t('teams_off_tip', { team: x.label }, `Tap to move or add to ${x.label}`);
      const bg = x.on ? '#166534' : 'transparent';
      const border = ask ? '#38bdf8' : (x.on ? '#22c55e' : '#475569');
      return `<button type="button" data-ps-team="${x.teamId}" ${x.canManage && !MOVES.busy ? '' : 'disabled'} title="${esc(tip)}"
        style="padding:5px 11px; border-radius:999px; font-weight:800; font-size:0.8rem; white-space:nowrap; cursor:${x.canManage ? 'pointer' : 'default'};
               background:${bg}; color:${x.on ? '#fff' : '#cbd5e1'}; border:${ask ? 2 : 1}px ${x.on ? 'solid' : 'dashed'} ${border}; opacity:${x.canManage ? 1 : 0.45};">
        ${x.on && x.locked ? '🔒 ' : (x.on ? '✓ ' : '')}${esc(x.short || x.label)}</button>`;
    };
    const groups = domains.map(d => {
      const head = domains.length > 1
        ? `<div style="font-size:0.72rem; font-weight:800; opacity:0.7; text-transform:uppercase; letter-spacing:0.04em;">${esc(t(`teams_domain_${d}`, {}, d))}</div>` : '';
      return `${head}<div style="display:flex; flex-wrap:wrap; gap:6px;">${b.teams.filter(x => x.domain === d).map(pill).join('')}</div>`;
    }).join('');

    let askHtml = '';
    const target = MOVES.ask && MOVES.ask.pid === pid ? b.teams.find(x => x.teamId === MOVES.ask.teamId) : null;
    if (target) {
      const btn = (act, label, from, kind) => `<button type="button" data-ps-move-act="${act}"${from ? ` data-ps-move-from="${from}"` : ''} ${MOVES.busy ? 'disabled' : ''}
        style="padding:7px 12px; border-radius:6px; font-weight:800; font-size:0.82rem; cursor:pointer; text-align:left;
               ${kind === 'go' ? 'background:#0ea5e9; color:#fff; border:1px solid #0ea5e9;'
                 : kind === 'warn' ? 'background:#7f1d1d; color:#fff; border:1px solid #b91c1c;'
                 : 'background:transparent; color:#e5e7eb; border:1px solid #475569;'}">${esc(label)}</button>`;
      let q, btns;
      if (target.on) {
        q = t('teams_remove_ask', { name, team: target.label }, `Take ${name} off ${target.label}?`);
        btns = [btn('remove', t('teams_remove_yes', { team: target.label }, `Take off ${target.label}`), 0, 'warn')];
      } else {
        const current = b.teams.filter(x => x.on);
        const leavable = current.filter(x => x.canManage && !x.locked);
        q = t('teams_ask', { name, team: target.label }, `${name} → ${target.label}`);
        btns = leavable.map(x => btn('move', t('teams_move_from', { team: target.label, from: x.short || x.label }, `Move here (off ${x.short || x.label})`), x.teamId, 'go'));
        btns.push(btn('add', current.length
          ? t('teams_add_also', { team: target.label, teams: current.map(x => x.short || x.label).join(', ') }, `Add — stays on ${current.map(x => x.short || x.label).join(', ')} too`)
          : t('teams_add', { team: target.label }, `Add to ${target.label}`), 0, leavable.length ? '' : 'go'));
      }
      btns.push(btn('cancel', t('teams_cancel', {}, 'Cancel'), 0, ''));
      askHtml = `<div data-ps-move-ask style="margin-top:4px; padding:10px; border-radius:8px; border:1px solid #38bdf8; background:#0c1e3a; display:flex; flex-direction:column; gap:6px; align-items:flex-start;">
          <div style="font-weight:800;">${esc(q)}</div>${btns.join('')}</div>`;
    }
    return `<div data-ps-moves style="display:flex; flex-direction:column; gap:8px;">
        <div style="font-size:0.75rem; font-weight:800; opacity:0.75;">${esc(t('teams_heading', {}, 'Teams — tap to move, add or take off'))}</div>
        ${groups}${askHtml}</div>`;
  }

  // Click inside the pills / ask panel.  ctx: { auth, person, redraw,
  // say(msg, bad), onChange }.  Returns true when it was ours.
  function handleMovesClick(e, ctx) {
    const p = ctx.person;
    const pid = p && p.personId;
    if (!pid) return false;
    const pillBtn = e.target.closest('[data-ps-team]');
    if (pillBtn) {
      const teamId = Number(pillBtn.getAttribute('data-ps-team'));
      const same = MOVES.ask && MOVES.ask.pid === pid && MOVES.ask.teamId === teamId;
      MOVES.ask = same ? null : { pid, teamId };
      ctx.redraw();
      return true;
    }
    const act = e.target.closest('[data-ps-move-act]');
    if (!act) return false;
    const what = act.getAttribute('data-ps-move-act');
    const ask = MOVES.ask;
    if (what === 'cancel' || !ask || ask.pid !== pid) { MOVES.ask = null; ctx.redraw(); return true; }
    const b = MOVES.board[pid];
    const target = b && b.teams.find(x => x.teamId === ask.teamId);
    const fromId = Number(act.getAttribute('data-ps-move-from')) || 0;
    const from = fromId && b ? b.teams.find(x => x.teamId === fromId) : null;
    const body = { person_id: pid, team_id: ask.teamId, action: what };
    if (what === 'move') body.from_team_id = fromId;
    MOVES.busy = true;
    ctx.redraw();
    (async () => {
      try {
        const res = await ctx.auth.fetch('/api/person-teams', {
          method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
        MOVES.board[pid] = data;
        MOVES.asked[pid] = Promise.resolve(data);
        MOVES.ask = null;
        if (window.PersonStanding && PersonStanding.forget) {
          PersonStanding.forget(pid);
          PersonStanding.load(ctx.auth, [pid]).then(() => ctx.redraw());
        }
        const team = target ? target.label : '';
        const name = (p.firstName || '').trim();
        ctx.say(what === 'move' ? t('teams_moved', { name, team, from: from ? from.label : '' }, `Moved to ${team}.`)
          : what === 'add' ? t('teams_added', { name, team }, `Added to ${team}.`)
          : t('teams_removed', { name, team }, `Taken off ${team}.`));
        if (ctx.onChange) ctx.onChange('teams');
      } catch (err) {
        ctx.say(`${t('teams_failed', {}, 'Could not save')}: ${err.message}`, true);
      } finally {
        MOVES.busy = false;
        ctx.redraw();
      }
    })();
    return true;
  }

  let state = null;   // { opts, tab, el }

  function button(key, opts = {}) {
    return `<button type="button" data-player-sheet="${esc(key)}"${opts.tab ? ` data-sheet-tab="${esc(opts.tab)}"` : ''}
      title="${esc(t('button_title', {}, 'Everything for this player'))}"
      style="${opts.compact ? 'min-width:0; min-height:0; padding:0 7px; border-radius:3px; font-size:0.8rem; margin:0;' : 'min-width:34px; padding:2px 10px; border-radius:6px; font-size:1.05rem;'} cursor:pointer; font-weight:900; line-height:1.2;
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
      case 'teams': {
        const standing = pid && window.PersonStanding ? (PersonStanding.rosterHtml(pid) || '') : '';
        const moves = movesHtml(p);
        return `${standing}${standing && moves ? '<div style="height:10px;"></div>' : ''}${moves}`;
      }
      case 'health':
        return healthHtml(p);
      case 'money':
        return `${pid && window.PersonStanding ? (PersonStanding.html(pid) || '') : ''}${laButton(p)}`;
      case 'fines':
        return laButton(p);
      case 'activity':
        return pid && window.PersonStanding ? (PersonStanding.html(pid) || '') : '';
      default:
        return '';
    }
  }

  // 🔗 Open in LA — on 💳 Money and ⚖️ Fines on every screen (owner
  // 2026-11-11: fines tab "needs a button to access la right like in
  // tuitions"): dues and fines are both charged / run on LeagueApps.
  function laButton(p) {
    const url = window.PersonStanding && PersonStanding.laMemberUrl ? PersonStanding.laMemberUrl(p.laUserId) : '';
    if (!url) return '';
    return `<div style="display:flex; margin-top:8px;"><a href="${esc(url)}" target="_blank" rel="noopener" data-ps-la
        title="${esc(t('la_title', {}, 'Open in LeagueApps — run card, see tuition and fines charges'))}"
        style="padding:6px 10px; border-radius:4px; text-decoration:none; background:#1e3a8a; color:#dbeafe; border:1px solid #3b82f6; font-size:0.75rem; font-weight:700;">${esc(t('la_button', {}, '🔗 Open in LA'))}</a></div>`;
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

  // Save the health control in `root` for person p.  Shared by the popup
  // and the full page (#person): `after()` redraws whichever is showing.
  async function saveHealthFor(root, auth, p, after, say) {
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
      const res = await auth.fetch('/api/person-health', {
        method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      if (data.health) HEALTH.people[p.personId] = data.health; else delete HEALTH.people[p.personId];
      say(t('health_saved', {}, 'Health saved.'));
      after(true);
    } catch (err) {
      say(`Could not save: ${err.message}`, true);
      after(false);
    }
  }

  function saveHealth(root) {
    if (!state || !state.person) return;
    const opts = state.opts;
    saveHealthFor(root, opts.auth, state.person, (ok) => {
      if (ok && opts.onChange) opts.onChange('health');
      draw();
    }, toast);
  }

  function toastIn(panel, msg, bad) {
    if (!panel) return;
    const n = document.createElement('div');
    n.textContent = msg;
    n.style.cssText = `position:${panel === document.body ? 'fixed' : 'absolute'}; left:50%; bottom:18px; transform:translateX(-50%); padding:8px 14px; border-radius:6px; font-weight:700; font-size:0.85rem; z-index:9001;
                       background:${bad ? '#7f1d1d' : '#14532d'}; color:#fff;`;
    panel.appendChild(n);
    setTimeout(() => n.remove(), 2200);
  }

  function toast(msg, bad) {
    if (state && state.el) toastIn(state.el.querySelector('.ps-panel'), msg, bad);
  }

  function tabLabel(k) { return t(`tab_${k}`, {}, TAB_FALLBACK[k]); }
  function tabButtons(active, flagOf) {
    return TABS.map((k) => {
      const on = k === active;
      const flag = flagOf ? flagOf(k) : false;
      return `<button type="button" data-ps-tab="${k}"
        style="flex:0 0 auto; padding:6px 12px; border-radius:999px; cursor:pointer; font-weight:800; font-size:0.82rem; white-space:nowrap; position:relative;
               background:${on ? '#0ea5e9' : 'transparent'}; color:${on ? '#fff' : '#e5e7eb'}; border:1px solid ${on ? '#0ea5e9' : '#374151'};">
        ${esc(tabLabel(k))}${flag ? '<span style="position:absolute; top:-3px; right:-3px; width:10px; height:10px; border-radius:50%; background:#e879f9;"></span>' : ''}
      </button>`;
    }).join('');
  }
  const EMPTY = {
    person: null, health: null,
    contact: ['empty_contact', 'No email or phone on file.'], teams: ['empty_teams', 'Not on a team.'],
    money: ['empty_money', 'No dues on record.'], fines: ['empty_fines', 'No fines.'],
    activity: ['empty_activity', 'No RSVP or attendance on record.'],
  };

  // ── Drawing ─────────────────────────────────────────────────────────
  function draw() {
    if (!state) return;
    const p = state.opts.resolve ? state.opts.resolve() : null;
    if (!p) { close(); return; }
    state.person = p;
    const extras = (state.opts.extras && state.opts.extras(p)) || {};
    const part = (k) => {
      const x = extras[k];
      return x == null ? { html: '', flag: false }
        : (typeof x === 'string' ? { html: x, flag: false } : { html: x.html || '', flag: !!x.flag });
    };
    const tabBtns = tabButtons(state.tab, (k) => part(k).flag);
    const coreHtml = core(state.tab, p);
    const extraHtml = part(state.tab).html;
    const body = (coreHtml || extraHtml)
      ? `${coreHtml}${coreHtml && extraHtml ? '<div style="height:10px;"></div>' : ''}${extraHtml}`
      : (EMPTY[state.tab] ? empty(EMPTY[state.tab][0], EMPTY[state.tab][1]) : '');
    const name = `${p.firstName || ''} ${p.lastName || ''}`.trim() || '—';
    state.el.querySelector('.ps-title').textContent = name;
    state.el.querySelector('.ps-tabs').innerHTML = tabBtns;
    const bodyEl = state.el.querySelector('.ps-body');
    const keepScroll = bodyEl.dataset.tab === state.tab ? bodyEl.scrollTop : 0;
    bodyEl.innerHTML = body;
    bodyEl.dataset.tab = state.tab;
    bodyEl.scrollTop = keepScroll;
    // Team pills / standing line arrive once PersonStanding has the person:
    // one load per person per opening, then one redraw.
    if (p.personId && !state.movesAsked) {
      state.movesAsked = true;
      const mpid = p.personId;
      loadMoves(state.opts.auth, mpid, true).then(() => {
        if (state && state.person && state.person.personId === mpid) draw();
      });
    }
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
    const hdrBtn = 'background:transparent; color:#e5e7eb; border:1px solid #374151; border-radius:6px; padding:2px 10px; cursor:pointer; font-size:1rem;';
    el.innerHTML = `
      <div class="ps-panel" style="position:relative; width:min(620px, 100%); height:100%; background:var(--bg-secondary, #111827);
                                   border-left:1px solid var(--border-color, #374151); display:flex; flex-direction:column; color:var(--fg, #e5e7eb);">
        <div style="display:flex; align-items:center; gap:10px; padding:14px 16px 8px;">
          <div class="ps-title" style="flex:1; font-weight:800; font-size:1.15rem;"></div>
          <button type="button" data-ps-full title="${esc(t('full_page', {}, 'Open as a full page'))}" style="${hdrBtn}">⤢</button>
          <button type="button" data-ps-close title="${esc(t('close', {}, 'Close (Esc)'))}" style="${hdrBtn}">✕</button>
        </div>
        <div class="ps-tabs" style="display:flex; gap:6px; flex-wrap:wrap; padding:4px 16px 10px; border-bottom:1px solid var(--border-color, #374151);"></div>
        <div class="ps-body" style="flex:1; overflow-y:auto; padding:14px 16px 60px; font-size:0.9rem;"></div>
      </div>`;
    el.addEventListener('click', (e) => {
      if (e.target === el || e.target.closest('[data-ps-close]')) { close(); return; }
      if (e.target.closest('[data-ps-full]')) { openFull(state.person, state.tab); return; }
      const tb = e.target.closest('[data-ps-tab]');
      if (tb) { state.tab = tb.getAttribute('data-ps-tab'); draw(); return; }
      if (state && handleMovesClick(e, { auth: state.opts.auth, person: state.person, redraw: draw, say: toast,
          onChange: state.opts.onChange })) e.stopPropagation();
    });
    el.addEventListener('change', (e) => {
      const h = e.target.closest('.ps-health');
      if (h) saveHealth(h);
    });
    host.appendChild(el);
    state = { opts, tab: TABS.includes(opts.tab) ? opts.tab : 'person', el, person: null };
    MOVES.ask = null;
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

  // ⤢ — the same sheet as the full page #person (PersonScreen draws it
  // with PlayerSheet.page).  Back returns to the screen it came from.
  function openFull(p, tab) {
    if (!p || (!p.personId && !p.laUserId)) return;
    const params = { tab: tab || 'person' };
    if (p.personId) { params.personId = String(p.personId); params.entity = `${p.personId}/${params.tab}`; }
    if (p.laUserId) params.leagueAppsUserId = String(p.laUserId);
    close();
    const nav = window.app && window.app.navigation;
    if (nav && typeof nav.goTo === 'function') nav.goTo('person', params);
    else window.location.hash = 'person?' + new URLSearchParams(params).toString();
  }

  // ── Full page (#person) ─────────────────────────────────────────────
  // The same tabs, same order, same core parts as the popup, drawn inline
  // in `container`.  The page hands over its own cards as DOM nodes per tab
  // (`sections`) — they move into the tab panes untouched, so the page's
  // handlers keep working.  Returns { setTab, refresh, tab }.
  //   PlayerSheet.page({ container, auth, person, tab, sections, onTab })
  function page(opts) {
    const c = opts.container;
    c.innerHTML = `
      <div class="ps-page-tabs" style="display:flex; gap:6px; flex-wrap:wrap; padding:4px 0 12px; margin-bottom:12px; border-bottom:1px solid var(--border-color, #374151);"></div>
      ${TABS.map(k => `<div class="ps-page-pane" data-ps-pane="${k}" style="display:none;">
        <div class="ps-page-core" style="font-size:0.9rem;"></div>
        <div class="ps-page-extra"></div>
        <div class="ps-page-empty"></div>
      </div>`).join('')}`;
    const ctl = { tab: TABS.includes(opts.tab) ? opts.tab : 'person', person: opts.person };
    const sections = opts.sections || {};
    TABS.forEach(k => {
      const extra = c.querySelector(`[data-ps-pane="${k}"] .ps-page-extra`);
      (sections[k] || []).filter(Boolean).forEach(node => extra.appendChild(node));
    });
    const visible = (node) => node && node.style.display !== 'none';
    function paint() {
      const p = ctl.person || {};
      c.querySelector('.ps-page-tabs').innerHTML = tabButtons(ctl.tab);
      TABS.forEach(k => {
        const pane = c.querySelector(`[data-ps-pane="${k}"]`);
        pane.style.display = k === ctl.tab ? 'block' : 'none';
        // The page's header card already is the identity — no self-link.
        const coreHtml = k === 'person' ? '' : core(k, p);
        const coreEl = pane.querySelector('.ps-page-core');
        coreEl.innerHTML = coreHtml;
        coreEl.style.marginBottom = coreHtml ? '14px' : '0';
        const hasExtra = Array.from(pane.querySelector('.ps-page-extra').children).some(visible);
        pane.querySelector('.ps-page-empty').innerHTML =
          (!coreHtml && !hasExtra && EMPTY[k]) ? empty(EMPTY[k][0], EMPTY[k][1]) : '';
      });
    }
    c.addEventListener('click', (e) => {
      const tb = e.target.closest('[data-ps-tab]');
      if (tb && c.contains(tb)) { ctl.setTab(tb.getAttribute('data-ps-tab')); return; }
      handleMovesClick(e, { auth: opts.auth, person: ctl.person, redraw: () => paint(),
        say: (m, bad) => toastIn(document.body, m, bad), onChange: opts.onChange });
    });
    c.addEventListener('change', (e) => {
      const h = e.target.closest('.ps-health');
      if (h) saveHealthFor(h, opts.auth, ctl.person, () => paint(), (m, bad) => toastIn(document.body, m, bad));
    });
    ctl.setTab = (k) => {
      if (!TABS.includes(k)) return;
      ctl.tab = k;
      paint();
      if (opts.onTab) opts.onTab(k);
    };
    // Team pills / standing line arrive once PersonStanding has the person.
    function standing() {
      const pid = ctl.person && ctl.person.personId;
      if (pid) loadMoves(opts.auth, pid, true).then(() => { if (ctl.person && ctl.person.personId === pid) paint(); });
      if (!pid || !window.PersonStanding) return;
      PersonStanding.load(opts.auth, [pid]).then(() => {
        if (ctl.person && ctl.person.personId === pid) paint();
      });
    }
    // The screen re-entered (same person or another): redraw + re-read.
    ctl.refresh = (p) => {
      if (p) ctl.person = p;
      paint();
      if (opts.auth) loadHealth(opts.auth).then(() => paint());
      standing();
    };
    paint();
    if (opts.auth) loadHealth(opts.auth).then(() => paint());
    standing();
    return ctl;
  }

  window.PlayerSheet = { TABS, button, open, close, refresh, isOpen, page, openFull, tabLabel, loadHealth, injuryFor, HEALTH };
})();
