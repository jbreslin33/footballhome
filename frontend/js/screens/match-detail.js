// MatchDetailScreen - display per-match player statistics
class MatchDetailScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-match-detail';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">
          ← Back
        </button>
        <h1 id="match-title">Match Details</h1>
      </div>
      
      <div id="match-stats-container" class="match-stats-container"></div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.matchId = params.matchId;
    this.matchTitle = params.matchTitle || 'Match Details';
    
    // Update title
    this.find('#match-title').textContent = this.matchTitle;
    
    this.loadMatchPlayerStats();
    
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
    });
  }
  
  loadMatchPlayerStats() {
    const container = this.find('#match-stats-container');
    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading match events...</p></div>';
    
    this.safeFetch(`/api/stats/matches/${this.matchId}/events`, response => {
      const events = response.data || [];
      
      if (events.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>No events recorded for this match.</p></div>';
        return;
      }
      
      this.renderMatchEvents(events);
    });
  }
  
  renderMatchEvents(events) {
    const container = this.find('#match-stats-container');
    container.innerHTML = `
      <div class="match-events-list">
        <h2>Match Events</h2>
        <table class="events-table">
          <thead>
            <tr>
              <th>Minute</th>
              <th>Player</th>
              <th>Team</th>
              <th>Event</th>
              <th>Details</th>
            </tr>
          </thead>
          <tbody>
            ${events.map(event => this.renderEventRow(event)).join('')}
          </tbody>
        </table>
      </div>
    `;
  }
  
  renderEventRow(event) {
    const eventIcon = this.getEventIcon(event.event_type);
    const details = event.assisted_by ? `Assist: ${this.escapeHtml(event.assisted_by)}` : '';
    
    return `
      <tr>
        <td class="minute-cell">${event.minute}'</td>
        <td class="player-cell">${this.escapeHtml(event.player_name)}</td>
        <td class="team-cell">${this.escapeHtml(event.team_name)}</td>
        <td class="event-cell">${eventIcon} ${this.escapeHtml(event.event_type)}</td>
        <td class="details-cell">${details}</td>
      </tr>
    `;
  }
  
  getEventIcon(eventType) {
    const icons = {
      'goal': '⚽',
      'assist': '🎯',
      'yellow_card': '🟨',
      'red_card': '🟥',
      'sub_in': '⬆️',
      'sub_out': '⬇️'
    };
    return icons[eventType] || '•';
  }
  
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
