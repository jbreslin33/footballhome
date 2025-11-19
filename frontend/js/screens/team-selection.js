// TeamSelectionScreen - select which team to manage/rsvp
class TeamSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-team-selection';
    div.innerHTML = `
      <div class="card">
        <h2>Select Team</h2>
        <p class="text-gray-600">Choose the team you want to work with</p>
        <div id="team-list" style="margin-top: 20px;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    const listContainer = this.find('#team-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading teams...</p></div>';
    
    // Fetch teams for current user
    this.safeFetch('/api/user/teams', teams => {
      this.renderList('#team-list', teams,
        t => `
          <button class="team-btn" data-id="${t.id}" data-name="${t.name}">
            <span class="team-name">${t.name}</span>
            ${t.role ? `<span class="team-role">${t.role}</span>` : ''}
          </button>
        `,
        'No teams found. Please contact an administrator to be added to a team.'
      );
    });
    
    // Handle team selection
    this.element.addEventListener('click', (e) => {
      const btn = e.target.closest('.team-btn');
      if (btn) {
        const team = {
          id: parseInt(btn.getAttribute('data-id')),
          name: btn.getAttribute('data-name')
        };
        
        console.log('Selected team:', team);
        this.navigation.context.team = team;
        this.navigation.goTo('practice-options');
      }
    });
  }
}
