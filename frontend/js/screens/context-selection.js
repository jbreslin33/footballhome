// ContextSelectionScreen - pick a team to coach.
//
// Only ever reached one way: coach-home.js's "Teams" tile, always with
// role:'coach'. The admin/player branches this screen used to have
// (admin -> admin-level-selection/division-selection tree, player ->
// /api/auth/player/teams) were dead code — nothing ever called this
// screen with role='admin' or role='player' — and the admin tree they
// pointed at (division-selection, division-menu, division-management,
// division-roster, team-selection, admin-sport-division, admin-team)
// was itself all "coming soon" stubs. Removed 2026-08-15 rather than
// left dead; see admin-level-selection.js for the matching cleanup on
// the actual admin nav path (admin-club -> #teams).
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
    this.role = 'coach';
    this.navigation.context.role = this.role;

    this.find('#context-title').textContent = 'Select Team to Coach';
    this.find('#context-subtitle').textContent = 'Choose a team to manage as coach';

    this.loadCoachTeams();
    
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
        const clubId = contextBtn.getAttribute('data-club-id');
        const genderCategory = contextBtn.getAttribute('data-gender-category') || null;

        this.navigation.context.selectedContext = { id: contextId, name: contextName, type: 'team' };

        // loadCoachTeams() only ever renders 'team' options, so this is
        // the only outcome — team-dashboard picks the right coached team.
        this.navigation.goTo('team-dashboard', {
          role: this.role,
          team: {
            id: contextId,
            name: contextName,
            clubId: clubId,
            genderCategory: genderCategory
          }
        });
      }
    });
  }
  
  loadCoachTeams() {
    const listContainer = this.find('#context-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>';

    // Get teams the user coaches
    const endpoint = '/api/auth/coach/teams';
    this.safeFetch(endpoint, response => {
      const teams = response.data || [];
      
      if (teams.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No teams to coach</p></div>';
        return;
      }
      
      this.renderList('#context-list', teams,
        team => {
          // Prefer chat name if one exists, else fall back to display/team name.
          const label = team.chat_name || team.display_name || team.name;
          const subtitle = team.player_count
            ? `${team.player_count} player${team.player_count === 1 ? '' : 's'}`
            : 'Team';
          return `
            <button class="btn btn-lg btn-primary context-option"
                    data-context-id="${team.id}"
                    data-context-name="${label}"
                    data-context-type="team"
                    data-club-id="${team.club_id || ''}"
                    data-chat-id="${team.chat_id || ''}"
                    data-gender-category="${team.gender_category || ''}"
                    style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
              <h3 style="margin: 0; font-size: 1.2rem;">⚽ ${label}</h3>
              <p style="margin: var(--space-1) 0 0 0; opacity: 0.8; font-size: 0.9rem;">
                ${subtitle}
              </p>
            </button>
          `;
        },
        '<div class="empty-state"><p>No teams available</p></div>'
      );
    });
  }
}
