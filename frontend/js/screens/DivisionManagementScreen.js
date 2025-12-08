// DivisionManagementScreen - division-level management options
class DivisionManagementScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-division-management';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Manage Division</h1>
        <p class="subtitle" id="division-name-subtitle"></p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-3);">
        <button class="btn btn-lg btn-primary option-btn" data-target="division-roster">
          <h2>Division Roster</h2>
          <p style="margin: var(--space-2) 0 0 0; opacity: 0.8;">View and manage all players in the division</p>
        </button>
        <button class="btn btn-lg btn-secondary option-btn" disabled>
          <h2>Division Reports</h2>
          <p style="margin: var(--space-2) 0 0 0; opacity: 0.8;">Coming soon</p>
        </button>
        <button class="btn btn-lg btn-secondary option-btn" disabled>
          <h2>Division Settings</h2>
          <p style="margin: var(--space-2) 0 0 0; opacity: 0.8;">Coming soon</p>
        </button>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Expect params like {division: {id, name}}
    this.division = params?.division || this.navigation.context.division;
    
    if (this.division?.name) {
      const subtitle = this.find('#division-name-subtitle');
      if (subtitle) {
        subtitle.textContent = this.division.name;
      }
    }
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      // Handle back button
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const btn = e.target.closest('.option-btn:not([disabled])');
      if (btn) {
        const target = btn.getAttribute('data-target');
        this.navigation.goTo(target, {division: this.division});
      }
    });
  }
}
