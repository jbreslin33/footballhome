// PracticeOptionsScreen - choose between managing or RSVPing to practices
class PracticeOptionsScreen extends Screen {
  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    const userRole = this.navigation.context.role; // 'coach', 'player', or 'parent'
    
    // Only coaches can manage practices and attendance
    const showManageButton = userRole === 'coach';
    
    const div = document.createElement('div');
    div.className = 'screen screen-practice-options';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>⚽ ${teamName} - Practices</h1>
        <p class="subtitle">What would you like to do?</p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-4); max-width: 500px; margin: 0 auto;">
        ${showManageButton ? `
          <button data-action="manage" class="btn btn-lg btn-primary">
            📝 Manage Practices
            <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
              Create, edit, and delete practices
            </small>
          </button>

          <button data-action="rsvp-management" class="btn btn-lg btn-primary">
            📋 Manage Player RSVPs
            <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
              View and update player RSVPs for practices
            </small>
          </button>
          
                    <button data-action="attendance" class="btn btn-lg btn-primary">
            📋 Manage Practice Attendance
            <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
              Track who attended each practice
            </small>
          </button>

          <button data-action="tactical-board" class="btn btn-lg btn-primary">
            🧠 Practice Tactics
            <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
              Create tactical boards for practices
            </small>
          </button>
        ` : ''}
        
        <button data-action="rsvp" class="btn btn-lg ${showManageButton ? 'btn-secondary' : 'btn-primary'}">
          ✓ RSVP to Practices
          <small style="display: block; font-weight: normal; margin-top: 5px; opacity: 0.9;">
            View and respond to scheduled practices
          </small>
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
        
        if (action === 'manage') {
          this.navigation.goTo('practice-management');
        } else if (action === 'rsvp-management') {
          this.navigation.goTo('practice-rsvp-management');
        } else if (action === 'attendance') {
          this.navigation.goTo('practice-attendance');
        } else if (action === 'tactical-board') {
          this.navigation.goTo('tactical-board', { 
            practiceTitle: 'General Practice Planning' 
          });
        } else if (action === 'rsvp') {
          this.navigation.goTo('practice-list');
        }
        return;
      }
      
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
