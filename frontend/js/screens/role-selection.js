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

        <button class="btn btn-lg btn-primary" data-role="summer-planner" style="display: ${adminButtonDisplay}; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">🏟️</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Summer Planner</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">Assign players to summer squads</div>
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
    } else if (role === 'summer-planner') {
      this.navigation.goTo('internal-roster');
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
