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
        description: 'Shared emails, matching name+DOB pairs, and people touched by merge history.',
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
    list.style.display = 'grid';
    list.style.gridTemplateColumns = 'repeat(auto-fill, minmax(280px, 1fr))';
    list.style.gap = 'var(--space-2)';
    list.innerHTML = this._people.map((p) => this._cardHtml(p)).join('');
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
