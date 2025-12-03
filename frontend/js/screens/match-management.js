// MatchManagementScreen - list matches with add/edit/delete
class MatchManagementScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-match-management';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>🏆 Manage Matches</h1>
        <p class="subtitle">Create, edit, and delete matches</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <button id="add-match-btn" class="btn btn-lg btn-success" style="width: 100%; max-width: 500px; margin: 0 auto var(--space-4); display: flex; justify-content: center;">
          + Add New Match
        </button>
        
        <div id="match-list" class="match-cards"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadMatches();
    
    this.element.addEventListener('click', (e) => {
      // Add new match
      if (e.target.id === 'add-match-btn' || e.target.closest('#add-match-btn')) {
        this.navigation.goTo('match-form', { mode: 'create' });
        return;
      }
      
      // Edit match
      const editBtn = e.target.closest('[data-action="edit"]');
      if (editBtn) {
        const matchId = editBtn.getAttribute('data-id');
        this.navigation.goTo('match-form', { 
          mode: 'edit', 
          matchId: matchId 
        });
        return;
      }
      
      // Delete match
      const deleteBtn = e.target.closest('[data-action="delete"]');
      if (deleteBtn) {
        const matchId = deleteBtn.getAttribute('data-id');
        const matchTitle = deleteBtn.getAttribute('data-name');
        
        if (confirm(`Delete match "${matchTitle}"?`)) {
          this.deleteMatch(matchId);
        }
        return;
      }
      
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }
  
  loadMatches() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) {
      console.error('No team selected');
      return;
    }
    
    const listContainer = this.find('#match-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading matches...</p></div>';
    
    // Use include_past=true to get all matches, not just upcoming
    this.safeFetch(`/api/matches/team/${teamId}?include_past=true`, response => {
      // Extract matches from standardized response format
      const matches = response.data || [];
      
      // Transform event_date into separate date and time fields
      const transformedMatches = matches.map(m => {
        const eventDate = new Date(m.event_date);
        
        // Format date as relative or absolute
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);
        
        let dateDisplay;
        if (eventDate.toDateString() === today.toDateString()) {
          dateDisplay = 'Today';
        } else if (eventDate.toDateString() === tomorrow.toDateString()) {
          dateDisplay = 'Tomorrow';
        } else {
          dateDisplay = eventDate.toLocaleDateString('en-US', { 
            weekday: 'short', 
            month: 'short', 
            day: 'numeric' 
          });
        }
        
        // Determine status display
        let statusDisplay = '';
        let statusClass = '';
        if (m.match_status === 'completed') {
          statusDisplay = `${m.home_team_score || 0} - ${m.away_team_score || 0}`;
          statusClass = 'status-completed';
        } else if (m.match_status === 'in_progress') {
          statusDisplay = 'In Progress';
          statusClass = 'status-live';
        } else if (m.match_status === 'postponed') {
          statusDisplay = 'Postponed';
          statusClass = 'status-postponed';
        } else {
          statusDisplay = 'Scheduled';
          statusClass = 'status-scheduled';
        }
        
        return {
          ...m,
          dateDisplay: dateDisplay,
          time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          statusDisplay: statusDisplay,
          statusClass: statusClass
        };
      });
      
      this.renderList('#match-list', transformedMatches,
        m => {
          const homeLogo = m.home_team_logo 
            ? `<img src="${m.home_team_logo}" class="team-logo" alt="Home Team">`
            : `<div class="team-logo-placeholder">🏠</div>`;
            
          const awayLogo = m.away_team_logo 
            ? `<img src="${m.away_team_logo}" class="team-logo" alt="Away Team">`
            : `<div class="team-logo-placeholder">✈️</div>`;

          return `
          <div class="card match-card">
            <div class="match-logos">
              ${homeLogo}
              <span class="match-vs">VS</span>
              ${awayLogo}
            </div>
            <div class="match-card-header" style="text-align: center; justify-content: center; flex-direction: column; gap: var(--space-2);">
              <h3>${m.title}</h3>
              <span class="match-status ${m.statusClass}">${m.statusDisplay}</span>
            </div>
            
            <div class="match-card-meta">
              <div class="meta-item">
                <span class="meta-icon">📅</span>
                <span>${m.dateDisplay}</span>
              </div>
              <div class="meta-item">
                <span class="meta-icon">🕐</span>
                <span>${m.time}</span>
              </div>
              ${m.venue_name ? `
              <div class="meta-item">
                <span class="meta-icon">📍</span>
                <span>${m.venue_name}</span>
              </div>
              ` : ''}
              ${m.competition_name ? `
              <div class="meta-item">
                <span class="meta-icon">🏆</span>
                <span>${m.competition_name}</span>
              </div>
              ` : ''}
            </div>
            
            <div style="display: flex; gap: var(--space-3); margin-top: var(--space-4);">
              <button data-action="edit" data-id="${m.id}" class="btn btn-primary" style="flex: 1;">Edit</button>
              <button data-action="delete" data-id="${m.id}" data-name="${m.title}" class="btn btn-danger" style="flex: 1;">Delete</button>
            </div>
          </div>
        `; },
        '<div class="empty-state"><p>🏆 No matches scheduled yet</p><p class="text-muted">Click "Add New Match" to create one</p></div>'
      );
    });
  }
  
  deleteMatch(matchId) {
    this.auth.fetch(`/api/matches/${matchId}`, { 
      method: 'DELETE' 
    })
    .then(r => {
      if (!r.ok) throw new Error('Delete failed');
      console.log('Match deleted');
      this.loadMatches(); // Refresh list
    })
    .catch(err => {
      this.handleError(err, 'delete');
    });
  }
}
