// RoleSelectionScreen - Choose which role to use (Coach, Player, Admin)
class RoleSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-role-selection';
    
    const user = this.navigation.context.user;
    const userName = user?.name || user?.email || 'User';
    
    // Check if user has admin role (club, sport division, team, super, or system level)
    const isAdmin = user?.role && (user.role === 'club' || user.role === 'sport_division' || user.role === 'team' || user.role === 'super' || user.role === 'system' || user.role === 'league');
    const adminButtonDisplay = isAdmin ? 'flex' : 'none';
    
    div.innerHTML = `
      <div class="screen-header">
        <h1>Welcome, ${this.escapeHtml(userName)}</h1>
        <p class="subtitle">Choose your role to continue</p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-4); max-width: 500px; margin: 0 auto;">
        <button class="btn btn-lg btn-primary" data-role="coach" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">🏆</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Coach</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">Manage your teams</div>
          </div>
        </button>
        
        <button class="btn btn-lg btn-primary" data-role="player" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">👤</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Player</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">View your info & availability</div>
          </div>
        </button>
        
        <button class="btn btn-lg btn-primary" data-role="admin" style="display: ${adminButtonDisplay}; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">👨‍💼</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Admin</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">System administration</div>
          </div>
        </button>
        
        <button class="btn btn-lg btn-primary" data-role="club-admin" style="display: ${adminButtonDisplay}; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">🏢</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Club Admin</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">Social media, events & club management</div>
          </div>
        </button>

        <a href="/tactical-games.html" class="btn btn-lg btn-primary" style="display: ${adminButtonDisplay}; align-items: center; gap: var(--space-3); text-decoration: none; color: inherit;">
          <span style="font-size: 2rem;">⚽</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Tactical Games</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">Sim demo + cognitive learning games</div>
          </div>
        </a>

        <button class="btn btn-text logout-btn" style="margin-top: var(--space-4);">Logout</button>
        <button class="btn btn-outline-secondary open-tactical-btn" style="margin-top: var(--space-2);">Open Tactical Board</button>

        <!-- ── View-as / impersonation picker (2026-07-11) ────────────
             Admin-only debugging tool: pick any active member and
             the app reloads as that person (all /api/my/* calls get
             ?asPersonId=<id> appended by the auth fetch wrapper).
             Persistent orange banner at the top of every screen shows
             who you're viewing as, with an "Exit view-as" button.
             Writes remain locked to the real caller \u2014 the backend
             refuses ?asPersonId= on POST/PUT/DELETE. -->
        <div class="view-as-picker" style="display: ${adminButtonDisplay}; flex-direction: column; gap: var(--space-2); margin-top: var(--space-4); padding: var(--space-3); border: 1px dashed #f97316; border-radius: 8px;">
          <div style="font-weight: bold; color: #c2410c;">\ud83c\udfad View as another member</div>
          <div style="font-size: 0.8rem; color: #666;">Read-only impersonation \u2014 debugging tool for admins.</div>
          <select class="view-as-select" style="padding: 8px; font-size: 1rem; border-radius: 6px; border: 1px solid #ccc;">
            <option value="">\u2014 loading members\u2026 \u2014</option>
          </select>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // ── Player-only auto-skip (2026-07-06) ─────────────────────────
    //
    // If the user is a plain player (no coach affiliation, no admin
    // claim, no admin-level `user.role`) there's nothing to pick from
    // here — force them straight to their weekly RSVP view.  This is
    // the natural landing page for the vast majority of accounts and
    // saves them from a meaningless button-tap on every visit.
    //
    // Coaches and admins keep the picker because they routinely
    // switch context (coach ↔ player, admin ↔ club-admin, etc).
    this._maybeAutoSkipToMy();

    // Handle role selection via event delegation
    this.element.addEventListener('click', (e) => {
      const roleBtn = e.target.closest('[data-role]');
      if (roleBtn) {
        const role = roleBtn.dataset.role;
        this.handleRoleSelection(role);
      }
      
      // Handle logout
      if (e.target.closest('.logout-btn')) {
        this.handleLogout();
      }

      // Open tactical board (direct)
      if (e.target.closest('.open-tactical-btn')) {
        // If we already have a selected team in navigation context, open tactical board directly
        const team = this.navigation.context?.team;
        const club = this.navigation.context?.club;

        if (team && team.id) {
          this.navigation.goTo('tactical-board', { teamId: team.id, teamName: team.name, clubId: team.clubId || club?.id });
        } else if (club && club.id) {
          // open at club level
          this.navigation.goTo('tactical-board', { clubId: club.id, clubName: club.name });
        } else {
          // Open tactical board without a specific context so user can work freely
          this.navigation.goTo('tactical-board');
        }
      }
    });

    // ── View-as picker ────────────────────────────────────────────────
    // Only meaningful for admins.  The dropdown is already hidden via
    // CSS `display: none` for non-admins, but we also short-circuit
    // the fetch to keep server logs clean.
    this._maybeLoadViewAsPicker();
  }

  async _maybeLoadViewAsPicker() {
    const user = this.navigation.context.user;
    const isAdmin = user?.role && (
      user.role === 'club' || user.role === 'sport_division' ||
      user.role === 'team' || user.role === 'super' ||
      user.role === 'system' || user.role === 'league'
    );
    if (!isAdmin) return;

    const select = this.element.querySelector('.view-as-select');
    if (!select) return;

    // One-time change handler.  Setting `viewAsPersonId` in Auth fires
    // a `viewAsChanged` DOM event; the banner in index.html reacts to
    // it and shows itself.  Then we navigate to /my as the target so
    // the admin immediately sees that person's weekly schedule.
    select.addEventListener('change', (ev) => {
      const opt = ev.target.selectedOptions[0];
      if (!opt || !opt.value) return;
      const personId   = Number(opt.value);
      const personName = opt.getAttribute('data-name') || opt.textContent || '';
      if (!personId) return;
      this.auth.setViewAs(personId, personName);
      this.navigation.context.role = 'player';
      this.navigation.goTo('my');
    });

    try {
      const res = await this.auth.fetch('/api/admin/members?variant=active');
      if (!res.ok) {
        select.innerHTML = '<option value="">— failed to load members —</option>';
        return;
      }
      const body = await res.json();
      const groups = body?.data?.groups || [];

      // Category emoji + display order — mirrors the "everyone pickup
      // and regular members on men, boys etc" phrasing from the
      // feature request.  Any category not in this map falls through
      // as a plain-labelled optgroup at the end.
      const catOrder  = ['men', 'women', 'boys', 'girls'];
      const catEmoji  = { men: '👨', women: '👩', boys: '👦', girls: '👧' };
      groups.sort((a, b) => {
        const ai = catOrder.indexOf(a.category);
        const bi = catOrder.indexOf(b.category);
        return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
      });

      const parts = ['<option value="">— pick a member —</option>'];
      for (const g of groups) {
        const emoji = catEmoji[g.category] || '•';
        const label = `${emoji} ${g.label || g.category} — ${g.program_name || ''}`.trim();
        parts.push(`<optgroup label="${this.escapeHtml(label)}">`);
        const members = g.members || [];
        for (const m of members) {
          const name = `${m.first_name || ''} ${m.last_name || ''}`.trim() || `Person #${m.person_id}`;
          parts.push(
            `<option value="${m.person_id}" data-name="${this.escapeHtml(name)}">`
            + this.escapeHtml(name)
            + '</option>'
          );
        }
        parts.push('</optgroup>');
      }
      select.innerHTML = parts.join('');
    } catch (e) {
      console.error('[view-as] failed to load members:', e);
      select.innerHTML = '<option value="">— failed to load members —</option>';
    }
  }
  
  handleRoleSelection(role) {
    // Store selected role in navigation context and navigate
    this.navigation.context.role = role;
    
    if (role === 'admin') {
      // Admin role - go directly to level selection
      this.navigation.goTo('admin-level-selection');
    } else if (role === 'club-admin') {
      // Club Admin - fetch user's club and go to club admin dashboard
      this.loadClubAdmin();
    } else if (role === 'player') {
      // Player - jump straight to their unified weekly schedule.
      // (Team-picking is intentionally skipped; MyController resolves
      //  eligible events via mens_team_assignments internally.)
      this.navigation.goTo('my');
    } else if (role === 'coach') {
      this.navigation.goTo('context-selection', { role: role });
    } else {
      this.handleError(new Error('Unknown role: ' + role), 'role-selection');
    }
  }
  
  async loadClubAdmin() {
    // Go directly to club admin for Lighthouse
    this.navigation.goTo('admin-club', {
      clubId: 134,
      clubName: 'Lighthouse 1893 SC'
    });
  }
  
  handleLogout() {
    this.auth.logout();
    this.navigation.context = { user: null, role: null, team: null }; // Clear context
    this.navigation.updateContextHeader();
    this.navigation.goTo('login');
  }

  // Fetches /api/auth/me/roles and, if the user has NO coach or admin
  // affiliation, immediately redirects to the weekly RSVP view.  Pure
  // players never need to see the picker.
  //
  // Also treats admin-level `user.role` (club / sport_division / team
  // / super / system / league) as "keep the picker" so admins retain
  // the ability to switch modes even if the DB has no matching
  // `admins` / `team_coaches` rows yet.
  async _maybeAutoSkipToMy() {
    try {
      const user = this.navigation.context.user || {};
      const isAdmin = user.role && (
        user.role === 'club' || user.role === 'sport_division' ||
        user.role === 'team' || user.role === 'super' ||
        user.role === 'system' || user.role === 'league'
      );
      if (isAdmin) return;

      const res = await this.auth.fetch('/api/auth/me/roles');
      if (!res.ok) return;
      const body = await res.json();
      const roles = (body && body.data && Array.isArray(body.data.roles))
        ? body.data.roles
        : [];
      const hasCoach = roles.some(r => r && r.type === 'coach');
      const hasAdmin = roles.some(r => r && r.type === 'admin');
      if (!hasCoach && !hasAdmin) {
        this.navigation.context.role = 'player';
        this.navigation.goTo('my');
      }
    } catch (_e) {
      // Non-fatal — fall back to the manual picker.
    }
  }
  
  // Helper to escape HTML
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
