// MatchOptionsScreen - choose between managing or RSVPing to matches
class MatchOptionsScreen extends Screen {
  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    const userRole = this.navigation.context.role; // 'coach', 'player', or 'parent'
    
    // Only coaches can manage matches and player RSVPs
    const isCoach = userRole === 'coach';
    const showManageButton = false; // Will enable later
    
    const div = document.createElement('div');
    div.className = 'screen screen-match-options';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back to Dashboard</button>
        <h1>🏆 ${teamName} Matches</h1>
        <p class="subtitle">What would you like to do?</p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-4); max-width: 500px; margin: 0 auto;">
        ${showManageButton ? `
          <button data-action="manage" class="btn btn-lg btn-primary">
            📝 Manage Matches
            <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
              Create, edit, and delete matches
            </small>
          </button>
        ` : ''}
        
        <button data-action="rsvp" class="btn btn-lg btn-primary">
          ✓ My RSVP
          <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
            View and respond to scheduled matches
          </small>
        </button>
        
        ${isCoach ? `
          <button data-action="manage-rsvps" class="btn btn-lg btn-secondary">
            📋 Manage Player RSVPs
            <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
              View and edit player availability for matches
            </small>
          </button>
        ` : ''}
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
        
        if (action === 'manage') {
          // Future: this.navigation.goTo('match-management');
          alert('Match management coming soon!');
        } else if (action === 'rsvp') {
          this.navigation.goTo('match-list');
        } else if (action === 'manage-rsvps') {
          this.navigation.goTo('match-rsvp-management');
        }
        return;
      }
      
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
