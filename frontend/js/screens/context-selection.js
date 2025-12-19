// ContextSelectionScreen - pick club or team based on role
class ContextSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-context-selection';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="context-title">Select Context</h1>
        <p class="subtitle" id="context-subtitle"></p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div id="context-list"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.role = params?.role || 'coach';
    this.navigation.context.role = this.role;
    
    // Set title based on role
    const titles = {
      coach: 'Select Team to Coach',
      player: 'Select Your Team',
      admin: 'Select Club or Team to Admin'
    };
    const subtitles = {
      coach: 'Choose a team to manage as coach',
      player: 'View your team info',
      admin: 'Choose what to manage'
    };
    
    this.find('#context-title').textContent = titles[this.role] || 'Select Context';
    this.find('#context-subtitle').textContent = subtitles[this.role] || '';
    
    this.loadContexts();
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const contextBtn = e.target.closest('.context-option');
      if (contextBtn) {
        const contextId = contextBtn.getAttribute('data-context-id');
        const contextName = contextBtn.getAttribute('data-context-name');
        const contextType = contextBtn.getAttribute('data-context-type'); // 'system', 'club', 'sport_division', or 'team'
        
        const context = { id: contextId, name: contextName, type: contextType };
        this.navigation.context.selectedContext = context;
        
        // Route based on context type and role
        if (this.role === 'admin') {
          // Admin role - go to level selection screen
          this.navigation.goTo('admin-level-selection');
        } else if (contextType === 'club') {
          // Non-admin club selected - go to division selection for this club
          this.navigation.goTo('division-selection', { 
            role: this.role, 
            clubId: contextId,
            clubName: contextName 
          });
        } else if (contextType === 'team') {
          // Non-admin team selected - go to team dashboard
          this.navigation.goTo('team-dashboard', { 
            role: this.role, 
            teamId: contextId,
            teamName: contextName 
          });
        }
      }
    });
  }
  
  loadContexts() {
    const listContainer = this.find('#context-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>';
    
    const user = this.auth.getUser();
    
    if (this.role === 'admin') {
      this.loadAdminContexts(user);
    } else if (this.role === 'coach') {
      this.loadCoachTeams(user);
    } else if (this.role === 'player') {
      this.loadPlayerTeams(user);
    }
  }
  
  loadAdminContexts(user) {
    const listContainer = this.find('#context-list');
    
    // Check if user has any admin privileges
    const endpoint = '/api/auth/admin/contexts';
    this.safeFetch(endpoint, response => {
      const contexts = response.data || [];
      
      if (contexts.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No admin privileges</p></div>';
        return;
      }
      
      // Show single "Administration" button that goes to level selection
      listContainer.innerHTML = `
        <button class="btn btn-lg btn-primary context-option" 
                data-context-id="admin" 
                data-context-name="Administration"
                data-context-type="admin"
                style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
          <h3 style="margin: 0; font-size: 1.2rem;">
            👨‍💼 Administration
          </h3>
          <p style="margin: var(--space-1) 0 0 0; opacity: 0.8; font-size: 0.9rem;">
            Manage system, clubs, teams, and more
          </p>
        </button>
      `;
    });
  }
  
  loadCoachTeams(user) {
    const listContainer = this.find('#context-list');
    
    // Get teams the user coaches
    const endpoint = '/api/auth/coach/teams';
    this.safeFetch(endpoint, response => {
      const teams = response.data || [];
      
      if (teams.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No teams to coach</p></div>';
        return;
      }
      
      this.renderList('#context-list', teams,
        team => `
          <button class="btn btn-lg btn-primary context-option" 
                  data-context-id="${team.id}" 
                  data-context-name="${team.display_name || team.name}"
                  data-context-type="team"
                  style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
            <h3 style="margin: 0; font-size: 1.2rem;">⚽ ${team.display_name || team.name}</h3>
            <p style="margin: var(--space-1) 0 0 0; opacity: 0.8; font-size: 0.9rem;">
              ${team.player_count ? team.player_count + ' players' : 'Team'}
            </p>
          </button>
        `,
        '<div class="empty-state"><p>No teams available</p></div>'
      );
    });
  }
  
  loadPlayerTeams(user) {
    const listContainer = this.find('#context-list');
    
    // Get teams the user is on
    const endpoint = '/api/auth/player/teams';
    this.safeFetch(endpoint, response => {
      const teams = response.data || [];
      
      if (teams.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>Not on any teams</p></div>';
        return;
      }
      
      this.renderList('#context-list', teams,
        team => `
          <button class="btn btn-lg btn-primary context-option" 
                  data-context-id="${team.id}" 
                  data-context-name="${team.display_name || team.name}"
                  data-context-type="team"
                  style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
            <h3 style="margin: 0; font-size: 1.2rem;">⚽ ${team.display_name || team.name}</h3>
            <p style="margin: var(--space-1) 0 0 0; opacity: 0.8; font-size: 0.9rem;">
              ${team.division_name ? team.division_name : 'Team'}
            </p>
          </button>
        `,
        '<div class="empty-state"><p>No teams available</p></div>'
      );
    });
  }
}
