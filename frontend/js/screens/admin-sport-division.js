// AdminSportDivisionScreen - Placeholder for sport division-level administration
class AdminSportDivisionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-sport-division';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="division-title">Sport Division Administration</h1>
        <p class="subtitle" id="division-subtitle">Sport division-level admin features</p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center;">
          <span style="font-size: 4rem; display: block; margin-bottom: var(--space-3);">⚽</span>
          <h2 id="division-name-display" style="margin-bottom: var(--space-2);">Sport Division Name</h2>
          <p style="opacity: 0.8; margin-bottom: var(--space-4);">
            Admin level: <strong>SPORT DIVISION</strong>
          </p>
          <p style="opacity: 0.6;">
            Sport division management features coming soon...
          </p>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.sportDivisionId = params?.sportDivisionId;
    this.sportDivisionName = params?.sportDivisionName || 'Sport Division';
    
    this.find('#division-title').textContent = this.sportDivisionName;
    this.find('#division-name-display').textContent = this.sportDivisionName;
    this.find('#division-subtitle').textContent = `Manage ${this.sportDivisionName}`;
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
