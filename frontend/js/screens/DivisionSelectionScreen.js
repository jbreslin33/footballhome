// DivisionSelectionScreen - choose which division to manage
class DivisionSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-division-selection';
    
    // Get user's club from auth context
    const user = this.auth.getUser();
    const clubName = user?.club_name || 'Your Club';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Select Division</h1>
        <p class="subtitle">Select a division in ${clubName}</p>
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
    
    // Get user's club from auth context
    const user = this.auth.getUser();
    const clubId = user?.club_id;
    const clubName = user?.club_name;
    
    if (!clubId) {
      listContainer.innerHTML = '<div class="empty-state"><p>No club associated with your account</p></div>';
      return;
    }
    
    // Fetch divisions for this club only
    const endpoint = `/api/clubs/${clubId}/divisions`;
    this.safeFetch(endpoint, response => {
      const divisions = response.data || [];
      
      if (divisions.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No divisions found for ' + clubName + '</p></div>';
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
              Select to manage
            </p>
          </button>
        `,
        '<div class="empty-state"><p>No divisions available</p></div>'
      );
    });
  }
}
