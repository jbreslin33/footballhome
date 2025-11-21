// TeamSelectionScreen - select which team to manage/rsvp
class TeamSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-team-selection';
    div.innerHTML = `
      <div class="card">
        <button class="btn btn-text back-btn">← Back</button>
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
    this.safeFetch('/api/auth/user/teams', response => {
      // Backend returns {success, message, data: [...teams...]}
      const teams = response.data || [];
      
      this.renderList('#team-list', teams,
        t => `
          <button class="team-btn" data-id="${t.id}" data-name="${t.name}">
            <span class="team-name">${t.name}</span>
          </button>
        `,
        'No teams found. Please contact an administrator to be added to a team.'
      );
    });
    
    // Handle team selection
    this.element.addEventListener('click', (e) => {
      // Handle back button
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const btn = e.target.closest('.team-btn');
      if (btn) {
        const team = {
          id: btn.getAttribute('data-id'),
          name: btn.getAttribute('data-name')
        };
        
        console.log('Selected team:', team);
        this.navigation.goTo('practice-options', { team: team });
      }
    });
  }
}
