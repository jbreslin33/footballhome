// AdminTeamScreen - Placeholder for team-level administration
class AdminTeamScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-team';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="team-title">Team Administration</h1>
        <p class="subtitle" id="team-subtitle">Team-level admin features</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center; margin-bottom: var(--space-4);">
          <span style="font-size: 3rem; display: block; margin-bottom: var(--space-2);">👥</span>
          <h2 id="team-name-display" style="margin-bottom: var(--space-2);">Team Name</h2>
          <p style="opacity: 0.8;">
            Admin level: <strong>TEAM</strong>
          </p>
        </div>
        
        <h3 style="margin-bottom: var(--space-3); opacity: 0.9;">Manage</h3>
        <div id="sub-navigation" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.teamId = params?.teamId;
    this.teamName = params?.teamName || 'Team';
    
    this.find('#team-title').textContent = this.teamName;
    this.find('#team-name-display').textContent = this.teamName;
    this.find('#team-subtitle').textContent = `Manage ${this.teamName}`;
    
    this.renderSubNavigation();
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const subNavBtn = e.target.closest('.sub-nav-btn');
      if (subNavBtn) {
        const section = subNavBtn.getAttribute('data-section');
        this.handleSubNavigation(section);
      }
    });
  }
  
  renderSubNavigation() {
    const subNav = this.find('#sub-navigation');
    
    const sections = [
      { id: 'roster', icon: '📋', label: 'Roster', description: 'Manage team roster' },
      { id: 'players', icon: '⚽', label: 'Players', description: 'Manage player records' },
      { id: 'coaches', icon: '👨‍🏫', label: 'Coaches', description: 'Manage coaching staff' },
      { id: 'practices', icon: '🏃', label: 'Practices', description: 'Practice schedule' },
      { id: 'matches', icon: '🏆', label: 'Matches', description: 'Match schedule' },
      { id: 'settings', icon: '⚙️', label: 'Settings', description: 'Team settings' }
    ];
    
    subNav.innerHTML = sections.map(section => `
      <button class="btn btn-lg btn-secondary sub-nav-btn" 
              data-section="${section.id}"
              style="height: auto; padding: var(--space-3); text-align: left;">
        <div style="font-size: 2rem; margin-bottom: var(--space-1);">${section.icon}</div>
        <div style="font-weight: 600; margin-bottom: var(--space-1);">${section.label}</div>
        <div style="opacity: 0.7; font-size: 0.85rem;">${section.description}</div>
      </button>
    `).join('');
  }
  
  handleSubNavigation(section) {
    // Placeholder - will implement actual navigation later
    alert(`${section.toUpperCase()} management coming soon for ${this.teamName}`);
  }
}
