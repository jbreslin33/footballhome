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
      
      <div style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center;">
          <span style="font-size: 4rem; display: block; margin-bottom: var(--space-3);">🏢</span>
          <h2 id="club-name-display" style="margin-bottom: var(--space-2);">Club Name</h2>
          <p style="opacity: 0.8; margin-bottom: var(--space-4);">
            Admin level: <strong>CLUB</strong>
          </p>
          <p style="opacity: 0.6;">
            Club management features coming soon...
          </p>
        </div>
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
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
