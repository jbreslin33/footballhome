// RosterDashboardScreen - overview of team roster by status category
class RosterDashboardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.roster = [];
    this.rosterStatuses = [];
  }

  render() {
    // Reset listener flag since we're creating a new element
    this._listenersAttached = false;
    
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-roster-dashboard';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>👥 ${teamName} Roster</h1>
        <p class="subtitle">Manage your team roster by category</p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div id="roster-loading" style="text-align: center; padding: var(--space-4);">
          <div class="spinner"></div>
          <p>Loading roster...</p>
        </div>
        
        <div id="roster-dashboard" style="display: none;">
          <!-- Categories will be rendered here -->
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  async onEnter(params) {
    const teamId = this.navigation.context.team?.id;
    
    // Load roster data and statuses
    await Promise.all([
      this.loadRoster(teamId),
      this.loadRosterStatuses()
    ]);
    
    this.renderDashboard();
    
    // Only attach event listener once
    if (!this._listenersAttached) {
      this._listenersAttached = true;
      this.element.addEventListener('click', (e) => {
        if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
          this.navigation.goBack();
          return;
        }
        
        // Handle category clicks
        const categoryBtn = e.target.closest('[data-category]');
        if (categoryBtn) {
          const category = categoryBtn.getAttribute('data-category');
          this.navigation.goTo('roster-category', { category });
          return;
        }
        
        // Handle add player button
        if (e.target.id === 'add-player-btn' || e.target.closest('#add-player-btn')) {
          this.navigation.goTo('roster-add-player');
          return;
        }
      });
    }
  }
  
  async loadRoster(teamId) {
    try {
      const response = await this.auth.fetch(`/api/teams/${teamId}/roster`);
      const result = await response.json();
      this.roster = result.data || [];
    } catch (error) {
      console.error('Error loading roster:', error);
      this.roster = [];
    }
  }
  
  async loadRosterStatuses() {
    try {
      const response = await this.auth.fetch('/api/teams/roster-statuses');
      const result = await response.json();
      this.rosterStatuses = result.data || [];
    } catch (error) {
      console.error('Error loading roster statuses:', error);
      this.rosterStatuses = [];
    }
  }
  
  renderDashboard() {
    // Hide loading, show dashboard
    this.element.querySelector('#roster-loading').style.display = 'none';
    this.element.querySelector('#roster-dashboard').style.display = 'block';
    
    const container = this.element.querySelector('#roster-dashboard');
    
    // Get players only (not coaches)
    const players = this.roster.filter(m => m.roleType === 'PLAYER');
    const coaches = this.roster.filter(m => m.roleType === 'COACH');
    
    // Group players by status category
    const categories = this.groupByCategory(players);
    
    let html = '';
    
    // Official Roster Section
    const officialCount = categories.official.length;
    const activeCount = players.filter(p => p.rosterStatusCode === 'active').length;
    const inactiveCount = players.filter(p => p.rosterStatusCode === 'official_inactive').length;
    
    html += `
      <div class="roster-section" style="margin-bottom: var(--space-4);">
        <h2 style="font-size: 1.3rem; margin-bottom: var(--space-3); color: var(--color-primary);">
          📋 Official Roster (${officialCount})
        </h2>
        <div style="display: flex; flex-direction: column; gap: var(--space-2);">
          <button data-category="active" class="roster-category-btn" style="
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--space-3); background: var(--color-background-secondary);
            border: 1px solid var(--color-border); border-radius: 8px;
            cursor: pointer; text-align: left;
          ">
            <span>✅ Active Players</span>
            <span class="badge" style="background: var(--color-success); color: white; padding: 4px 12px; border-radius: 12px; font-weight: bold;">${activeCount}</span>
          </button>
          <button data-category="official_inactive" class="roster-category-btn" style="
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--space-3); background: var(--color-background-secondary);
            border: 1px solid var(--color-border); border-radius: 8px;
            cursor: pointer; text-align: left;
          ">
            <span>📝 Registered (Inactive)</span>
            <span class="badge" style="background: var(--color-warning); color: black; padding: 4px 12px; border-radius: 12px; font-weight: bold;">${inactiveCount}</span>
          </button>
        </div>
      </div>
    `;
    
    // Training Squad Section
    const trialCount = players.filter(p => p.rosterStatusCode === 'trial').length;
    const injuredCount = players.filter(p => p.rosterStatusCode === 'injured_reserve').length;
    const trainingCount = trialCount + injuredCount;
    
    html += `
      <div class="roster-section" style="margin-bottom: var(--space-4);">
        <h2 style="font-size: 1.3rem; margin-bottom: var(--space-3); color: var(--color-primary);">
          🏃 Training Squad (${trainingCount})
        </h2>
        <div style="display: flex; flex-direction: column; gap: var(--space-2);">
          <button data-category="trial" class="roster-category-btn" style="
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--space-3); background: var(--color-background-secondary);
            border: 1px solid var(--color-border); border-radius: 8px;
            cursor: pointer; text-align: left;
          ">
            <span>🔄 On Trial</span>
            <span class="badge" style="background: var(--color-info); color: white; padding: 4px 12px; border-radius: 12px; font-weight: bold;">${trialCount}</span>
          </button>
          <button data-category="injured_reserve" class="roster-category-btn" style="
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--space-3); background: var(--color-background-secondary);
            border: 1px solid var(--color-border); border-radius: 8px;
            cursor: pointer; text-align: left;
          ">
            <span>🏥 Injured Reserve</span>
            <span class="badge" style="background: var(--color-danger); color: white; padding: 4px 12px; border-radius: 12px; font-weight: bold;">${injuredCount}</span>
          </button>
        </div>
      </div>
    `;
    
    // Not Active Section
    const suspendedCount = players.filter(p => p.rosterStatusCode === 'suspended').length;
    const departedCount = players.filter(p => p.rosterStatusCode === 'departed' || !p.isActive).length;
    const notActiveCount = suspendedCount + departedCount;
    
    html += `
      <div class="roster-section" style="margin-bottom: var(--space-4);">
        <h2 style="font-size: 1.3rem; margin-bottom: var(--space-3); color: var(--color-text-secondary);">
          ❌ Not Active (${notActiveCount})
        </h2>
        <div style="display: flex; flex-direction: column; gap: var(--space-2);">
          <button data-category="suspended" class="roster-category-btn" style="
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--space-3); background: var(--color-background-secondary);
            border: 1px solid var(--color-border); border-radius: 8px;
            cursor: pointer; text-align: left;
          ">
            <span>⚠️ Suspended</span>
            <span class="badge" style="background: #666; color: white; padding: 4px 12px; border-radius: 12px; font-weight: bold;">${suspendedCount}</span>
          </button>
          <button data-category="departed" class="roster-category-btn" style="
            display: flex; justify-content: space-between; align-items: center;
            padding: var(--space-3); background: var(--color-background-secondary);
            border: 1px solid var(--color-border); border-radius: 8px;
            cursor: pointer; text-align: left;
          ">
            <span>👋 Departed</span>
            <span class="badge" style="background: #999; color: white; padding: 4px 12px; border-radius: 12px; font-weight: bold;">${departedCount}</span>
          </button>
        </div>
      </div>
    `;
    
    // Coaching Staff Section
    if (coaches.length > 0) {
      html += `
        <div class="roster-section" style="margin-bottom: var(--space-4);">
          <h2 style="font-size: 1.3rem; margin-bottom: var(--space-3); color: var(--color-primary);">
            👨‍🏫 Coaching Staff (${coaches.length})
          </h2>
          <div style="background: var(--color-background-secondary); border: 1px solid var(--color-border); border-radius: 8px; padding: var(--space-3);">
            ${coaches.map(coach => `
              <div style="padding: var(--space-2) 0; border-bottom: 1px solid var(--color-border);">
                <strong>${coach.name}</strong>
                <span style="color: var(--color-text-secondary); margin-left: var(--space-2);">${coach.position}</span>
              </div>
            `).join('')}
          </div>
        </div>
      `;
    }
    
    // Add Player Button
    html += `
      <div style="margin-top: var(--space-4); padding-top: var(--space-4); border-top: 2px solid var(--color-border);">
        <button id="add-player-btn" class="btn btn-primary btn-lg" style="width: 100%;">
          ➕ Add Player to Roster
        </button>
      </div>
    `;
    
    container.innerHTML = html;
  }
  
  groupByCategory(players) {
    return {
      official: players.filter(p => p.showInOfficialRoster),
      training: players.filter(p => p.showInRsvp && !p.showInOfficialRoster),
      inactive: players.filter(p => !p.showInRsvp && !p.showInOfficialRoster)
    };
  }
}
