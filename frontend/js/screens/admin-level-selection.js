// AdminLevelSelectionScreen - choose which admin level to work with
class AdminLevelSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-level-selection';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Administration</h1>
        <p class="subtitle">Select admin level</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div id="level-list"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadAdminLevels();
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const levelBtn = e.target.closest('.level-option');
      if (levelBtn) {
        const levelType = levelBtn.getAttribute('data-level-type');
        const entityCount = parseInt(levelBtn.getAttribute('data-entity-count') || '0');
        
        // If only one entity at this level, go directly to it
        // Otherwise go to entity selection screen
        if (levelType === 'system' || levelType === 'super') {
          // System/Super admin - only one "entity" (the system itself)
          this.navigation.goTo('admin-system');
        } else if (entityCount === 1) {
          // Single entity - get it and navigate directly
          this.navigateToSingleEntity(levelType);
        } else {
          // Multiple entities - go to selection screen
          this.navigation.goTo('admin-entity-list', { levelType });
        }
      }
    });
  }
  
  navigateToSingleEntity(levelType) {
    // Get the single entity for this level and navigate directly
    const endpoint = '/api/auth/admin/contexts';
    this.safeFetch(endpoint, response => {
      const contexts = response.data || [];
      const entity = contexts.find(c => c.type === levelType);
      
      if (entity) {
        this.navigateToAdminScreen(levelType, entity);
      }
    });
  }
  
  navigateToAdminScreen(levelType, entity) {
    // /api/auth/admin/contexts only ever emits type 'super' or 'club'
    // (sport_division/league/conference/division/team admin levels were
    // never wired up backend-side — see AuthController::handleAdminContexts'
    // TODO). Keeping dead branches here for types that can never appear
    // just risks a "Screen not registered" crash if that ever changes
    // without this file being updated too.
    const routes = {
      club: { screen: 'admin-club', params: { clubId: entity.id, clubName: entity.display_name } },
    };
    
    const route = routes[levelType];
    if (route) {
      this.navigation.goTo(route.screen, route.params);
    }
  }
  
  loadAdminLevels() {
    const listContainer = this.find('#level-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>';
    
    // Get admin contexts and group by level
    const endpoint = '/api/auth/admin/contexts';
    this.safeFetch(endpoint, response => {
      const contexts = response.data || [];
      
      if (contexts.length === 0) {
        listContainer.innerHTML = '<div class="empty-state"><p>No admin privileges</p></div>';
        return;
      }
      
      // Group contexts by type
      const grouped = {};
      contexts.forEach(ctx => {
        if (!grouped[ctx.type]) {
          grouped[ctx.type] = [];
        }
        grouped[ctx.type].push(ctx);
      });
      
      // Define level configuration — only 'super'/'system'/'club' can ever
      // appear (see navigateToAdminScreen's comment on why the other
      // admin levels were removed from here rather than left dead).
      const levelConfig = {
        super: { icon: '🛡️', label: 'Super Admin', description: 'Global administration' },
        system: { icon: '👨‍💼', label: 'System', description: 'Global administration' },
        club: { icon: '🏢', label: 'Club', description: 'Club management' },
      };

      // Render level buttons
      const levels = Object.keys(grouped).sort((a, b) => {
        const order = ['super', 'system', 'club'];
        return order.indexOf(a) - order.indexOf(b);
      });
      
      let html = '';
      levels.forEach(levelType => {
        const config = levelConfig[levelType];
        const entities = grouped[levelType];
        const count = entities.length;
        
        html += `
          <button class="btn btn-lg btn-primary level-option" 
                  data-level-type="${levelType}"
                  data-entity-count="${count}"
                  style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <div>
                <h3 style="margin: 0; font-size: 1.2rem;">
                  ${config.icon} ${config.label}
                </h3>
                <p style="margin: var(--space-1) 0 0 0; opacity: 0.8; font-size: 0.9rem;">
                  ${config.description}
                </p>
              </div>
              <div style="text-align: right;">
                <span style="display: inline-block; background: rgba(255,255,255,0.2); border-radius: 12px; padding: 4px 12px; font-size: 0.9rem;">
                  ${count} ${count === 1 ? 'entity' : 'entities'}
                </span>
              </div>
            </div>
          </button>
        `;
      });
      
      listContainer.innerHTML = html;
    });
  }
}
