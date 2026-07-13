// RsvpEligibilityScreen — Diagnostic board that shows exactly which
// mens-selection teams each FH member can RSVP for.
//
// Why this exists (2026-07-11): the mens-roster board grants RSVP
// eligibility automatically via an INSERT/UPDATE trigger on
// roster_assignments, BUT that only fires when a coach has manually
// dropped the player onto a mens tier (APSL / Liga 1 / Liga 2 / Adult)
// on the Mens Roster screen.  Members who never made it onto a tier
// only get Pickup (909) via the LaPool fallback, which looks confusing
// when you're staring at the mens-roster board and wondering why
// $PERSON only has ✓ on Pickup.
//
// This screen is the "check my work" view — one row per member, one
// column per team, ✓ / – shows the current state, click to toggle.
// Tabs (All / Men / Women / Boys / Girls) mirror the Members board so
// the same filter mental model applies.
//
// Data flow:
//   1. GET /api/admin/members?variant=active               — one call, all categories
//      (payload now includes `leagueapps_user_id` per person)
//   2. GET /api/mens-roster/rsvp-eligibility?leagueAppsUserId=X   — one per person
//   3. PUT /api/mens-roster/rsvp-eligibility body {leagueAppsUserId, teamIds}
//
// Team catalog (must stay in sync with MensRosterController.cpp
// `kEligibilityTeams`):
//   35 APSL · 120 Liga 1 · 121 Liga 2 · 122 Adult · 908 Practice · 909 Pickup

class RsvpEligibilityScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🗳️ RSVP Eligibility</h1>
        <p class="subtitle" id="rsvp-elig-subtitle">Who can RSVP for which mens team</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="rsvp-elig-filters" style="margin-bottom: var(--space-3);
             display:flex; flex-wrap:wrap; gap: var(--space-1);"></div>

        <div id="rsvp-elig-search-wrap" style="margin-bottom: var(--space-3);">
          <input id="rsvp-elig-search" type="search"
                 placeholder="Search name or email…"
                 style="width:100%; padding: var(--space-2) var(--space-3); font-size: 1rem;
                        border-radius: var(--radius-md); border: 1px solid var(--color-border);
                        background: var(--bg-secondary); color: var(--text-primary);">
        </div>

        <div id="rsvp-elig-legend" style="margin-bottom: var(--space-3); display:flex;
             flex-wrap:wrap; gap:6px; font-size:0.8rem;"></div>

        <div id="rsvp-elig-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">
          Loading members and eligibility…
        </div>
        <div id="rsvp-elig-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="rsvp-elig-empty" style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">
          No members match this tab.
        </div>

        <div id="rsvp-elig-table-wrap" style="display:none; overflow-x:auto;
             background: var(--bg-secondary); border: 1px solid var(--color-border);
             border-radius: var(--radius-md);">
          <table id="rsvp-elig-table" style="width:100%; border-collapse: collapse;
                 font-size: 0.88rem;">
          </table>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  // Team catalog — MUST match MensRosterController.cpp `kEligibilityTeams`.
  // Order here == column order in the table.  Colors match the per-player
  // modal in mens-roster.js openRsvpEligibilityModal().
  _teams() {
    return [
      { id: 35,  short: 'APSL',   label: 'APSL',     color: '#2563eb' },
      { id: 120, short: 'Liga 1', label: 'Liga 1',   color: '#0891b2' },
      { id: 121, short: 'Liga 2', label: 'Liga 2',   color: '#14b8a6' },
      { id: 122, short: 'Adult', label: 'Adult',     color: '#a78bfa' },
      { id: 908, short: 'Pract.', label: 'Practice', color: '#f59e0b' },
      { id: 909, short: 'Pickup', label: 'Pickup',   color: '#10b981' },
    ];
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;
    this._groups  = [];
    this._elig    = new Map();   // leagueAppsUserId (string) → Set<teamId>
    this._filter  = '';
    // Default tab = All so the operator sees everyone right away.
    this._category = '';

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const chip = e.target.closest('[data-category-chip]');
      if (chip) {
        const cat = chip.getAttribute('data-category-chip');
        this._category = (cat === 'all') ? '' : cat;
        this._renderChips();
        this._renderTable();
        return;
      }
    });

    // Delegate change events on the checkboxes.  Toggling a box PUTs the
    // full new team-id set for that player (the PUT endpoint is
    // set-replace, per MensRosterController.cpp handlePutRsvpEligibility).
    this.element.addEventListener('change', async (e) => {
      const cb = e.target.closest('input[type=checkbox][data-la-user-id]');
      if (!cb) return;
      const uid    = cb.getAttribute('data-la-user-id');
      const teamId = Number(cb.getAttribute('data-team-id'));
      const want   = cb.checked;
      await this._toggle(uid, teamId, want, cb);
    });

    const search = this.find('#rsvp-elig-search');
    if (search) {
      search.addEventListener('input', (ev) => {
        this._filter = (ev.target.value || '').trim().toLowerCase();
        this._renderTable();
      });
    }

    this._load();
  }

  async _load() {
    const loadingEl = this.find('#rsvp-elig-loading');
    const errorEl   = this.find('#rsvp-elig-error');
    const wrap      = this.find('#rsvp-elig-table-wrap');
    const emptyEl   = this.find('#rsvp-elig-empty');
    loadingEl.style.display = 'block';
    errorEl.style.display   = 'none';
    emptyEl.style.display   = 'none';
    wrap.style.display      = 'none';

    try {
      const res = await this.auth.fetch('/api/admin/members?variant=active');
      if (!res.ok) throw new Error(`members HTTP ${res.status}`);
      const body = await res.json();
      if (!body?.success) throw new Error(body?.error || 'members load failed');

      this._groups = Array.isArray(body?.data?.groups) ? body.data.groups : [];

      // Batch-fetch eligibility for every member with an LA user id.
      // N parallel GETs is fine for ~150 members; if it gets slow later
      // we can add a bulk endpoint that takes a comma-separated list.
      const uids = new Set();
      for (const g of this._groups) {
        for (const m of (g.members || [])) {
          const uid = m.leagueapps_user_id;
          if (uid !== null && uid !== undefined && uid !== '') uids.add(String(uid));
        }
      }
      loadingEl.textContent = `Fetching RSVP eligibility for ${uids.size} member${uids.size === 1 ? '' : 's'}…`;

      await Promise.all(Array.from(uids).map(async (uid) => {
        try {
          const r = await this.auth.fetch(
            `/api/mens-roster/rsvp-eligibility?leagueAppsUserId=${encodeURIComponent(uid)}`
          );
          if (!r.ok) { this._elig.set(uid, new Set()); return; }
          const b = await r.json();
          this._elig.set(uid, new Set((b?.teamIds || []).map(Number)));
        } catch (_e) {
          this._elig.set(uid, new Set());
        }
      }));

      loadingEl.style.display = 'none';
      this._renderChips();
      this._renderLegend();
      this._renderTable();
    } catch (err) {
      console.error('rsvp-eligibility load failed', err);
      loadingEl.style.display = 'none';
      errorEl.style.display   = 'block';
      errorEl.textContent     = `Failed to load: ${err.message}`;
    }
  }

  // Category tabs — match members-screen style so the mental model
  // transfers.  Counts reflect the current member set (before search
  // filter) so the tabs don't jump around as you type.
  _renderChips() {
    const el = this.find('#rsvp-elig-filters');
    if (!el) return;
    const order = ['men', 'women', 'boys', 'girls'];
    const present = new Set(this._groups.map(g => (g.category || '').toLowerCase()));
    const cats = order.filter(c => present.has(c));
    const totalAll = this._groups.reduce((n, g) => n + (g.members?.length || 0), 0);
    const countFor = (cat) => this._groups
      .filter(g => (g.category || '').toLowerCase() === cat)
      .reduce((n, g) => n + (g.members?.length || 0), 0);
    const label = { men: '👨 Men', women: '👩 Women', boys: '👦 Boys', girls: '👧 Girls' };
    const chip = (id, text, count, active) => `
      <button data-category-chip="${id}"
              style="padding:6px 12px; border-radius:999px; cursor:pointer;
                     font-weight:600; font-size:0.85rem;
                     border:1px solid var(--color-border);
                     background:${active ? 'var(--color-primary, #2563eb)' : 'var(--bg-secondary)'};
                     color:${active ? 'white' : 'var(--text-primary)'};">
        ${text} <span style="opacity:0.7; font-weight:400;">(${count})</span>
      </button>`;
    el.innerHTML = [
      chip('all', 'All', totalAll, !this._category),
      ...cats.map(c => chip(c, label[c] || c, countFor(c), this._category === c)),
    ].join(' ');
  }

  _renderLegend() {
    const el = this.find('#rsvp-elig-legend');
    if (!el) return;
    el.innerHTML = this._teams().map(t => `
      <span style="display:inline-flex; align-items:center; gap:4px;
                   padding:3px 8px; border-radius:999px;
                   background:${t.color}22; color:${t.color};
                   border:1px solid ${t.color}66;">
        <span style="width:8px; height:8px; border-radius:2px; background:${t.color};"></span>
        ${t.label} <span style="opacity:0.6;">#${t.id}</span>
      </span>
    `).join(' ');
  }

  _filteredMembers() {
    // Flatten groups → members, filter by category tab + search string.
    // Category is per-group; search matches name/email substring.
    const rows = [];
    for (const g of this._groups) {
      const gc = (g.category || '').toLowerCase();
      if (this._category && gc !== this._category) continue;
      for (const m of (g.members || [])) {
        rows.push({ ...m, category: gc, program_name: g.program_name });
      }
    }
    if (!this._filter) return rows;
    return rows.filter(m => {
      const hay = [
        m.first_name, m.last_name, m.email,
        `${m.first_name || ''} ${m.last_name || ''}`,
      ].map(v => (v || '').toLowerCase()).join(' ');
      return hay.includes(this._filter);
    });
  }

  _renderTable() {
    const wrap = this.find('#rsvp-elig-table-wrap');
    const empty = this.find('#rsvp-elig-empty');
    const table = this.find('#rsvp-elig-table');
    const subtitle = this.find('#rsvp-elig-subtitle');
    if (!wrap || !table) return;

    const teams = this._teams();
    const rows  = this._filteredMembers();

    const catLabel = { men: 'Men', women: 'Women', boys: 'Boys', girls: 'Girls' }[this._category] || 'All';
    if (subtitle) {
      subtitle.textContent =
        `${rows.length} member${rows.length === 1 ? '' : 's'} — ${catLabel} · toggle a checkbox to grant/revoke RSVP eligibility`;
    }

    if (rows.length === 0) {
      wrap.style.display  = 'none';
      empty.style.display = 'block';
      return;
    }
    empty.style.display = 'none';
    wrap.style.display  = 'block';

    const th = (txt, style = '') => `<th style="text-align:left; padding:8px 10px;
      font-weight:700; font-size:0.78rem; text-transform:uppercase; letter-spacing:0.03em;
      opacity:0.75; border-bottom:1px solid var(--color-border); ${style}">${txt}</th>`;

    const teamCols = teams.map(t => `
      <th style="text-align:center; padding:8px 6px; font-weight:700;
                 font-size:0.78rem; text-transform:uppercase; letter-spacing:0.03em;
                 color:${t.color}; border-bottom:1px solid var(--color-border);
                 border-left:1px solid var(--color-border);">
        ${t.short}
        <div style="font-size:0.65rem; opacity:0.55; font-weight:400;">#${t.id}</div>
      </th>`).join('');

    const bodyRows = rows.map(m => {
      const uid  = (m.leagueapps_user_id === null || m.leagueapps_user_id === undefined) ? '' : String(m.leagueapps_user_id);
      const name = `${m.first_name || ''} ${m.last_name || ''}`.trim() || '(no name)';
      const email = m.email || '';
      const set   = this._elig.get(uid) || new Set();
      const catBadge = m.category
        ? `<span style="display:inline-block; padding:2px 8px; margin-left:6px;
                        border-radius:999px; font-size:0.7rem; font-weight:600;
                        background:var(--bg-tertiary, #1f2937); opacity:0.8;">
             ${this._categoryEmoji(m.category)} ${m.category}
           </span>`
        : '';
      const noUid = !uid;
      const noUidNote = noUid
        ? `<div style="font-size:0.7rem; color:#f59e0b; margin-top:2px;">⚠ no LeagueApps user id — RSVP eligibility can't be set</div>`
        : '';

      const cells = teams.map(t => {
        if (noUid) {
          return `<td style="text-align:center; padding:6px;
                             border-top:1px solid var(--color-border);
                             border-left:1px solid var(--color-border); opacity:0.3;">–</td>`;
        }
        const checked = set.has(t.id) ? 'checked' : '';
        return `
          <td style="text-align:center; padding:6px;
                     border-top:1px solid var(--color-border);
                     border-left:1px solid var(--color-border);
                     background:${set.has(t.id) ? t.color + '15' : 'transparent'};">
            <input type="checkbox"
                   data-la-user-id="${this._esc(uid)}"
                   data-team-id="${t.id}"
                   ${checked}
                   style="width:18px; height:18px; accent-color:${t.color}; cursor:pointer;">
          </td>`;
      }).join('');

      return `
        <tr>
          <td style="padding:8px 10px; border-top:1px solid var(--color-border);">
            <div style="font-weight:600;">${this._esc(name)}${catBadge}</div>
            ${email ? `<div style="font-size:0.78rem; opacity:0.7;">${this._esc(email)}</div>` : ''}
            <div style="font-size:0.68rem; opacity:0.5; margin-top:2px;">
              ${uid ? `LA #${this._esc(uid)}` : 'no LA id'}
              ${m.program_name ? ` · ${this._esc(m.program_name)}` : ''}
            </div>
            ${noUidNote}
          </td>
          ${cells}
        </tr>
      `;
    }).join('');

    table.innerHTML = `
      <thead>
        <tr style="background: var(--bg-tertiary, rgba(255,255,255,0.03));">
          ${th('Member', 'min-width:220px;')}
          ${teamCols}
        </tr>
      </thead>
      <tbody>${bodyRows}</tbody>
    `;
  }

  async _toggle(uid, teamId, want, cb) {
    // Optimistically update local state so the row background flips
    // instantly.  Rollback the checkbox + local state on PUT failure.
    const set = this._elig.get(uid) || new Set();
    const had = set.has(teamId);
    if (want) set.add(teamId); else set.delete(teamId);
    this._elig.set(uid, set);
    // Update just this cell's background — cheaper than re-rendering the table.
    const td = cb.closest('td');
    if (td) {
      const color = (this._teams().find(t => t.id === teamId) || {}).color || '#2563eb';
      td.style.background = want ? color + '15' : 'transparent';
    }

    try {
      const r = await this.auth.fetch('/api/mens-roster/rsvp-eligibility', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          leagueAppsUserId: Number(uid),
          teamIds: Array.from(set),
        }),
      });
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
    } catch (err) {
      // Rollback.
      if (had) set.add(teamId); else set.delete(teamId);
      this._elig.set(uid, set);
      cb.checked = had;
      if (td) {
        const color = (this._teams().find(t => t.id === teamId) || {}).color || '#2563eb';
        td.style.background = had ? color + '15' : 'transparent';
      }
      alert(`Failed to save RSVP eligibility: ${err.message}`);
    }
  }

  _categoryEmoji(c) {
    return { men: '👨', women: '👩', boys: '👦', girls: '👧' }[c] || '';
  }

  _esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
}
