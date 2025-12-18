// AdminEntityListScreen - select which entity to administer when multiple exist at a level
class AdminEntityListScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-entity-list';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="entity-list-title">Select Entity</h1>
        <p class="subtitle" id="entity-list-subtitle"></p>
      </div>
      
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
    
    // Set title based on level type
    const levelConfig = {
      club: { icon: '🏢', label: 'Clubs', singular: 'Club' },
      sport_division: { icon: '⚽', label: 'Sport Divisions', singular: 'Sport Division' },
      league: { icon: '🏆', label: 'Leagues', singular: 'League' },
      conference: { icon: '📋', label: 'Conferences', singular: 'Conference' },
      division: { icon: '📊', label: 'Divisions', singular: 'Division' },
      team: { icon: '👥', label: 'Teams', singular: 'Team' }
    };
    
    const config = levelConfig[this.levelType];
    if (config) {
      this.find('#entity-list-title').textContent = `Select ${config.singular}`;
      this.find('#entity-list-subtitle').textContent = `Choose a ${config.singular.toLowerCase()} to administer`;
    }
    
    this.loadEntities();
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
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
      sport_division: { screen: 'admin-sport-division', params: { sportDivisionId: entityId, sportDivisionName: entityName } },
      league: { screen: 'admin-league', params: { leagueId: entityId, leagueName: entityName } },
      conference: { screen: 'admin-conference', params: { conferenceId: entityId, conferenceName: entityName } },
      division: { screen: 'admin-division', params: { divisionId: entityId, divisionName: entityName } },
      team: { screen: 'admin-team', params: { teamId: entityId, teamName: entityName } }
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
      sport_division: '⚽',
      league: '🏆',
      conference: '📋',
      division: '📊',
      team: '👥'
    };
    return icons[type] || '📋';
  }
}
