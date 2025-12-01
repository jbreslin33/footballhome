// TeamDashboardScreen - choose between practices or matches after selecting a team
class TeamDashboardScreen extends Screen {
  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-team-dashboard';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back to Teams</button>
        <h1>⚽ ${teamName}</h1>
        <p class="subtitle">What would you like to work with?</p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-3); max-width: 500px; margin: 0 auto;">
        <button data-action="roster" class="btn btn-lg btn-primary">
          👥 Manage Roster
        </button>
        
        <button data-action="practices" class="btn btn-lg btn-primary">
          ⚽ Practices
        </button>
        
        <button data-action="matches" class="btn btn-lg btn-primary">
          🏆 Matches
        </button>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.element.addEventListener('click', (e) => {
      const actionBtn = e.target.closest('[data-action]');
      if (actionBtn) {
        const action = actionBtn.getAttribute('data-action');
        
        if (action === 'roster') {
          this.navigation.goTo('roster-management');
        } else if (action === 'practices') {
          this.navigation.goTo('practice-options');
        } else if (action === 'matches') {
          this.navigation.goTo('match-options');
        }
        return;
      }
      
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
