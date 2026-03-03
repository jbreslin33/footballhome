// ClubDetailScreen - Shows a club's teams with rosters and schedules
class ClubDetailScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-club-detail';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="club-title">Club</h1>
        <p class="subtitle" id="club-subtitle"></p>
      </div>
      
      <div id="club-content" style="padding: var(--space-3);">
        <div class="loading-state">
          <div class="spinner"></div>
          <p>Loading club details...</p>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';
    this.club = null;
    
    this.find('#club-title').textContent = this.clubName;
    
    this.loadClubDetail();
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      const teamHeader = e.target.closest('.team-toggle');
      if (teamHeader) {
        const teamSection = teamHeader.closest('.team-section');
        const content = teamSection.querySelector('.team-content');
        const arrow = teamHeader.querySelector('.toggle-arrow');
        if (content.style.display === 'none') {
          content.style.display = 'block';
          arrow.textContent = '▼';
        } else {
          content.style.display = 'none';
          arrow.textContent = '▶';
        }
      }
      
      const tabBtn = e.target.closest('.team-tab-btn');
      if (tabBtn) {
        const teamSection = tabBtn.closest('.team-section');
        const tabName = tabBtn.dataset.tab;
        
        // Update active tab
        teamSection.querySelectorAll('.team-tab-btn').forEach(b => b.classList.remove('active'));
        tabBtn.classList.add('active');
        
        // Show correct panel
        teamSection.querySelectorAll('.team-tab-panel').forEach(p => p.style.display = 'none');
        teamSection.querySelector(`.team-tab-panel[data-tab="${tabName}"]`).style.display = 'block';
      }
    });
  }
  
  loadClubDetail() {
    this.safeFetch(`/api/clubs/${this.clubId}`, (response) => {
      this.club = response.data;
      this.find('#club-title').textContent = this.club.name;
      this.find('#club-subtitle').textContent = `${this.club.teams.length} team${this.club.teams.length !== 1 ? 's' : ''}`;
      this.renderClubDetail();
    });
  }
  
  renderClubDetail() {
    const content = this.find('#club-content');
    const club = this.club;
    
    if (!club.teams || club.teams.length === 0) {
      content.innerHTML = '<p style="text-align: center; opacity: 0.7; padding: var(--space-4);">No teams found for this club</p>';
      return;
    }
    
    // Group teams by league
    const teamsByLeague = {};
    for (const team of club.teams) {
      const key = team.league_name;
      if (!teamsByLeague[key]) teamsByLeague[key] = [];
      teamsByLeague[key].push(team);
    }
    
    content.innerHTML = Object.entries(teamsByLeague).map(([league, teams]) => `
      <div style="margin-bottom: var(--space-4);">
        <h2 style="margin-bottom: var(--space-2); padding-bottom: var(--space-1); border-bottom: 2px solid var(--accent-primary);">
          ${league}
        </h2>
        ${teams.map(team => this.renderTeamSection(team)).join('')}
      </div>
    `).join('');
  }
  
  renderTeamSection(team) {
    return `
      <div class="team-section" style="margin-bottom: var(--space-3); background: var(--bg-secondary); border-radius: var(--radius-lg); border: 1px solid var(--border-primary); overflow: hidden;">
        <div class="team-toggle" style="padding: var(--space-3); cursor: pointer; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-weight: 600; font-size: 1.1rem;">${team.name}</div>
            <div style="font-size: 0.85rem; opacity: 0.7;">
              ${team.division_name} · ${team.season_name} · 
              ${team.player_count} player${team.player_count !== 1 ? 's' : ''} · 
              ${team.match_count} match${team.match_count !== 1 ? 'es' : ''}
            </div>
          </div>
          <span class="toggle-arrow" style="font-size: 1.2rem; opacity: 0.5;">▶</span>
        </div>
        
        <div class="team-content" style="display: none; padding: 0 var(--space-3) var(--space-3);">
          <div style="display: flex; gap: var(--space-1); margin-bottom: var(--space-2); border-bottom: 1px solid var(--border-primary);">
            <button class="team-tab-btn active" data-tab="roster" 
                    style="padding: var(--space-1) var(--space-2); border: none; background: none; cursor: pointer; font-weight: 600; border-bottom: 2px solid var(--accent-primary);">
              Roster (${team.roster.length})
            </button>
            <button class="team-tab-btn" data-tab="schedule"
                    style="padding: var(--space-1) var(--space-2); border: none; background: none; cursor: pointer; opacity: 0.7;">
              Schedule (${team.matches.length})
            </button>
          </div>
          
          <div class="team-tab-panel" data-tab="roster" style="display: block;">
            ${this.renderRoster(team.roster)}
          </div>
          <div class="team-tab-panel" data-tab="schedule" style="display: none;">
            ${this.renderSchedule(team.matches, team.name)}
          </div>
        </div>
      </div>
    `;
  }
  
  renderRoster(roster) {
    if (roster.length === 0) {
      return '<p style="opacity: 0.7; font-size: 0.9rem;">No players on roster</p>';
    }
    
    return `
      <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
        <thead>
          <tr style="border-bottom: 1px solid var(--border-primary); text-align: left;">
            <th style="padding: var(--space-1);">#</th>
            <th style="padding: var(--space-1);">Name</th>
          </tr>
        </thead>
        <tbody>
          ${roster.map(p => `
            <tr style="border-bottom: 1px solid var(--border-secondary);">
              <td style="padding: var(--space-1); opacity: 0.7;">${p.jersey_number || '-'}</td>
              <td style="padding: var(--space-1);">${p.last_name}, ${p.first_name}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    `;
  }
  
  renderSchedule(matches, teamName) {
    if (matches.length === 0) {
      return '<p style="opacity: 0.7; font-size: 0.9rem;">No matches scheduled</p>';
    }
    
    return `
      <div style="display: flex; flex-direction: column; gap: var(--space-1);">
        ${matches.map(m => {
          const isHome = m.home_team_name === teamName;
          const opponent = isHome ? m.away_team_name : m.home_team_name;
          const prefix = isHome ? 'vs' : '@';
          const hasScore = m.home_score !== null && m.away_score !== null;
          const score = hasScore ? `${m.home_score} - ${m.away_score}` : '';
          
          let resultClass = '';
          if (hasScore) {
            const teamScore = isHome ? m.home_score : m.away_score;
            const oppScore = isHome ? m.away_score : m.home_score;
            if (teamScore > oppScore) resultClass = 'color: var(--color-success, #28a745);';
            else if (teamScore < oppScore) resultClass = 'color: var(--color-danger, #dc3545);';
            else resultClass = 'opacity: 0.7;';
          }
          
          return `
            <div style="display: flex; align-items: center; gap: var(--space-2); padding: var(--space-1); border-bottom: 1px solid var(--border-secondary); font-size: 0.9rem;">
              <span style="min-width: 90px; opacity: 0.7;">${m.match_date}</span>
              <span style="min-width: 20px; opacity: 0.5;">${prefix}</span>
              <span style="flex: 1;">${opponent}</span>
              <span style="font-weight: 600; min-width: 50px; text-align: right; ${resultClass}">${score || m.match_status}</span>
            </div>
          `;
        }).join('')}
      </div>
    `;
  }
}
