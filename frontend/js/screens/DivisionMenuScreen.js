// DivisionMenuScreen - choose between managing teams or managing division
class DivisionMenuScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-division-menu';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Division Menu</h1>
        <p class="subtitle" id="division-name-subtitle"></p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-3);">
        <button class="btn btn-lg btn-primary menu-btn" data-target="team-selection">
          <h2>Manage Teams</h2>
          <p style="margin: var(--space-2) 0 0 0; opacity: 0.8;">Team rosters, schedules, and activities</p>
        </button>
        <button class="btn btn-lg btn-primary menu-btn" data-target="division-management">
          <h2>Manage Division</h2>
          <p style="margin: var(--space-2) 0 0 0; opacity: 0.8;">Division roster, reports, and settings</p>
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
      
      const btn = e.target.closest('.menu-btn');
      if (btn) {
        const target = btn.getAttribute('data-target');
        this.navigation.goTo(target, {division: this.division});
      }
    });
  }
}
