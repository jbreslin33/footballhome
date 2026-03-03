// ClubDirectoryScreen - Browse all clubs
class ClubDirectoryScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-club-directory';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Club Directory</h1>
        <p class="subtitle">All registered clubs</p>
      </div>
      
      <div style="padding: var(--space-3);">
        <div style="margin-bottom: var(--space-3);">
          <input type="text" id="club-search" placeholder="Search clubs..." 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--border-primary); border-radius: var(--radius-md); font-size: 1rem;">
        </div>
        <div id="club-list" class="loading-state">
          <div class="spinner"></div>
          <p>Loading clubs...</p>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter() {
    this.clubs = [];
    this.loadClubs();
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const clubCard = e.target.closest('.club-card');
      if (clubCard) {
        const clubId = clubCard.dataset.clubId;
        const club = this.clubs.find(c => String(c.id) === clubId);
        if (club) {
          this.navigation.goTo('club-detail', { clubId: club.id, clubName: club.name });
        }
      }
    });
    
    const searchInput = this.find('#club-search');
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.filterClubs(e.target.value);
      });
    }
  }
  
  loadClubs() {
    this.safeFetch('/api/clubs', (response) => {
      this.clubs = response.data || [];
      this.renderClubs(this.clubs);
    });
  }
  
  filterClubs(query) {
    const q = query.toLowerCase();
    const filtered = this.clubs.filter(c => 
      c.name.toLowerCase().includes(q) || 
      c.organization_name.toLowerCase().includes(q)
    );
    this.renderClubs(filtered);
  }
  
  renderClubs(clubs) {
    const container = this.find('#club-list');
    
    if (clubs.length === 0) {
      container.innerHTML = '<p style="text-align: center; opacity: 0.7; padding: var(--space-4);">No clubs found</p>';
      return;
    }
    
    container.innerHTML = `
      <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: var(--space-3);">
        ${clubs.map(club => `
          <div class="club-card" data-club-id="${club.id}" 
               style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-3); cursor: pointer; transition: transform 0.15s, box-shadow 0.15s; border: 1px solid var(--border-primary);">
            <div style="display: flex; align-items: center; gap: var(--space-2); margin-bottom: var(--space-2);">
              ${club.logo_url 
                ? `<img src="${club.logo_url}" alt="" style="width: 48px; height: 48px; border-radius: var(--radius-md); object-fit: cover;">` 
                : `<div style="width: 48px; height: 48px; border-radius: var(--radius-md); background: var(--accent-primary); display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: white;">⚽</div>`}
              <div>
                <div style="font-weight: 600; font-size: 1.1rem;">${club.name}</div>
                <div style="opacity: 0.7; font-size: 0.85rem;">${club.organization_name}</div>
              </div>
            </div>
            <div style="display: flex; gap: var(--space-3); font-size: 0.85rem; opacity: 0.8;">
              <span>👥 ${club.team_count} team${club.team_count !== 1 ? 's' : ''}</span>
              <span>⚽ ${club.player_count} player${club.player_count !== 1 ? 's' : ''}</span>
            </div>
          </div>
        `).join('')}
      </div>
    `;
  }
}
