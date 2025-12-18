// AdminClubScreen - Placeholder for club-level administration
class AdminClubScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-club';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="club-title">Club Administration</h1>
        <p class="subtitle" id="club-subtitle">Club-level admin features</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center; margin-bottom: var(--space-4);">
          <span style="font-size: 3rem; display: block; margin-bottom: var(--space-2);">🏢</span>
          <h2 id="club-name-display" style="margin-bottom: var(--space-2);">Club Name</h2>
          <p style="opacity: 0.8;">
            Admin level: <strong>CLUB</strong>
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
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';
    
    this.find('#club-title').textContent = this.clubName;
    this.find('#club-name-display').textContent = this.clubName;
    this.find('#club-subtitle').textContent = `Manage ${this.clubName}`;
    
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
      { id: 'users', icon: '👤', label: 'Users', description: 'Manage user accounts' },
      { id: 'players', icon: '⚽', label: 'Players', description: 'Manage player records' },
      { id: 'teams', icon: '👥', label: 'Teams', description: 'Manage teams' },
      { id: 'venues', icon: '🏟️', label: 'Venues', description: 'Manage venues' },
      { id: 'settings', icon: '⚙️', label: 'Settings', description: 'Club settings' }
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
    alert(`${section.toUpperCase()} management coming soon for ${this.clubName}`);
  }
}
