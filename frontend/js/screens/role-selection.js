// RoleSelectionScreen - Choose which role to use (for now: Coach only)
class RoleSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-role-selection';
    
    const user = this.navigation.context.user;
    const userName = user?.name || user?.email || 'User';
    
    div.innerHTML = `
      <div class="card">
        <h2>Welcome, ${this.escapeHtml(userName)}</h2>
        <p>Select your role:</p>
        
        <div class="role-options">
          <button class="btn btn-primary btn-large" data-role="coach">
            <span class="role-icon">🏈</span>
            <span class="role-label">Coach</span>
          </button>
          
          <!-- Player role will be added later -->
          <!-- 
          <button class="btn btn-primary btn-large" data-role="player">
            <span class="role-icon">👟</span>
            <span class="role-label">Player</span>
          </button>
          -->
        </div>
        
        <button class="btn btn-text logout-btn">Logout</button>
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
    if (role === 'coach') {
      // Go to team selection for coach
      this.navigation.goTo('team-selection', { role: role });
    } else if (role === 'player') {
      // Future: player flow
      this.handleError(new Error('Player role not yet implemented'), 'role-selection');
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
