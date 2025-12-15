// RoleSelectionScreen - Choose which role to use (Coach, Player, Admin)
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
        
        <button class="btn btn-lg btn-primary" data-role="admin" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">👨‍💼</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">Admin</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">Manage clubs & teams</div>
          </div>
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
    if (role === 'coach' || role === 'player' || role === 'admin') {
      this.navigation.context.role = role;
      this.navigation.goTo('context-selection', { role: role });
    } else {
      this.handleError(new Error('Unknown role: ' + role), 'role-selection');
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
