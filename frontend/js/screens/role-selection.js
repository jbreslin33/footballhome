// RoleSelectionScreen - Choose which role to use (for now: Coach only)
class RoleSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-role-selection';
    
    const user = this.navigation.context.user;
    const userName = user?.name || user?.email || 'User';
    
    div.innerHTML = `
      <div class="screen-header">
        <h1>Welcome, ${this.escapeHtml(userName)}</h1>
        <p class="subtitle">Choose your role to continue</p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-4); max-width: 500px; margin: 0 auto;">
        <button class="btn btn-lg btn-primary" data-role="coach" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">🏈</span>
          <span style="flex: 1; text-align: left;">Coach</span>
        </button>
        
        <button class="btn btn-lg btn-primary" data-role="player" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">👟</span>
          <span style="flex: 1; text-align: left;">Player</span>
        </button>
        
        <button class="btn btn-text logout-btn" style="margin-top: var(--space-4);">Logout</button>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
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
    });
  }
  
  handleRoleSelection(role) {
    // Store selected role in navigation context and navigate
    if (role === 'coach' || role === 'player') {
      // For now, hardcode Lighthouse 1893 SC division UUID
      // TODO: Add proper division selection screen
      const division = { id: 'd37eb44b-8e47-0004-9060-f0cbe96fe089', name: 'Lighthouse 1893 SC' };
      this.navigation.context.division = division;
      
      // Go to division menu which splits between team and division management
      this.navigation.goTo('division-menu', { role: role, division: division });
    } else if (role === 'parent') {
      // Future: parent flow
      this.handleError(new Error('Parent role not yet implemented'), 'role-selection');
    }
  }
  
  handleLogout() {
    this.auth.logout();
    this.navigation.context = { user: null, role: null, team: null }; // Clear context
    this.navigation.updateContextHeader();
    this.navigation.goTo('login');
  }
  
  // Helper to escape HTML
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
