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

  const pill = (text, title, bg, fg, border) =>
    `<span title="${esc(title)}" style="padding:0 6px; border-radius:999px; background:${bg}; color:${fg}; border:1px solid ${border}; font-weight:800; white-space:nowrap;">${esc(text)}</span>`;

  const inactivePill = () => pill(t('inactive', {}, '💤 INACTIVE'),
    t('inactive_tip', {}, 'Inactive — still billed monthly, no fines, no RSVP reminders'), '#1e293b', '#cbd5e1', '#64748b');

  function html(personId) {
    const hit = cache.get(Number(personId));
    if (!hit || !hit.data) return '';
    const { activity: a, dues: d } = hit.data;
    const bits = [];
    // 💤 Inactive (mig 945): leads the line; ghost / no-show say nothing
    // about someone who isn't meant to come.
    if (hit.data.inactive) bits.push(inactivePill());

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
      if (d.free_reason === 'volunteer') bits.push(pill(t('dues_volunteer', {}, '🙋 Volunteer'), '', '#1e293b', '#cbd5e1', '#475569'));
      else if (d.free_reason === 'injured') bits.push(pill(t('dues_injured', {}, '🩹 No dues'), '', '#1e293b', '#cbd5e1', '#475569'));
      else if (!d.member) bits.push(pill(t('dues_no_membership', {}, '💰 No membership'), t('dues_no_membership_tip', {}, 'No live LeagueApps registration'), '#1f2937', '#9ca3af', '#4b5563'));
      else if (d.balance > 0) {
        const amount = `$${Math.round(d.balance)}`;
        bits.push(pill(t('dues_owes', { amount, months: d.months_behind }, `💰 Owes ${amount} · ${d.months_behind} mo`), '', d.months_behind >= 2 ? '#3a1f1f' : '#3a2e05', d.months_behind >= 2 ? '#fca5a5' : '#fbbf24', d.months_behind >= 2 ? '#b91c1c' : '#d97706'));
      } else bits.push(pill(t('dues_paid', {}, '💰 Paid up'), '', '#052e16', '#86efac', '#16a34a'));
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
    return `${small(flag)}<span title="${esc(rTip)}" style="font-size:0.65rem; line-height:1.3; font-weight:800; white-space:nowrap;">${esc(rTxt)}</span>`
      + `<span title="${esc(lastTip)}" style="font-size:0.65rem; line-height:1.3; font-weight:700; white-space:nowrap;">${esc(lastTxt)}</span>`;
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

  window.PersonStanding = { load, html, chip, fillChips, answered };
})();
