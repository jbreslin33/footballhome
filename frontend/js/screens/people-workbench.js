// PeopleWorkbenchScreen — Club Admin person-graph directory.
//
// Data source: GET /api/admin/people?view=…
// Scope: current Lighthouse people only (open person_la_memberships).
// Scraped league/opponent-only identities stay in System Admin.
//
// Views (lens tiles from admin-club):
//   directory   — full person graph (default)
//   accounts    — persons with a users row
//   players     — persons with a players row
//   staff       — coaches / club admins / team admins
//   duplicates  — email or name+dob collisions, merge history
//   data-issues — missing contact / account / roster / RSVP links
class PeopleWorkbenchScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="people-workbench-title">People Directory</h1>
        <p class="subtitle" id="people-workbench-subtitle">Lighthouse person graph</p>
      </div>

      <div style="padding: var(--space-4);">
        <p id="people-workbench-description" style="opacity: 0.75; margin: 0 0 var(--space-3);">
          One row per Lighthouse person with account, player, staff, roster, and RSVP links.
        </p>

        <div id="people-lens-bar" style="display:flex; flex-wrap:wrap; gap: var(--space-1);
             margin-bottom: var(--space-3);"></div>

        <div id="people-counts" style="display:flex; flex-wrap:wrap; gap: var(--space-2);
             margin-bottom: var(--space-3); font-size: 0.85rem; opacity: 0.85;"></div>

        <div style="margin-bottom: var(--space-3);">
          <input id="people-search" type="search"
                 placeholder="Search name, email, phone…"
                 style="width:100%; padding: var(--space-2) var(--space-3); font-size: 1rem;
                        border-radius: var(--radius-md); border: 1px solid var(--color-border);
                        background: var(--bg-secondary); color: var(--text-primary);">
        </div>

        <div id="people-loading" style="padding: var(--space-4); text-align:center; opacity:0.7;">
          Loading people…
        </div>
        <div id="people-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="people-empty" style="display:none; text-align:center; padding: var(--space-6);
             opacity:0.6;">No people match this view.</div>
        <div id="people-list" style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Lighthouse';
    this.view = this._normalizeView(params?.view);
    this._search = '';
    this._people = [];
    this._counts = {};
    this._searchTimer = null;

    const meta = this._viewMeta(this.view);
    this.find('#people-workbench-title').textContent = params?.title || meta.title;
    this.find('#people-workbench-subtitle').textContent =
      params?.subtitle || `${this.clubName} · person graph`;
    this.find('#people-workbench-description').textContent =
      params?.description || meta.description;

    this._renderLensBar();
    this._bindEvents();
    this._load();
  }

  _normalizeView(view) {
    const allowed = ['directory', 'accounts', 'players', 'staff', 'duplicates', 'data-issues'];
    const v = String(view || 'directory').toLowerCase();
    return allowed.includes(v) ? v : 'directory';
  }

  _viewMeta(view) {
    const map = {
      directory: {
        title: 'People Directory',
        description: 'One Lighthouse person per row: contact, account, player, staff, membership, roster, and RSVP.',
      },
      accounts: {
        title: 'Accounts',
        description: 'Login users connected to Lighthouse persons — sign-in state and activity.',
      },
      players: {
        title: 'Players',
        description: 'Lighthouse player records linked to persons (not scraped opponent-only players).',
      },
      staff: {
        title: 'Coaches & Admins',
        description: 'Coach, team admin, and club admin assignments on Lighthouse people.',
      },
      duplicates: {
        title: 'Duplicates / Merges',
        description: 'Grouped by shared email or name+DOB. Keep one person and drop the other; reverse from the person profile.',
      },
      'data-issues': {
        title: 'Data Issues',
        description: 'Missing contacts, accounts, LA aliases, roster assignments, or RSVP eligibility.',
      },
    };
    return map[view] || map.directory;
  }

  _bindEvents() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const lens = e.target.closest('[data-lens]');
      if (lens) {
        this.view = this._normalizeView(lens.getAttribute('data-lens'));
        const meta = this._viewMeta(this.view);
        this.find('#people-workbench-title').textContent = meta.title;
        this.find('#people-workbench-description').textContent = meta.description;
        this._renderLensBar();
        this._load();
        return;
      }

      const mergeBtn = e.target.closest('[data-merge-keep][data-merge-drop]');
      if (mergeBtn) {
        e.preventDefault();
        e.stopPropagation();
        this._mergePersons(
          Number(mergeBtn.getAttribute('data-merge-keep')),
          Number(mergeBtn.getAttribute('data-merge-drop')),
          mergeBtn
        );
        return;
      }

      // Ignore clicks on action buttons inside cards.
      if (e.target.closest('[data-stop-nav]')) return;

      const card = e.target.closest('[data-la-user-id]');
      if (card) {
        const laId = card.getAttribute('data-la-user-id');
        if (!laId) return;
        this.navigation.goTo('person', {
          leagueAppsUserId: laId,
          returnTo: 'people-workbench',
          returnToParams: {
            clubId: this.clubId,
            clubName: this.clubName,
            view: this.view,
            title: this.find('#people-workbench-title')?.textContent,
            subtitle: this.find('#people-workbench-subtitle')?.textContent,
            description: this.find('#people-workbench-description')?.textContent,
          },
        });
      }
    });

    const search = this.find('#people-search');
    if (search) {
      search.addEventListener('input', () => {
        clearTimeout(this._searchTimer);
        this._searchTimer = setTimeout(() => {
          this._search = (search.value || '').trim();
          this._load();
        }, 250);
      });
    }
  }

  _renderLensBar() {
    const lenses = [
      { id: 'directory', label: 'Directory' },
      { id: 'accounts', label: 'Accounts' },
      { id: 'players', label: 'Players' },
      { id: 'staff', label: 'Staff' },
      { id: 'duplicates', label: 'Duplicates' },
      { id: 'data-issues', label: 'Data Issues' },
    ];
    const el = this.find('#people-lens-bar');
    if (!el) return;
    el.innerHTML = lenses.map((l) => {
      const active = l.id === this.view;
      return `<button type="button" class="btn btn-secondary" data-lens="${l.id}"
                style="padding: 4px 12px; font-size: 0.85rem;
                       ${active ? 'background: var(--color-primary); color: #fff; border-color: var(--color-primary);' : ''}">
                ${l.label}
              </button>`;
    }).join('');
  }

  async _load() {
    const loading = this.find('#people-loading');
    const error = this.find('#people-error');
    const empty = this.find('#people-empty');
    const list = this.find('#people-list');
    if (loading) loading.style.display = 'block';
    if (error) { error.style.display = 'none'; error.textContent = ''; }
    if (empty) empty.style.display = 'none';
    if (list) list.style.display = 'none';

    try {
      const qs = new URLSearchParams({ view: this.view });
      if (this._search) qs.set('q', this._search);
      const res = await this.auth.fetch(`/api/admin/people?${qs.toString()}`);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body || `HTTP ${res.status}`);
      }
      const json = await res.json();
      const data = json.data || json;
      this._people = Array.isArray(data.people) ? data.people : [];
      this._counts = data.counts || {};
      this._renderCounts();
      this._renderList();
    } catch (err) {
      if (error) {
        error.style.display = 'block';
        error.textContent = `Failed to load people: ${err.message || err}`;
      }
    } finally {
      if (loading) loading.style.display = 'none';
    }
  }

  _renderCounts() {
    const el = this.find('#people-counts');
    if (!el) return;
    const c = this._counts;
    const shown = this._people.length;
    el.innerHTML = `
      <span>Showing <strong>${shown}</strong></span>
      <span>· Accounts ${c.accounts ?? '—'}</span>
      <span>· Players ${c.players ?? '—'}</span>
      <span>· Staff ${c.staff ?? '—'}</span>
      <span>· Duplicates ${c.duplicates ?? '—'}</span>
      <span>· Issues ${c.data_issues ?? '—'}</span>
    `;
  }

  _renderList() {
    const empty = this.find('#people-empty');
    const list = this.find('#people-list');
    if (!list) return;

    if (!this._people.length) {
      if (empty) empty.style.display = 'block';
      list.style.display = 'none';
      list.innerHTML = '';
      return;
    }
    if (empty) empty.style.display = 'none';

    if (this.view === 'duplicates') {
      list.style.display = 'flex';
      list.style.flexDirection = 'column';
      list.style.gap = 'var(--space-3)';
      list.style.gridTemplateColumns = '';
      list.innerHTML = this._duplicatesHtml();
      return;
    }

    list.style.display = 'grid';
    list.style.gridTemplateColumns = 'repeat(auto-fill, minmax(280px, 1fr))';
    list.style.gap = 'var(--space-2)';
    list.innerHTML = this._people.map((p) => this._cardHtml(p)).join('');
  }

  // Group duplicate candidates by shared email or name+DOB so the
  // operator can pick a keep / drop pair and call /api/persons/merge.
  _duplicatesHtml() {
    const groups = new Map();
    const add = (key, label, person) => {
      if (!key) return;
      if (!groups.has(key)) groups.set(key, { key, label, people: [] });
      const g = groups.get(key);
      if (!g.people.some((p) => p.person_id === person.person_id)) {
        g.people.push(person);
      }
    };

    for (const p of this._people) {
      if (p.email_duplicate && p.email) {
        add(`email:${String(p.email).toLowerCase()}`, `Shared email · ${p.email}`, p);
      }
      if (p.name_dob_duplicate) {
        const fn = String(p.first_name || '').toLowerCase();
        const ln = String(p.last_name || '').toLowerCase();
        const dob = p.dob || '';
        add(`name:${fn}|${ln}|${dob}`, `Matching name + DOB · ${p.first_name || ''} ${p.last_name || ''} ${dob}`.trim(), p);
      }
    }

    // Merge-history-only people (no live collision) still show as cards.
    const groupedIds = new Set();
    for (const g of groups.values()) {
      for (const p of g.people) groupedIds.add(p.person_id);
    }
    const mergeOnly = this._people.filter((p) => p.has_merge_history && !groupedIds.has(p.person_id));

    const parts = [];
    for (const g of groups.values()) {
      if (g.people.length < 2) continue;
      // Prefer keep candidate with LA alias + account + most roster links.
      const ranked = [...g.people].sort((a, b) => this._keepScore(b) - this._keepScore(a));
      parts.push(`
        <div style="border: 1px solid var(--color-border); border-radius: var(--radius-lg);
                    padding: var(--space-3); background: var(--bg-secondary);">
          <div style="font-weight:700; margin-bottom: var(--space-2);">${this._esc(g.label)}</div>
          <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                      gap: var(--space-2);">
            ${ranked.map((p, idx) => this._dupCardHtml(p, ranked, idx === 0)).join('')}
          </div>
        </div>
      `);
    }

    if (mergeOnly.length) {
      parts.push(`
        <div style="border: 1px solid var(--color-border); border-radius: var(--radius-lg);
                    padding: var(--space-3);">
          <div style="font-weight:700; margin-bottom: var(--space-2);">Merge history only</div>
          <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                      gap: var(--space-2);">
            ${mergeOnly.map((p) => this._cardHtml(p)).join('')}
          </div>
          <p style="margin: var(--space-2) 0 0; font-size:0.8rem; opacity:0.7;">
            Open the person profile to reverse a merge if needed.
          </p>
        </div>
      `);
    }

    if (!parts.length) {
      return `<div style="opacity:0.6; text-align:center; padding: var(--space-6);">
        No mergeable duplicate groups found.
      </div>`;
    }
    return parts.join('');
  }

  _keepScore(p) {
    let s = 0;
    if (p.leagueapps_user_id) s += 8;
    if (p.has_fh_account) s += 4;
    if (p.player_id) s += 2;
    s += Number(p.roster_count || 0);
    s += Number(p.rsvp_count || 0);
    if (p.email) s += 1;
    if (p.phone) s += 1;
    return s;
  }

  _dupCardHtml(p, group, suggestedKeep) {
    const name = `${p.first_name || ''} ${p.last_name || ''}`.trim() || `Person #${p.person_id}`;
    const laId = p.leagueapps_user_id ? String(p.leagueapps_user_id) : '';
    const others = group.filter((o) => o.person_id !== p.person_id);
    const mergeBtns = others.map((o) => `
      <button type="button" class="btn btn-secondary" data-stop-nav
              data-merge-keep="${p.person_id}" data-merge-drop="${o.person_id}"
              style="padding:4px 10px; font-size:0.75rem; font-weight:700;">
        Keep this · drop #${o.person_id}
      </button>
    `).join('');

    return `
      <div ${laId ? `data-la-user-id="${this._esc(laId)}"` : ''}
           style="padding: var(--space-3); border: 1px solid ${suggestedKeep ? '#10b981' : 'var(--color-border)'};
                  border-radius: var(--radius-md); background: var(--bg-primary);
                  display:flex; flex-direction:column; gap:6px;
                  ${laId ? 'cursor:pointer;' : ''}">
        <div style="font-weight:600;">
          ${this._esc(name)}
          <span style="opacity:0.55; font-weight:500; font-size:0.8rem;">#${p.person_id}</span>
          ${suggestedKeep ? this._chip('#0b3a2e', '#a7f3d0', '#10b981', 'Suggested keep') : ''}
        </div>
        <div style="font-size:0.8rem; opacity:0.75;">
          ${p.email ? this._esc(p.email) : 'no email'}
          · ${p.has_fh_account ? 'has account' : 'no account'}
          · roster ${p.roster_count || 0}
          · RSVP ${p.rsvp_count || 0}
        </div>
        <div style="display:flex; flex-wrap:wrap; gap:6px; margin-top:4px;" data-stop-nav>
          ${mergeBtns}
        </div>
      </div>
    `;
  }

  async _mergePersons(keepId, dropId, btn) {
    if (!keepId || !dropId || keepId === dropId) return;
    const keep = this._people.find((p) => p.person_id === keepId);
    const drop = this._people.find((p) => p.person_id === dropId);
    const keepName = keep
      ? `${keep.first_name || ''} ${keep.last_name || ''}`.trim() || `#${keepId}`
      : `#${keepId}`;
    const dropName = drop
      ? `${drop.first_name || ''} ${drop.last_name || ''}`.trim() || `#${dropId}`
      : `#${dropId}`;
    const ok = window.confirm(
      `Merge people?\n\nKeep: ${keepName} (#${keepId})\nDrop: ${dropName} (#${dropId})\n\n` +
      `Child rows move onto the kept person. This can be reversed from the person profile.`
    );
    if (!ok) return;

    const prev = btn ? btn.textContent : '';
    if (btn) {
      btn.disabled = true;
      btn.textContent = 'Merging…';
    }
    try {
      // API param names are historical (LA keep / GM drop) — same keep/drop semantics.
      const res = await this.auth.fetch('/api/persons/merge', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ laPersonId: keepId, gmPersonId: dropId }),
      });
      if (!res.ok) {
        const t = await res.text();
        throw new Error(t || `HTTP ${res.status}`);
      }
      await this._load();
    } catch (err) {
      alert(`Merge failed: ${err.message || err}`);
      if (btn) {
        btn.disabled = false;
        btn.textContent = prev;
      }
    }
  }

  _cardHtml(p) {
    const name = `${p.first_name || ''} ${p.last_name || ''}`.trim() || `Person #${p.person_id}`;
    const laId = p.leagueapps_user_id ? String(p.leagueapps_user_id) : '';
    const clickable = !!laId;

    const chips = [];
    if (p.has_fh_account) {
      const days = p.days_since_activity;
      chips.push(days == null
        ? this._chip('#3a2e05', '#fde68a', '#d97706', 'Account · never seen')
        : this._chip('#0b3a2e', '#a7f3d0', '#10b981', `Account · ${days}d`));
    } else {
      chips.push(this._chip('#1f2937', '#9ca3af', '#374151', 'No account'));
    }
    if (p.player_id) chips.push(this._chip('#0b1f3a', '#93c5fd', '#3b82f6', 'Player'));
    if (p.is_coach) chips.push(this._chip('#2e1a3a', '#e9d5ff', '#a855f7', 'Coach'));
    if (p.is_club_admin) chips.push(this._chip('#2e1a3a', '#e9d5ff', '#a855f7', 'Club admin'));
    if (p.is_team_admin) chips.push(this._chip('#2e1a3a', '#e9d5ff', '#a855f7', 'Team admin'));
    if (p.has_active) chips.push(this._chip('#0b3a2e', '#a7f3d0', '#10b981', 'Active member'));
    if (p.has_pickup) chips.push(this._chip('#1f2937', '#9ca3af', '#374151', 'Pickup'));
    if (p.email_duplicate || p.name_dob_duplicate) {
      chips.push(this._chip('#3a1515', '#fecaca', '#ef4444', 'Possible duplicate'));
    }
    if (p.has_merge_history) {
      chips.push(this._chip('#3a2e05', '#fde68a', '#d97706', 'Merge history'));
    }

    const issues = Array.isArray(p.issues) ? p.issues : [];
    const issueLabels = {
      missing_email: 'Missing email',
      missing_phone: 'Missing phone',
      missing_la_alias: 'Missing LA alias',
      no_fh_account: 'No FH account',
      no_player: 'No player record',
      no_roster: 'No roster team',
      no_rsvp: 'No RSVP eligibility',
    };
    const issueHtml = issues.length
      ? `<div style="display:flex; flex-wrap:wrap; gap:4px; margin-top:4px;">
           ${issues.map((i) => this._chip('#3a1515', '#fecaca', '#ef4444', issueLabels[i] || i)).join('')}
         </div>`
      : '';

    const rosterLine = p.roster_count > 0
      ? `<div style="font-size:0.8rem; opacity:0.8;">Roster · ${this._esc(p.roster_teams || `${p.roster_count} team(s)`)}</div>`
      : `<div style="font-size:0.8rem; opacity:0.55;">Roster · none</div>`;
    const rsvpLine = p.rsvp_count > 0
      ? `<div style="font-size:0.8rem; opacity:0.8;">RSVP · ${this._esc(p.rsvp_teams || `${p.rsvp_count} team(s)`)}</div>`
      : `<div style="font-size:0.8rem; opacity:0.55;">RSVP · none</div>`;

    const contactBits = [];
    if (p.email) contactBits.push(this._esc(p.email));
    if (p.phone) contactBits.push(this._esc(p.phone));
    const contactLine = contactBits.length
      ? `<div style="font-size:0.8rem; opacity:0.75; word-break:break-word;">${contactBits.join(' · ')}</div>`
      : `<div style="font-size:0.8rem; opacity:0.55;">No contact on file</div>`;

    return `
      <div ${clickable ? `data-la-user-id="${this._esc(laId)}"` : ''}
           style="padding: var(--space-3); border: 1px solid var(--color-border);
                  border-radius: var(--radius-md); background: var(--bg-secondary);
                  display:flex; flex-direction:column; gap:6px;
                  ${clickable ? 'cursor:pointer;' : ''}">
        <div style="font-weight:600;">${this._esc(name)}</div>
        <div style="display:flex; flex-wrap:wrap; gap:4px;">${chips.join('')}</div>
        ${contactLine}
        ${rosterLine}
        ${rsvpLine}
        ${issueHtml}
        ${!clickable ? `<div style="font-size:0.75rem; opacity:0.55;">No LA alias — open from Members after sync</div>` : ''}
      </div>
    `;
  }

  _chip(bg, fg, border, text) {
    return `<span style="display:inline-flex; align-items:center; padding:2px 8px;
                   border-radius:999px; font-size:0.7rem; font-weight:700;
                   background:${bg}; color:${fg}; border:1px solid ${border};">${this._esc(text)}</span>`;
  }

  _esc(s) {
    return String(s ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
}
