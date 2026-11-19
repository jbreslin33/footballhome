// PersonStanding — the one line every player card carries: 👻 ghost /
// 🙈 no-show, the last RSVP and the dues standing (owner 2026-11-03:
// "need last rsvp on all cards so i know if a player is ghost lol and
// dues standing").
//
// Data: GET /api/payments/standing?person_ids=… (club admins; anyone else
// gets a 403 and simply no line) — the same RSVP / attendance trail the
// #payments cards read (PersonActivity) plus fh_dues_balance_usd and the
// free reason (volunteer / injured).  Ghost rule = #payments': heard from
// at least once, but no present/late mark and no yes RSVP in 30 days.
//
//   PersonStanding.load(auth, personIds) → Promise (cached ~2 min per id)
//   PersonStanding.html(personId)        → '' until loaded
//
// Words: message_templates kind 'person_standing' (mig 995).
(function () {
  const cache = new Map();      // person_id → { at, data }
  const TTL = 120000;
  let denied = false;
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const t = (tier, tokens, fb) =>
    (window.MessageCopy && MessageCopy.block && MessageCopy.block('person_standing', tier, tokens || {})) || fb;
  const md = (iso) => {
    if (!iso) return '';
    const d = new Date(iso);
    return isNaN(d) ? '' : `${d.getMonth() + 1}/${d.getDate()}`;
  };

  async function load(auth, ids) {
    if (denied || !auth) return;
    const now = Date.now();
    const want = [...new Set((ids || []).map(Number).filter(n => n > 0))]
      .filter(id => !cache.has(id) || now - cache.get(id).at > TTL);
    for (let i = 0; i < want.length; i += 300) {
      const chunk = want.slice(i, i + 300);
      try {
        const res = await auth.fetch(`/api/payments/standing?person_ids=${chunk.join(',')}`);
        if (res.status === 401 || res.status === 403) { denied = true; return; }
        if (!res.ok) return;
        const body = await res.json();
        const people = (body && body.people) || {};
        chunk.forEach(id => cache.set(id, { at: now, data: people[String(id)] || null }));
      } catch (_e) { return; }
    }
  }

  // His LeagueApps Manager member page — where staff run a card / see
  // tuition (owner 11/5: "run card from la … from anyone … universal on
  // all player cards").  The one place this URL is built; every dues pill
  // links through it.
  const LA_SITE_ID = 41983;
  function laMemberUrl(laUserId) {
    const uid = String(laUserId || '').replace(/\D/g, '');
    return uid ? `https://manager.leagueapps.com/console/sites/${LA_SITE_ID}/memberDetails?memberId=${uid}` : '';
  }
  // Wrap a pill so a tap opens his LA page in a new tab (no-op without an LA id).
  function laLink(pillHtml, laUserId) {
    const url = laMemberUrl(laUserId);
    if (!url) return pillHtml;
    return `<a href="${esc(url)}" target="_blank" rel="noopener" draggable="false" data-la-dues-link
       title="${esc(t('dues_la_tip', {}, 'Open in LeagueApps — run card, see tuition'))}"
       onclick="event.stopPropagation()" style="text-decoration:none; cursor:pointer;">${pillHtml}</a>`;
  }
  const laUserId = (personId) => {
    const hit = cache.get(Number(personId));
    return hit && hit.data ? hit.data.laUserId || null : null;
  };

  const pill = (text, title, bg, fg, border) =>
    `<span title="${esc(title)}" style="padding:0 6px; border-radius:999px; background:${bg}; color:${fg}; border:1px solid ${border}; font-weight:800; white-space:nowrap;">${esc(text)}</span>`;

  const inactivePill = () => pill(t('inactive', {}, '💤 INACTIVE'),
    t('inactive_tip', {}, 'Inactive — still billed monthly, no fines, no RSVP reminders'), '#1e293b', '#cbd5e1', '#64748b');

  // 📎 League form flags (mig 1540, owner 11/19: "if we see him … we flag
  // their card with label docs uploaded" → "once on offical apsl roster we
  // can take down flag").  Only leagues with a form sheet (APSL), only
  // while he is off every one of that league's official lists:
  //   in      filled the form (head shot + ID)
  //   missing on one of the league's teams, no form row
  // stale = the sheet's last read failed (⚠ + "as of" on the hover).
  function docFlags(personId) {
    const hit = cache.get(Number(personId));
    const regs = hit && hit.data && Array.isArray(hit.data.registrations) ? hit.data.registrations : [];
    return regs.filter(g => g && g.formSheet && !g.onList).map(g => ({
      league: g.league || '',
      state: g.registered && g.source === 'league_form' ? 'in' : (!g.registered && g.onLeagueTeam ? 'missing' : null),
      date: g.at || '',
      stale: g.formOk === false,
      formAt: g.formAt || '',
    })).filter(f => f.state);
  }
  function docTip(f) {
    const base = f.state === 'in'
      ? t('docs_in_tip', { league: f.league, date: f.date }, `Filled the ${f.league} registration form ${f.date}. Not on the ${f.league} official roster yet.`)
      : t('docs_missing_tip', { league: f.league }, `On a ${f.league} team, not on the official roster, no ${f.league} form.`);
    return f.stale ? `${base} ${t('docs_stale_tip', { league: f.league, date: f.formAt }, `Couldn't read the ${f.league} form sheet — as of ${f.formAt}.`)}` : base;
  }
  function docPill(f, small) {
    const text = (f.state === 'in'
      ? t('docs_in', { league: f.league, date: f.date }, `📎 ${f.league} docs uploaded ${f.date}`.trim())
      : t('docs_missing', { league: f.league }, `❌ ${f.league} docs`)) + (f.stale ? t('docs_stale', {}, ' ⚠') : '');
    const [bg, fg, border] = f.state === 'in' ? ['#0c1e3a', '#93c5fd', '#2563eb'] : ['#3b0a0a', '#fca5a5', '#dc2626'];
    const h = pill(text, docTip(f), bg, fg, border);
    return small ? h.replace('style="padding:0 6px;', 'style="font-size:0.6rem; line-height:1.3; padding:0 4px;') : h;
  }

  function html(personId) {
    const hit = cache.get(Number(personId));
    if (!hit || !hit.data) return '';
    const { activity: a, dues: d } = hit.data;
    const bits = [];
    // 💤 Inactive (mig 945): leads the line; ghost / no-show say nothing
    // about someone who isn't meant to come.
    if (hit.data.inactive) bits.push(inactivePill());
    docFlags(personId).forEach(f => bits.push(docPill(f)));

    if (a) {
      const days = a.windowDays || 30;
      const heard = a.lastRsvp || a.lastMarked;
      const ghost = heard && !(a.attended30 > 0) && !(a.rsvpYes30 > 0);
      const noShow = heard && !ghost && !(a.attended30 > 0) && (a.absent30 > 0);
      if (hit.data.inactive) { /* 💤 already says it */ }
      else if (ghost) bits.push(pill(t('ghost', {}, '👻 GHOST'), t('ghost_tip', { days }, `No present/late mark and no yes RSVP in the last ${days} days`), '#3a1f1f', '#fca5a5', '#b91c1c'));
      else if (noShow) bits.push(pill(t('no_show', {}, '🙈 NO-SHOW'), t('no_show_tip', { days }, `Says yes but only absent marks in the last ${days} days`), '#3a2e05', '#fbbf24', '#d97706'));
      const r = a.lastRsvp;
      if (r) {
        const icon = r.status === 'yes' ? '✅' : r.status === 'no' ? '❌' : '·';
        const what = [r.eventKind || '', r.opponent ? `v ${r.opponent}` : '', md(r.eventStartAt)].filter(Boolean).join(' ');
        bits.push(`<span title="${esc(t('last_rsvp_tip', { date: md(r.at) }, `Answered ${md(r.at)}`))}">${esc(t('last_rsvp', { icon, status: r.status, what }, `🗓 ${icon} ${what}`))}</span>`);
      } else {
        bits.push(`<span style="opacity:0.7;">${esc(t('no_rsvp', {}, '🗓 No RSVP ever'))}</span>`);
      }
    }

    if (d) {
      const duesAt = bits.length;
      if (d.free_reason === 'volunteer') bits.push(pill(t('dues_volunteer', {}, '🙋 Volunteer'), '', '#1e293b', '#cbd5e1', '#475569'));
      else if (d.free_reason === 'injured') bits.push(pill(t('dues_injured', {}, '🩹 No dues'), '', '#1e293b', '#cbd5e1', '#475569'));
      else if (!d.member) bits.push(pill(t('dues_no_membership', {}, '💰 No membership'), t('dues_no_membership_tip', {}, 'No live LeagueApps registration'), '#1f2937', '#9ca3af', '#4b5563'));
      else if (d.balance > 0) {
        const amount = `$${Math.round(d.balance)}`;
        bits.push(pill(t('dues_owes', { amount, months: d.months_behind }, `💰 Owes ${amount} · ${d.months_behind} mo`), '', d.months_behind >= 2 ? '#3a1f1f' : '#3a2e05', d.months_behind >= 2 ? '#fca5a5' : '#fbbf24', d.months_behind >= 2 ? '#b91c1c' : '#d97706'));
      } else bits.push(pill(t('dues_paid', {}, '💰 Paid up'), '', '#052e16', '#86efac', '#16a34a'));
      if (bits.length > duesAt) bits[duesAt] = laLink(bits[duesAt], hit.data.laUserId);
    }

    if (!bits.length) return '';
    return `<div data-person-standing style="font-size:0.68rem; display:flex; flex-wrap:wrap; gap:5px; align-items:center; margin-top:4px; opacity:0.95;">${bits.join('')}</div>`;
  }

  // The one-line #teams card's chip: 👻 / 🙈 when it applies, else the
  // last RSVP's date (dues already ride on that card).
  // opts.inactive = false on #teams' Roster pill (owner 11/3: "we don't do
  // inactive on roster page") — that view is league paperwork only.
  function chip(personId, opts = {}) {
    const showInactive = opts.inactive !== false;
    const small = (html) => html.replace('style="padding:0 6px;', 'style="font-size:0.6rem; line-height:1.3; padding:0 4px;');
    const hit = cache.get(Number(personId));
    if (!hit || !hit.data || !hit.data.activity) return '';
    const a = hit.data.activity;
    const days = a.windowDays || 30;
    const heard = a.lastRsvp || a.lastMarked;
    const ghost = heard && !(a.attended30 > 0) && !(a.rsvpYes30 > 0);
    const noShow = heard && !ghost && !(a.attended30 > 0) && (a.absent30 > 0);
    const last = a.lastRsvp ? md(a.lastRsvp.eventStartAt || a.lastRsvp.at) : '';
    const lastTxt = last ? t('chip_last', { date: last }, `last ${last}`) : t('chip_never', {}, 'no RSVP');
    const lastTip = a.lastRsvp ? t('last_rsvp_tip', { date: md(a.lastRsvp.at) }, `Last RSVP ${a.lastRsvp.status} · answered ${md(a.lastRsvp.at)}`) : t('no_rsvp', {}, '🗓 No RSVP ever');
    const flag = hit.data.inactive ? (showInactive ? small(inactivePill()) : '')
               : ghost ? pill(t('ghost', {}, '👻 GHOST'), t('ghost_tip', { days }, `No present/late mark and no yes RSVP in the last ${days} days`), '#3a1f1f', '#fca5a5', '#b91c1c')
               : noShow ? pill(t('no_show', {}, '🙈 NO-SHOW'), t('no_show_tip', { days }, `Says yes but only absent marks in the last ${days} days`), '#3a2e05', '#fbbf24', '#d97706') : '';
    // R:27 — every RSVP on record (owner 11/4), the number the boards rank by.
    const total = Number(hit.data.rsvpTotal) || 0;
    const rTxt = t('chip_rsvp_total', { n: total }, `R:${total}`);
    const rTip = t('chip_rsvp_total_tip', { n: total }, `${total} RSVPs on record — games and practices`);
    // 11/5: date at the chip text size, full opacity, no 🗓 (the emoji drew
    // over the first digit at this size — "no label partially hidden").
    const docs = docFlags(personId).map(f => docPill(f, true)).join('');
    return `${docs}${small(flag)}<span title="${esc(rTip)}" style="font-size:0.65rem; line-height:1.3; font-weight:800; white-space:nowrap;">${esc(rTxt)}</span>`
      + `<span title="${esc(lastTip)}" style="font-size:0.65rem; line-height:1.3; font-weight:700; white-space:nowrap;">${esc(lastTxt)}</span>`;
  }

  // Tuition card roster pills (mig 1221, owner 11/10: "show their status,
  // active, inactive, what official rosters they are on. like APSL Active,
  // APSL Inactive, APSL OFFICIAL, LIGA 1 OFFICIAL"): per team his #teams
  // status, then 📋 Official when the league's own list has him.
  const ROSTER_STYLE = {
    active:         ['#052e16', '#86efac', '#16a34a'],
    inactive:       ['#1e293b', '#cbd5e1', '#64748b'],
    practice_squad: ['#3a2e05', '#fbbf24', '#d97706'],
    call_in:        ['#3a2e05', '#fbbf24', '#d97706'],
    not_eligible:   ['#3b0a0a', '#fca5a5', '#dc2626'],   // ⛔ mig 1523
    standby:        ['#0c1e3a', '#93c5fd', '#2563eb'],   // 🪑 Reserves, mig 1530
  };
  const ROSTER_FALLBACK = {
    active: 'Active', inactive: 'Inactive', practice_squad: 'Practice Squad', call_in: 'Call-in', not_eligible: 'Not On Roster', standby: 'Reserves',
  };
  function rosterHtml(personId) {
    const hit = cache.get(Number(personId));
    const rosters = hit && hit.data && Array.isArray(hit.data.rosters) ? hit.data.rosters : [];
    const regs = hit && hit.data && Array.isArray(hit.data.registrations) ? hit.data.registrations : [];
    if (!rosters.length && !regs.length) return '';
    const bits = [];
    rosters.forEach((r) => {
      const team = r.team || '';
      if (r.status) {
        const [bg, fg, border] = ROSTER_STYLE[r.status] || ROSTER_STYLE.inactive;
        bits.push(pill(t(`roster_${r.status}`, { team }, `${team} ${ROSTER_FALLBACK[r.status] || r.status}`),
          t('roster_status_tip', { team }, `Status on ${team} (#teams)`), bg, fg, border));
      }
      if (r.official) {
        bits.push(pill(t('roster_official', { team }, `📋 ${team} Official`),
          t('roster_official_tip', { list: r.officialList || team, date: r.officialAt || '' },
            `On the league's official list — ${r.officialList || team}`),
          '#0c1e3a', '#93c5fd', '#2563eb'));
      }
    });
    // League registration (mig 1518/1519): ✅ filled the league's form (or
    // on its list), ❌ never did — a call-up then needs a new registration.
    regs.forEach((g) => {
      const league = g.league || '';
      if (g.registered) {
        const date = g.at || '';
        bits.push(pill(t('reg_have', { league, date }, `✅ ${league} reg ${date}`.trim()),
          g.source === 'official_list'
            ? t('reg_list_tip', { league, date }, `On the ${league} official roster, so registered with ${league} this season.`)
            : t('reg_have_tip', { league, date }, `Filled the ${league} registration form.`),
          '#052e16', '#86efac', '#16a34a'));
      } else {
        bits.push(pill(t('reg_missing', { league }, `❌ No ${league} reg`),
          t('reg_missing_tip', { league }, `Never filled the ${league} registration form.`),
          '#3b0a0a', '#fca5a5', '#dc2626'));
      }
    });
    return bits.length
      ? `<div data-roster-standing-line style="font-size:0.68rem; display:flex; flex-wrap:wrap; gap:5px; align-items:center; margin-top:2px;">${bits.join('')}</div>`
      : '';
  }

  // Fill every [data-roster-standing] under root once its ids are loaded.
  async function fillRosters(auth, root) {
    if (!root) return;
    const els = [...root.querySelectorAll('[data-roster-standing]')];
    if (!els.length) return;
    await load(auth, els.map(e => e.dataset.rosterStanding));
    els.forEach(e => { e.innerHTML = rosterHtml(e.dataset.rosterStanding); });
  }

  // Has he (or his parent) ever answered an RSVP himself?  true / false,
  // or null while unknown (not loaded, or a viewer without access).
  function answered(personId) {
    const hit = cache.get(Number(personId));
    return hit && hit.data && typeof hit.data.answered === 'boolean' ? hit.data.answered : null;
  }

  // Fill every [data-standing-chip] under root once its ids are loaded —
  // boards render cards synchronously, so the chips arrive after.
  async function fillChips(auth, root) {
    if (!root) return;
    const els = [...root.querySelectorAll('[data-standing-chip]')];
    if (!els.length) return;
    await load(auth, els.map(e => e.dataset.standingChip));
    els.forEach(e => { e.innerHTML = chip(e.dataset.standingChip, { inactive: e.dataset.standingInactive !== '0' }); });
  }

  // The dues figure alone — { balance, free_reason, member } or null (not
  // loaded / not an admin).  Game Center's lineup note (mig 1299).
  function dues(personId) {
    const hit = cache.get(Number(personId));
    return hit && hit.data && hit.data.dues ? hit.data.dues : null;
  }

  // A #teams team card box (owner 11/19 "2 'game' cards for apsl and liga 1
  // … with boxes and important info in the boxes"): two tiny lines under
  // the name — 👻 / 🙈 or the last RSVP date, then dues and the CASA form.
  // Same rules as html() / chip(); '' until loaded or for non-admins.
  // opts.paidAt: the board row's last payment (ISO) → "· 11/10" after the
  // dues (owner 11/19 "also would like a date paid").
  function boxLine(personId, opts = {}) {
    const hit = cache.get(Number(personId));
    if (!hit || !hit.data) return '';
    const { activity: a, dues: d } = hit.data;
    const s = (text, color, title) => `<span title="${esc(title || '')}" style="color:${color}; white-space:nowrap;">${esc(text)}</span>`;
    const top = [], bottom = [];
    // RSVP by colour (mig 1546, owner 11/19 "green if they set availabity
    // in last 7 days … yellow if within 14 days. red if past 14" → "just
    // the letters RSVP" → "we dont need ghost status as RSVP color will
    // tell us"): his own newest answer; the date rides on the hover.
    {
      const COL = { green: '#86efac', yellow: '#fbbf24', red: '#fca5a5' };
      const at = hit.data.lastAnsweredAt;
      const days = at ? Math.max(0, Math.floor((Date.now() - new Date(at)) / 86400000)) : null;
      top.push(s(t('box_rsvp', {}, 'RSVP'), COL[hit.data.rsvpBox] || COL.red,
        at ? t('box_rsvp_tip', { date: md(at), days }, `Last answered ${md(at)} (${days} days ago)`)
           : t('box_rsvp_never_tip', {}, 'Has never answered an RSVP themselves')));
      // P3 = practices attended lately (mig 1555) — the 🤝 Committed tiebreak.
      if (hit.data.practicesRecent != null) {
        const n = Number(hit.data.practicesRecent) || 0;
        top.push(s(t('box_practices', { n }, `P${n}`), n > 0 ? 'rgba(255,255,255,0.9)' : '#fca5a5',
          t('box_practices_tip', { n, days: hit.data.practiceDays || 14 }, `Came to ${n} practices in the last ${hit.data.practiceDays || 14} days`)));
      }
    }
    // Dues (owner 11/19 "in green it dont even need to say paid … if owed
    // it needs to show date of last payment and AMOUNT OWED all in red"):
    // green "11/10 $35" = last payment; red "11/10 $70" = last payment
    // date + amount owed.  opts.paidAt / opts.paidAmount = the board row's.
    // Last payment on ANY of his LA registrations (standing lastPaidAt,
    // owner 11/19 "Marco has no date"); the board row's (current reg only)
    // is the fallback.
    const paidIso = hit.data.lastPaidAt || opts.paidAt || '';
    const paidAmt = hit.data.lastPaidAt ? hit.data.lastPaidAmount : opts.paidAmount;
    const paid = paidIso ? md(paidIso) : '';
    const money = (n) => `$${Math.round(Number(n) || 0)}`;
    if (d) {
      if (d.free_reason === 'volunteer') bottom.push(s(t('box_dues_volunteer', {}, '🙋 vol'), '#cbd5e1'));   // mig 1534
      else if (d.free_reason) bottom.push(s(t('box_dues_free', {}, '$0'), '#cbd5e1'));
      else if (!d.member) bottom.push(s(t('box_dues_none', {}, 'no LA'), '#9ca3af'));
      else if (d.balance > 0) {
        const amount = money(d.balance);
        bottom.push(s(paid ? t('box_owes_since', { date: paid, amount }, `${paid} ${amount}`) : amount, '#fca5a5',
          paid ? t('box_owes_since_tip', { date: paid, amount }, `Owes ${amount}. Last payment ${paid}.`)
               : t('box_owes_never_tip', { amount }, `Owes ${amount}. No payment on record.`)));
      } else {
        const amount = paidAmt != null && paidAmt !== '' ? money(paidAmt) : '';
        bottom.push(s(paid ? t('box_paid_amount', { date: paid, amount }, `${paid} ${amount}`.trim()) : t('box_dues_free', {}, '$0'), '#86efac',
          paid ? t('box_paid_on_tip', { date: paid }, `Last payment ${paid}`) : ''));
      }
    }
    // League paperwork is the box's red DOCS corner flag now (docsMissing,
    // mig 1548), not ❌CASA / ❌APSL on this line.
    const row = (bits) => bits.length ? `<div style="display:flex; gap:4px; justify-content:center; flex-wrap:nowrap; overflow:hidden;">${bits.join('')}</div>` : '';
    return row(top) + row(bottom);
  }

  // DOCS on a #teams box (mig 1548, owner 11/19 "a flag at top of card
  // that is DOCS in red? its obvois if liga 1 team its for CASA reg and
  // apsl same"): the league that owns teamId (registrations[].teamIds) has
  // no registration for him and he is not on its list.  Filled the APSL
  // form but not listed yet = docs are in, no flag (ROSTER says the rest).
  // → { league, tip } or null; null until loaded / for non-admins.
  function docsMissing(personId, teamId) {
    const hit = cache.get(Number(personId));
    const regs = hit && hit.data && Array.isArray(hit.data.registrations) ? hit.data.registrations : [];
    const g = regs.find(r => r && Array.isArray(r.teamIds) && r.teamIds.some(id => Number(id) === Number(teamId)));
    if (!g || g.registered || g.onList) return null;
    const league = g.league || '';
    let tip = g.formSheet
      ? t('docs_missing_tip', { league }, `No ${league} registration form on file.`)
      : t('reg_missing_tip', { league }, `Never filled the ${league} registration form.`);
    const stale = g.formSheet && g.formOk === false;
    if (stale) tip += ' ' + t('docs_stale_tip', { league, date: g.formAt || '' }, `Couldn't read the ${league} form sheet.`);
    return { league, tip, stale };
  }

  // ✅CASA / ❌CASA after a name (⛔ Not eligible row on the #teams team
  // card, mig 1523): filled the form → the commissioner can put him On
  // Roster now; never → a new registration first.  '' until loaded.
  function regMark(personId) {
    const hit = cache.get(Number(personId));
    const regs = hit && hit.data && Array.isArray(hit.data.registrations) ? hit.data.registrations : [];
    return regs.filter(g => g && g.league === 'CASA').map(g => g.registered
      ? `<span style="color:#86efac;" title="${esc(t('reg_have_tip', { league: g.league, date: g.at || '' }, ''))}">${esc(t('box_reg_have', { league: g.league }, `✅${g.league}`))}</span>`
      : `<span style="color:#fca5a5;" title="${esc(t('reg_missing_tip', { league: g.league }, ''))}">${esc(t('box_reg_missing', { league: g.league }, `❌${g.league}`))}</span>`).join('');
  }

  // Behind on what (mig 1551, owner 11/19 "categorize the players who are
  // regulars … up to date in rsvp and dues, behind rsvp, behind in dues,
  // behind in both" → "or is that better done as a sort?"): rsvp = not
  // green (no own answer in rsvp_box_policy.green_days); dues = owes on a
  // live membership (volunteer / $0 / no LA never count).  null until
  // loaded / for non-admins.
  function behind(personId) {
    const hit = cache.get(Number(personId));
    if (!hit || !hit.data) return null;
    const d = hit.data.dues;
    // Not green = behind (owner 11/19: Erick David, yellow RSVP + owes, "is both").
    return { rsvp: hit.data.rsvpBox !== 'green', dues: !!(d && !d.free_reason && d.member && d.balance > 0),
             practices: Number(hit.data.practicesRecent) || 0 };
  }

  // A save changed his teams (player sheet ⚽ pills): the next load re-reads.
  function forget(personId) { cache.delete(Number(personId)); }

  window.PersonStanding = { behind, docsMissing, docFlags, forget, load, html, chip, fillChips, rosterHtml, fillRosters, answered, laMemberUrl, laLink, laUserId, dues, boxLine, regMark };
})();
