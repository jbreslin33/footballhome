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
      const res = await this.auth.fetch(`/api/schedule/window?week_start=${weekStart}`);
      if (!res.ok || this.weekStart !== weekStart) { if (!res.ok) this.el.innerHTML = ''; return; }
      this.window = await res.json();
      this.el.innerHTML = this.html(this.window);
    } catch (err) {
      console.warn('[calendar] release strip failed:', err);
      this.el.innerHTML = '';
    }
  }

  html(w) {
    const esc = this.esc;
    const admin = CalendarOps.isAdmin(this.auth);
    const fmt = CalendarOps.fmtWhen;
    const mon = new Date(w.week_start + 'T00:00:00');
    const weekLabel = `Week of ${mon.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}`;
    const policyOpens = w.policy_opens_at ? new Date(w.policy_opens_at).getTime() : null;
    const earlyOpen = !!(w.release && !w.release.revoked_at && policyOpens && policyOpens > Date.now());
    const postedNormally = w.open_now && !earlyOpen;

    const base = 'display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:8px 12px; border-radius:8px; font-size:0.85rem;';
    const btn  = 'padding:5px 12px; border-radius:999px; border:1px solid rgba(255,255,255,0.25); background:#2563eb; color:#fff; font-weight:700; font-size:0.8rem; cursor:pointer;';
    const link = 'background:none; border:none; color:#bfdbfe; text-decoration:underline; cursor:pointer; font-size:0.78rem; padding:2px 4px;';

    let body;
    if (postedNormally) {
      body = `<span>✅ <strong>${esc(weekLabel)}</strong> is posted. It opened
          ${esc(fmt(w.opens_at))}${w.policy ? ` (rule: ${esc(w.policy.label)})` : ''}.</span>`;
    } else if (earlyOpen) {
      body = `<span>✅ <strong>${esc(weekLabel)}</strong> is posted early
          ${w.release.released_by ? `by ${esc(w.release.released_by)}` : ''}, ${esc(fmt(w.release.released_at))}.
          Normal post time was ${esc(fmt(w.policy_opens_at))}.</span>
        ${admin ? `<button type="button" data-release-close="${w.release.id}" style="${btn} background:#7f1d1d;">Close it again</button>` : ''}`;
    } else {
      body = `<span>🕗 <strong>${esc(weekLabel)}</strong> posts to players and parents
          <strong>${esc(fmt(w.opens_at))}</strong>${w.policy ? ` (rule: ${esc(w.policy.label)})` : ''}.</span>
        ${admin ? `<button type="button" data-release-open="${esc(w.week_start)}" style="${btn}">Open now</button>` : ''}`;
    }

    let policyHtml = '';
    if (admin) {
      if (this.editing) {
        const wd = w.policy ? w.policy.weekday : 0;
        const tm = w.policy ? w.policy.time : '20:00';
        const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        policyHtml = `
          <span style="display:inline-flex; align-items:center; gap:6px; margin-left:auto;">
            <span style="opacity:0.8;">Standing rule:</span>
            <select data-policy-weekday style="font-size:0.8rem; padding:3px 6px;">
              ${names.map((n, i) => `<option value="${i}" ${i === wd ? 'selected' : ''}>${n}</option>`).join('')}
            </select>
            <input type="time" data-policy-time value="${esc(tm)}" style="font-size:0.8rem; padding:3px 6px;">
            <button type="button" data-policy-save style="${btn}">Save</button>
            <button type="button" data-policy-cancel style="${link}">Cancel</button>
          </span>`;
      } else {
        policyHtml = `<button type="button" data-policy-edit style="${link} margin-left:auto;">Change the rule</button>`;
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
          const mon = new Date(openBtn.dataset.releaseOpen + 'T00:00:00');
          if (!confirm(`Post the week of ${mon.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })} to players and parents now?`)) return;
          openBtn.disabled = true; openBtn.textContent = 'Opening…';
          const res = await this.auth.fetch('/api/schedule/releases', { method: 'POST', headers: json, body: JSON.stringify({ week_start: openBtn.dataset.releaseOpen }) });
          if (!res.ok) await fail(res);
        } else if (closeBtn) {
          if (!confirm('Close this week again? Players and parents will stop seeing it until the normal post time.')) return;
          closeBtn.disabled = true; closeBtn.textContent = 'Closing…';
          const res = await this.auth.fetch(`/api/schedule/releases/${closeBtn.dataset.releaseClose}/revoke`, { method: 'POST' });
          if (!res.ok) await fail(res);
        } else if (editBtn) {
          this.editing = true;
        } else if (cancelBtn) {
          this.editing = false;
        } else if (saveBtn) {
          const wd = this.el.querySelector('[data-policy-weekday]').value;
          const tm = this.el.querySelector('[data-policy-time]').value;
          saveBtn.disabled = true; saveBtn.textContent = 'Saving…';
          const res = await this.auth.fetch('/api/schedule/policy', { method: 'PUT', headers: json, body: JSON.stringify({ cutover_weekday: String(wd), cutover_time: tm }) });
          if (!res.ok) await fail(res);
          this.editing = false;
        }
        await this.load(this.weekStart);
        if (this.onChange && (openBtn || closeBtn || saveBtn)) this.onChange();
      } catch (err) {
        console.error('[calendar] release action failed:', err);
        alert(`Could not update the schedule window: ${err.message}`);
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
    if (!clashes.length) {
      return `<div style="${base} background:rgba(22,101,52,0.18); border:1px solid rgba(74,222,128,0.35);">
        ${esc(this.copy('clash_none', { through: body.through || '' }) || `✅ No field clashes on the calendar through ${body.through || ''}.`)}
      </div>`;
    }
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
    return `<div style="${base} background:rgba(245,158,11,0.14); border:1px solid rgba(251,191,36,0.5);">
      <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
        <strong>${esc(this.copy('clash_title') || '⚠ Field clash')}</strong>
        <span style="opacity:0.8;">${clashes.length} in the next ${body.days || ClashStrip.DAYS} days</span>
        <span style="opacity:0.65; font-size:0.78rem; flex-basis:100%;">${esc(this.copy('clash_hint'))}</span>
      </div>
      ${rows}
    </div>`;
  }
}

window.CalendarOps = CalendarOps;
window.ReleaseStrip = ReleaseStrip;
window.ClashStrip = ClashStrip;
