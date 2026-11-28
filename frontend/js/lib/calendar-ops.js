// Calendar ops strips — the admin pieces above the one 📅 Calendar page
// (screens/event-center.js).  They lived on the old #calendar screen
// (screens/calendar.js, deleted 2026-11-16 — owner: "rsvp, calendar and
// event center should be one page").
//
//   ReleaseStrip  the week's schedule release (mig 334): when it posts to
//                 players and parents, ✅ posted / posted early, Open now /
//                 Close it again, and the standing rule.  Admin writes.
//   ClashStrip    field clashes on the calendar (mig 532): games on one
//                 facility needing more than one field at once, always the
//                 next 120 days whatever the page shows.
//
// Each takes its host element and { auth, escapeHtml }; load() fetches and
// paints, the strip wires its own clicks once per host element.

const CalendarOps = {
  // Admin = the account's role — under 🎭 view-as that is the viewed
  // person's own (auth.user, core/ViewAs), so a player never gets the strips.
  isAdmin(auth) {
    const role = auth && auth.user && auth.user.role;
    return role === 'club' || role === 'super' || role === 'system';
  },
  fmtWhen(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d)) return '';
    return `${d.toLocaleDateString(undefined, { weekday: 'short', month: 'numeric', day: 'numeric' })} ${d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;
  },
};

class ReleaseStrip {
  constructor(el, ctx) {
    this.el = el;
    this.auth = ctx.auth;
    this.esc = ctx.escapeHtml;
    this.weekStart = null;      // 'YYYY-MM-DD', the Monday shown
    this.editing = false;
    this.window = null;
    this._wire();
  }

  // weekStart: the Monday the page shows, or null to hide (month / agenda).
  async load(weekStart) {
    this.weekStart = weekStart;
    if (!this.el) return;
    if (!weekStart) { this.el.innerHTML = ''; return; }
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth).catch(() => {});   // the strip's words
      const res = await this.auth.fetch(`/api/schedule/window?week_start=${weekStart}`);
      if (!res.ok || this.weekStart !== weekStart) { if (!res.ok) this.el.innerHTML = ''; return; }
      this.window = await res.json();
      this.el.innerHTML = this.html(this.window);
      if (this.onPaint) this.onPaint();
    } catch (err) {
      console.warn('[calendar] release strip failed:', err);
      this.el.innerHTML = '';
    }
  }

  // Words: message_templates kind='calendar' release_* (mig 1394 — were
  // literals on the old #calendar).  A row missing reads as nothing.
  copy(tier, tokens = {}) {
    const mc = window.MessageCopy;
    return (mc && mc.block && mc.block('calendar', tier, tokens)) || '';
  }

  _weekWord(weekStart) {
    const mon = new Date(weekStart + 'T00:00:00');
    return this.copy('release_week', { date: mon.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }) });
  }

  html(w) {
    const esc = this.esc;
    const admin = CalendarOps.isAdmin(this.auth);
    const fmt = CalendarOps.fmtWhen;
    const week = this._weekWord(w.week_start);
    const rule = w.policy ? w.policy.label : '';
    const policyOpens = w.policy_opens_at ? new Date(w.policy_opens_at).getTime() : null;
    const earlyOpen = !!(w.release && !w.release.revoked_at && policyOpens && policyOpens > Date.now());
    const postedNormally = w.open_now && !earlyOpen;
    // The host shows the strip openly unless the week simply posted on time
    // (owner 11/27 "i dont see any way to open now" · "dude no menu").
    this.needsAction = !postedNormally;

    const base = 'display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:8px 12px; border-radius:8px; font-size:0.85rem;';
    const btn  = 'padding:5px 12px; border-radius:999px; border:1px solid rgba(255,255,255,0.25); background:#2563eb; color:#fff; font-weight:700; font-size:0.8rem; cursor:pointer;';
    const link = 'background:none; border:none; color:#bfdbfe; text-decoration:underline; cursor:pointer; font-size:0.78rem; padding:2px 4px;';
    // The sentence, escaped, with the week's name in bold.
    const line = (tier, tokens) => {
      const text = esc(this.copy(tier, { week, rule, ...tokens }));
      return `<span>${week ? text.replace(esc(week), `<strong>${esc(week)}</strong>`) : text}</span>`;
    };

    let body;
    if (postedNormally) {
      body = line('release_posted', { opened: fmt(w.opens_at) });
    } else if (earlyOpen) {
      body = line('release_early', { by: w.release.released_by || '', at: fmt(w.release.released_at), normal: fmt(w.policy_opens_at) })
        + (admin ? `<button type="button" data-release-close="${w.release.id}" style="${btn} background:#7f1d1d;">${esc(this.copy('release_close_btn'))}</button>` : '');
    } else {
      body = line('release_pending', { opens: fmt(w.opens_at) })
        + (admin ? `<button type="button" data-release-open="${esc(w.week_start)}" style="${btn}">${esc(this.copy('release_open_btn'))}</button>` : '');
    }

    let policyHtml = '';
    if (admin) {
      if (this.editing) {
        const wd = w.policy ? w.policy.weekday : 0;
        const tm = w.policy ? w.policy.time : '20:00';
        // Weekday names from the browser's locale (Sunday = 0, as the policy).
        const dayName = (i) => new Date(2024, 0, 7 + i).toLocaleDateString(undefined, { weekday: 'long' });
        policyHtml = `
          <span style="display:inline-flex; align-items:center; gap:6px; margin-left:auto;">
            <span style="opacity:0.8;">${esc(this.copy('release_rule_label'))}</span>
            <select data-policy-weekday style="font-size:0.8rem; padding:3px 6px;">
              ${[0, 1, 2, 3, 4, 5, 6].map(i => `<option value="${i}" ${i === wd ? 'selected' : ''}>${esc(dayName(i))}</option>`).join('')}
            </select>
            <input type="time" data-policy-time value="${esc(tm)}" style="font-size:0.8rem; padding:3px 6px;">
            <button type="button" data-policy-save style="${btn}">${esc(this.copy('release_save'))}</button>
            <button type="button" data-policy-cancel style="${link}">${esc(this.copy('release_cancel'))}</button>
          </span>`;
      } else {
        policyHtml = `<button type="button" data-policy-edit style="${link} margin-left:auto;">${esc(this.copy('release_rule_link'))}</button>`;
      }
    }
    const on = earlyOpen || postedNormally;
    return `<div style="${base} background:${on ? 'rgba(22,101,52,0.25)' : 'rgba(37,99,235,0.18)'}; border:1px solid ${on ? 'rgba(74,222,128,0.45)' : 'rgba(96,165,250,0.45)'};">
        ${body}${policyHtml}
      </div>`;
  }

  _wire() {
    if (!this.el) return;
    this.el.addEventListener('click', async (e) => {
      const openBtn   = e.target.closest('[data-release-open]');
      const closeBtn  = e.target.closest('[data-release-close]');
      const editBtn   = e.target.closest('[data-policy-edit]');
      const saveBtn   = e.target.closest('[data-policy-save]');
      const cancelBtn = e.target.closest('[data-policy-cancel]');
      if (!openBtn && !closeBtn && !editBtn && !saveBtn && !cancelBtn) return;
      e.preventDefault(); e.stopPropagation();
      const json = { 'Content-Type': 'application/json' };
      const fail = async (res) => { throw new Error((await res.json().catch(() => ({}))).error || `HTTP ${res.status}`); };
      try {
        if (openBtn) {
          if (!confirm(this.copy('release_confirm_open', { week: this._weekWord(openBtn.dataset.releaseOpen) }))) return;
          openBtn.disabled = true; openBtn.textContent = this.copy('release_opening');
          const res = await this.auth.fetch('/api/schedule/releases', { method: 'POST', headers: json, body: JSON.stringify({ week_start: openBtn.dataset.releaseOpen }) });
          if (!res.ok) await fail(res);
        } else if (closeBtn) {
          if (!confirm(this.copy('release_confirm_close'))) return;
          closeBtn.disabled = true; closeBtn.textContent = this.copy('release_closing');
          const res = await this.auth.fetch(`/api/schedule/releases/${closeBtn.dataset.releaseClose}/revoke`, { method: 'POST' });
          if (!res.ok) await fail(res);
        } else if (editBtn) {
          this.editing = true;
        } else if (cancelBtn) {
          this.editing = false;
        } else if (saveBtn) {
          const wd = this.el.querySelector('[data-policy-weekday]').value;
          const tm = this.el.querySelector('[data-policy-time]').value;
          saveBtn.disabled = true; saveBtn.textContent = this.copy('release_saving');
          const res = await this.auth.fetch('/api/schedule/policy', { method: 'PUT', headers: json, body: JSON.stringify({ cutover_weekday: String(wd), cutover_time: tm }) });
          if (!res.ok) await fail(res);
          this.editing = false;
        }
        await this.load(this.weekStart);
        if (this.onChange && (openBtn || closeBtn || saveBtn)) this.onChange();
      } catch (err) {
        console.error('[calendar] release action failed:', err);
        alert(this.copy('release_failed', { error: err.message }));
        await this.load(this.weekStart);
      }
    });
  }
}

class ClashStrip {
  static get DAYS() { return 120; }

  constructor(el, ctx) {
    this.el = el;
    this.auth = ctx.auth;
    this.esc = ctx.escapeHtml;
  }

  copy(tier, tokens = {}) {
    const mc = window.MessageCopy;
    return (mc && mc.block && mc.block('calendar', tier, tokens)) || '';
  }

  async load() {
    if (!this.el) return;
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth).catch(() => {});
      const res = await this.auth.fetch(`/api/calendar/field-clashes?days=${ClashStrip.DAYS}`);
      if (!res.ok) { this.el.innerHTML = ''; return; }
      this.el.innerHTML = this.html(await res.json());
    } catch (err) {
      console.warn('[calendar] clash strip failed:', err);
      this.el.innerHTML = '';
    }
  }

  html(body) {
    const esc = this.esc;
    const clashes = (body && body.clashes) || [];
    const base = 'padding:8px 12px; border-radius:8px; font-size:0.85rem;';
    // Silence when all is well, like a Unix tool (owner 11/18 "it should be
    // 'linux' like silence unless there is conflict then a red banner with
    // error text").  clash_none copy is no longer drawn.
    if (!clashes.length) return '';
    const fields = (n) => `${Number(n).toFixed(2).replace(/\.?0+$/, '')}`;
    const unknown = esc(this.copy('clash_unknown') || 'format not set');
    const rows = clashes.map(c => `
      <div style="padding:6px 0; border-top:1px solid rgba(255,255,255,0.12);">
        <div style="font-weight:700;">${esc(this.copy('clash_line', { facility: c.facility, day: c.day_label, time: c.time_label, total: fields(c.total_share) })
          || `${c.facility} · ${c.day_label} at ${c.time_label} — these games need ${fields(c.total_share)} fields at once:`)}</div>
        <ul style="margin:4px 0 0 18px; padding:0; line-height:1.5;">
          ${c.games.map(g => `<li>${esc(g.starts)}–${esc(g.ends)} <strong>${esc(g.summary || g.teams)}</strong>
              <span style="opacity:0.75;">· ${g.format ? esc(g.format) : unknown} · ${fields(g.share)} field${Number(g.share) === 1 ? '' : 's'}${g.unknown && g.format ? ` · ${unknown}` : ''}</span></li>`).join('')}
        </ul>
      </div>`).join('');
    return `<div role="alert" style="${base} background:rgba(185,28,28,0.28); border:1px solid #ef4444; color:#fecaca;">
      <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
        <strong style="color:#fff;">${esc(this.copy('clash_title') || '⚠ Field clash')}</strong>
        <span style="opacity:0.8;">${esc(this.copy('clash_count', { n: clashes.length, days: body.days || ClashStrip.DAYS }))}</span>
        <span style="opacity:0.65; font-size:0.78rem; flex-basis:100%;">${esc(this.copy('clash_hint'))}</span>
      </div>
      ${rows}
    </div>`;
  }
}

window.CalendarOps = CalendarOps;
window.ReleaseStrip = ReleaseStrip;
window.ClashStrip = ClashStrip;
