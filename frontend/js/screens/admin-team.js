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
      
      <div style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center;">
          <span style="font-size: 4rem; display: block; margin-bottom: var(--space-3);">⚽</span>
          <h2 id="team-name-display" style="margin-bottom: var(--space-2);">Team Name</h2>
          <p style="opacity: 0.8; margin-bottom: var(--space-4);">
            Admin level: <strong>TEAM</strong>
          </p>
          <p style="opacity: 0.6;">
            Team administration features coming soon...
          </p>
        </div>
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
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
