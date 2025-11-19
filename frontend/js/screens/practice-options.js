// PracticeOptionsScreen - choose between managing or RSVPing to practices
class PracticeOptionsScreen extends Screen {
  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-practice-options';
    div.innerHTML = `
      <div class="card">
        <h2>Practice Options</h2>
        <p class="text-gray-600">Team: <strong>${teamName}</strong></p>
        
        <div class="options-grid" style="margin-top: 30px; display: grid; gap: 15px;">
          <button data-action="manage" class="btn btn-primary btn-lg">
            📝 Manage Practices
            <small style="display: block; font-weight: normal; margin-top: 5px;">
              Create, edit, and delete practices
            </small>
          </button>
          
          <button data-action="rsvp" class="btn btn-secondary btn-lg">
            ✓ RSVP to Practices
            <small style="display: block; font-weight: normal; margin-top: 5px;">
              View and respond to scheduled practices
            </small>
          </button>
        </div>
        
        <button id="back-btn" class="btn btn-secondary" style="margin-top: 20px;">
          ← Back to Teams
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
