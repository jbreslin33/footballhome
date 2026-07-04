// AdminClubTeamsScreen — lightweight team picker for club admin.
//
// Route: 'admin-club-teams'
// Nav from: admin-club → sub-nav "Teams" tile.
// Purpose: list every team in the club as a card; clicking a card
//          opens that team's home page (team-hub).
//
// Data source: GET /api/clubs/:clubId?gender=all (already returns
// the full teams array; no new endpoint needed).
class AdminClubTeamsScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-club-teams';
    div.innerHTML = `
      <div class="screen-header" style="display:flex;align-items:center;gap:var(--space-3);padding:var(--space-3);">
        <button class="btn btn-secondary btn-sm back-btn">← Back</button>
        <h1 id="act-title" style="margin:0;font-size:1.15rem;">Teams</h1>
        <span style="flex:1"></span>
        <span id="act-count" style="font-size:0.78rem;color:var(--text-muted);"></span>
      </div>

      <div style="padding: 0 var(--space-3) var(--space-3);">
        <div id="act-filter-row" style="display:flex;gap:var(--space-2);align-items:center;margin-bottom:var(--space-3);flex-wrap:wrap;">
          <input id="act-search" type="search" placeholder="Search teams…"
                 style="flex:1;min-width:180px;font-size:0.9rem;padding:8px 10px;border-radius:6px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);">
          <div id="act-gender-pills" style="display:flex;gap:4px;">
            <button type="button" class="act-gender-pill" data-gender="all"    style="font-size:0.78rem;padding:6px 10px;border-radius:9999px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);cursor:pointer;">All</button>
            <button type="button" class="act-gender-pill" data-gender="mens"   style="font-size:0.78rem;padding:6px 10px;border-radius:9999px;background:transparent;color:var(--text-muted);border:1px solid var(--border-color);cursor:pointer;">Men's</button>
            <button type="button" class="act-gender-pill" data-gender="womens" style="font-size:0.78rem;padding:6px 10px;border-radius:9999px;background:transparent;color:var(--text-muted);border:1px solid var(--border-color);cursor:pointer;">Women's</button>
            <button type="button" class="act-gender-pill" data-gender="youth"  style="font-size:0.78rem;padding:6px 10px;border-radius:9999px;background:transparent;color:var(--text-muted);border:1px solid var(--border-color);cursor:pointer;">Youth</button>
          </div>
        </div>

        <div id="act-list" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(240px, 1fr));gap:var(--space-2);">
          <div style="grid-column: 1 / -1; text-align:center; padding: var(--space-4); color: var(--text-muted);">
            <div class="spinner" style="display:inline-block;"></div>
            <div style="margin-top: var(--space-2);">Loading teams…</div>
          </div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId ?? this.navigation.context?.club?.id;
    this.clubName = params?.clubName ?? this.navigation.context?.club?.name ?? 'Club';
    this._teams = [];
    this._filter = 'all';
    this._search = '';

    const title = this.find('#act-title');
    if (title) title.textContent = `${this.clubName} — Teams`;

    this._wireEvents();
    this._loadTeams();
  }

  _wireEvents() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const pill = e.target.closest('.act-gender-pill');
      if (pill) {
        this._filter = pill.dataset.gender;
        this._renderPills();
        this._renderList();
        return;
      }
      const card = e.target.closest('[data-team-open]');
      if (card) {
        const teamId = parseInt(card.dataset.teamOpen, 10);
        const team = this._teams.find(t => t.id === teamId);
        if (team) {
          this.navigation.goTo('team-hub', {
            teamId: team.id,
            teamName: team.name,
            clubId: this.clubId,
            lineupTeamId: team.id,
          });
        }
        return;
      }
    });
    const search = this.find('#act-search');
    if (search) {
      search.addEventListener('input', (e) => {
        this._search = e.target.value.trim().toLowerCase();
        this._renderList();
      });
    }
  }

  async _loadTeams() {
    try {
      const res = await this.auth.fetch(`/api/clubs/${this.clubId}?gender=all`);
      const payload = await res.json();
      // Backend returns club object with teams array — normalise both shapes.
      const club = payload?.data || payload;
      this._teams = Array.isArray(club?.teams) ? club.teams : [];
    } catch (err) {
      console.warn('[admin-club-teams] load failed:', err);
      this._teams = [];
    }
    this._renderList();
  }

  _renderPills() {
    this.element.querySelectorAll('.act-gender-pill').forEach(btn => {
      const active = btn.dataset.gender === this._filter;
      btn.style.background = active ? 'var(--bg-secondary)' : 'transparent';
      btn.style.color = active ? 'var(--text-primary)' : 'var(--text-muted)';
    });
  }

  _renderList() {
    const list = this.find('#act-list');
    const count = this.find('#act-count');
    if (!list) return;

    const filtered = this._teams.filter(t => {
      if (this._filter !== 'all') {
        const gc = String(t.gender_category || '').toLowerCase();
        if (gc !== this._filter) return false;
      }
      if (this._search && !String(t.name || '').toLowerCase().includes(this._search)) return false;
      return true;
    });

    if (count) count.textContent = `${filtered.length} of ${this._teams.length}`;

    if (!filtered.length) {
      list.innerHTML = `
        <div style="grid-column: 1 / -1; text-align:center; padding: var(--space-4); color: var(--text-muted);">
          No teams match.
        </div>
      `;
      return;
    }

    // Sort: pool teams last (they're catch-alls), then alphabetical.
    const sorted = [...filtered].sort((a, b) => {
      const ap = a.is_pool ? 1 : 0, bp = b.is_pool ? 1 : 0;
      if (ap !== bp) return ap - bp;
      return String(a.name || '').localeCompare(String(b.name || ''));
    });

    list.innerHTML = sorted.map(t => {
      const name = this.escapeHtml(t.name || 'Team');
      const gc = String(t.gender_category || '').toLowerCase();
      const genderChip = gc
        ? `<span style="font-size:0.68rem;padding:2px 6px;border-radius:9999px;background:rgba(148,163,184,0.15);color:var(--text-muted);">${this.escapeHtml(gc)}</span>`
        : '';
      const poolChip = t.is_pool
        ? '<span style="font-size:0.68rem;padding:2px 6px;border-radius:9999px;background:rgba(56,189,248,0.15);color:#38bdf8;">pool</span>'
        : '';
      return `
        <button type="button" data-team-open="${t.id}"
                style="all:unset;cursor:pointer;display:block;padding:var(--space-3);border-radius:8px;background:var(--bg-secondary);border:1px solid var(--border-color);transition:border-color 0.15s;"
                onmouseover="this.style.borderColor='#3b82f6'"
                onmouseout="this.style.borderColor='var(--border-color)'">
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:4px;flex-wrap:wrap;">
            ${genderChip}
            ${poolChip}
          </div>
          <div style="font-weight:600;color:var(--text-primary);font-size:0.95rem;">${name}</div>
          <div style="font-size:0.72rem;color:var(--text-muted);margin-top:4px;">Open team page →</div>
        </button>
      `;
    }).join('');
  }
}
