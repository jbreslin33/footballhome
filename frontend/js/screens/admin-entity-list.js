// AdminEntityListScreen - select which entity to administer when multiple exist at a level
class AdminEntityListScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-entity-list';
    
    div.innerHTML = `
      <div style="padding: var(--space-4);">
        <div id="entity-list"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.levelType = params?.levelType;
    
    if (!this.levelType) {
      console.error('No levelType provided');
      this.navigation.goBack();
      return;
    }
    
    this.loadEntities();
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      const entityBtn = e.target.closest('.entity-option');
      if (entityBtn) {
        const entityId = entityBtn.getAttribute('data-entity-id');
        const entityName = entityBtn.getAttribute('data-entity-name');
        
        this.navigateToAdminScreen(entityId, entityName);
      }
    });
  }
  
  navigateToAdminScreen(entityId, entityName) {
    const routes = {
      club: { screen: 'admin-club', params: { clubId: entityId, clubName: entityName } },
    };
    
    const route = routes[this.levelType];
    if (route) {
      this.navigation.goTo(route.screen, route.params);
    }
  }
  
  loadEntities() {
    const listContainer = this.find('#entity-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>';
    
    // Get admin contexts and filter by this level type
    const endpoint = '/api/auth/admin/contexts';
    this.safeFetch(endpoint, response => {
      const contexts = response.data || [];
      const entities = contexts.filter(c => c.type === this.levelType);
      
      if (entities.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No entities found</p></div>';
        return;
      }
      
      // Render entity buttons
      let html = '';
      entities.forEach(entity => {
        const icon = this.getIconForType(this.levelType);
        html += `
          <button class="btn btn-lg btn-primary entity-option" 
                  data-entity-id="${entity.id}"
                  data-entity-name="${entity.display_name || entity.name}"
                  style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
            <h3 style="margin: 0; font-size: 1.2rem;">
              ${icon} ${entity.display_name || entity.name}
            </h3>
          </button>
        `;
      });
      
      listContainer.innerHTML = html;
    });
  }
  
  getIconForType(type) {
    const icons = {
      club: '🏢',
    };
    return icons[type] || '📋';
  }
}
