// DivisionSelectionScreen - choose which division to manage
class DivisionSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-division-selection';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Select Division</h1>
        <p class="subtitle">Which division would you like to manage?</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div id="division-list"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Store role for later use
    this.role = params?.role || this.navigation.context.role;
    
    this.loadDivisions();
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      // Handle back button
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Handle division selection
      const divisionBtn = e.target.closest('.division-option');
      if (divisionBtn) {
        const divisionId = divisionBtn.getAttribute('data-division-id');
        const divisionName = divisionBtn.getAttribute('data-division-name');
        
        const division = { id: divisionId, name: divisionName };
        this.navigation.context.division = division;
        this.navigation.goTo('division-menu', { role: this.role, division: division });
      }
    });
  }
  
  loadDivisions() {
    const listContainer = this.find('#division-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading divisions...</p></div>';
    
    // Fetch all divisions
    this.safeFetch('/api/divisions', response => {
      const divisions = response.data || [];
      
      if (divisions.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No divisions found</p></div>';
        return;
      }
      
      this.renderList('#division-list', divisions,
        d => `
          <button class="btn btn-lg btn-primary division-option" 
                  data-division-id="${d.id}" 
                  data-division-name="${d.display_name || d.name}"
                  style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
            <h3 style="margin: 0; font-size: 1.2rem;">${d.display_name || d.name}</h3>
            <p style="margin: var(--space-1) 0 0 0; opacity: 0.8; font-size: 0.9rem;">
              ${d.league_name ? `League: ${d.league_name}` : 'Select to manage'}
            </p>
          </button>
        `,
        '<div class="empty-state"><p>No divisions available</p></div>'
      );
    }, error => {
      listContainer.innerHTML = `
        <div class="empty-state">
          <p>⚠️ Failed to load divisions</p>
          <p class="text-muted">Please try again</p>
          <button class="btn btn-primary" onclick="location.reload()">Reload</button>
        </div>
      `;
    });
  }
}
