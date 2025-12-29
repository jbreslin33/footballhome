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
    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading player stats...</p></div>';
    
    this.safeFetch(`/api/stats/matches/${this.matchId}/player-stats`, response => {
      const data = response.data || {};
      const teams = data.teams || [];
      
      if (teams.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>No player statistics available for this match.</p></div>';
        return;
      }
      
      this.renderPlayerStats(teams);
    });
  }
  
  renderPlayerStats(teams) {
    const container = this.find('#match-stats-container');
    container.innerHTML = '';
    
    // Render each team
    teams.forEach(team => {
      const teamSection = document.createElement('div');
      teamSection.className = 'team-stats-section';
      
      // Split players into starters and substitutes
      const starters = team.players.filter(p => p.is_starter);
      const substitutes = team.players.filter(p => !p.is_starter);
      
      teamSection.innerHTML = `
        <h2 class="team-name">${this.escapeHtml(team.team_name)}</h2>
        
        ${starters.length > 0 ? `
          <div class="player-group">
            <h3 class="group-label">Starters</h3>
            <table class="player-stats-table">
              <thead>
                <tr>
                  <th>Player</th>
                  <th>G</th>
                  <th>A</th>
                  <th>YC</th>
                  <th>RC</th>
                  <th>Sub</th>
                </tr>
              </thead>
              <tbody>
                ${starters.map(player => this.renderPlayerRow(player)).join('')}
              </tbody>
            </table>
          </div>
        ` : ''}
        
        ${substitutes.length > 0 ? `
          <div class="player-group">
            <h3 class="group-label">Substitutes</h3>
            <table class="player-stats-table">
              <thead>
                <tr>
                  <th>Player</th>
                  <th>G</th>
                  <th>A</th>
                  <th>YC</th>
                  <th>RC</th>
                  <th>Sub</th>
                </tr>
              </thead>
              <tbody>
                ${substitutes.map(player => this.renderPlayerRow(player)).join('')}
              </tbody>
            </table>
          </div>
        ` : ''}
      `;
      
      container.appendChild(teamSection);
    });
  }
  
  renderPlayerRow(player) {
    // Format substitution info
    let subInfo = '-';
    if (player.sub_in_minute !== null) {
      subInfo = `⬆️${player.sub_in_minute}'`;
    } else if (player.sub_out_minute !== null) {
      subInfo = `⬇️${player.sub_out_minute}'`;
    }
    
    return `
      <tr>
        <td class="player-name">${this.escapeHtml(player.player_name)}</td>
        <td class="stat-value">${player.goals || 0}</td>
        <td class="stat-value">${player.assists || 0}</td>
        <td class="stat-value">${player.yellow_cards || 0}</td>
        <td class="stat-value">${player.red_cards || 0}</td>
        <td class="stat-value sub-info">${subInfo}</td>
      </tr>
    `;
  }
  
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
