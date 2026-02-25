// TeamDashboardScreen - tabbed team page with Schedule, Roster, Standings, Chat
class TeamDashboardScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-team-dashboard';
    div.innerHTML = `
      <div class="screen-header team-page-header">
        <button id="back-btn" class="btn btn-secondary btn-sm">← Back</button>
        <h1 id="team-title">Team</h1>
      </div>
      
      <div class="team-tabs">
        <button class="team-tab active" data-tab="schedule">Schedule</button>
        <button class="team-tab" data-tab="roster">Roster</button>
        <button class="team-tab" data-tab="standings">Standings</button>
        <button class="team-tab" data-tab="chat">Chat</button>
      </div>
      
      <div class="team-tab-content">
        <div id="tab-schedule" class="tab-panel active">
          <div id="schedule-list" class="match-cards"></div>
        </div>
        
        <div id="tab-roster" class="tab-panel" style="display:none;">
          <div id="roster-content"></div>
        </div>
        
        <div id="tab-standings" class="tab-panel" style="display:none;">
          <div id="standings-content"></div>
        </div>
        
        <div id="tab-chat" class="tab-panel" style="display:none;">
          <div id="chat-content"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.activeTab = 'schedule';
    this.matchesLoaded = false;
    this.rosterLoaded = false;
    this.standingsLoaded = false;
    
    // Set team context
    if (params?.team) {
      this.navigation.context.team = params.team;
    } else if (params?.teamId && params?.teamName) {
      this.navigation.context.team = {
        id: params.teamId,
        name: params.teamName,
        clubId: params.clubId || null
      };
    }
    
    const titleEl = this.find('#team-title');
    if (titleEl && this.navigation.context.team) {
      titleEl.textContent = this.navigation.context.team.name;
    }
    
    // Load schedule by default
    this.loadSchedule();
    
    // Event delegation
    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Tab switching
      const tab = e.target.closest('.team-tab');
      if (tab) {
        this.switchTab(tab.getAttribute('data-tab'));
        return;
      }
      
      // RSVP buttons
      const rsvpBtn = e.target.closest('[data-action="rsvp"]');
      if (rsvpBtn) {
        const matchId = rsvpBtn.getAttribute('data-id');
        const status = rsvpBtn.getAttribute('data-status');
        this.handleRSVP(matchId, status);
        return;
      }
      
      // Match stats button
      const statsBtn = e.target.closest('[data-action="stats"]');
      if (statsBtn) {
        this.navigation.goTo('match-detail', {
          matchId: statsBtn.getAttribute('data-id'),
          matchTitle: statsBtn.getAttribute('data-title')
        });
        return;
      }
      
      // Tactics button
      const tacticsBtn = e.target.closest('[data-action="tactics"]');
      if (tacticsBtn) {
        this.navigation.goTo('tactical-board', {
          matchId: tacticsBtn.getAttribute('data-id'),
          matchTitle: tacticsBtn.getAttribute('data-title'),
          team: this.navigation.context.team
        });
        return;
      }
      
      // Manage roster button
      const manageBtn = e.target.closest('[data-action="manage-roster"]');
      if (manageBtn) {
        this.navigation.goTo('roster-dashboard');
        return;
      }
      
      // Practices button
      const practicesBtn = e.target.closest('[data-action="practices"]');
      if (practicesBtn) {
        this.navigation.goTo('practice-options');
        return;
      }
    });
  }
  
  // --- Tab Management ---
  
  switchTab(tabName) {
    if (this.activeTab === tabName) return;
    this.activeTab = tabName;
    
    // Update tab buttons
    this.element.querySelectorAll('.team-tab').forEach(t => t.classList.remove('active'));
    this.element.querySelector(`.team-tab[data-tab="${tabName}"]`)?.classList.add('active');
    
    // Update panels
    this.element.querySelectorAll('.tab-panel').forEach(p => {
      p.style.display = 'none';
      p.classList.remove('active');
    });
    const panel = this.find(`#tab-${tabName}`);
    if (panel) {
      panel.style.display = '';
      panel.classList.add('active');
    }
    
    // Lazy-load tab data
    if (tabName === 'schedule' && !this.matchesLoaded) this.loadSchedule();
    if (tabName === 'roster' && !this.rosterLoaded) this.loadRoster();
    if (tabName === 'standings' && !this.standingsLoaded) this.loadStandings();
    if (tabName === 'chat') this.loadChat();
  }
  
  // --- Schedule Tab ---
  
  loadSchedule() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) return;
    
    const container = this.find('#schedule-list');
    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading schedule...</p></div>';
    
    this.safeFetch(`/api/matches/team/${teamId}`, response => {
      const matches = response.data || [];
      this.matchesLoaded = true;
      this.loadMatchesWithRSVP(matches);
    });
  }
  
  async loadMatchesWithRSVP(matches) {
    const userId = this.auth.getUser()?.id;
    const roleType = this.navigation.context.role;
    
    if (!userId || !roleType) {
      this.renderSchedule(matches);
      return;
    }
    
    const matchesWithRSVP = await Promise.all(
      matches.map(async (match) => {
        try {
          const response = await this.auth.fetch(`/api/events/${match.id}/rsvps?role_type=${roleType}`);
          const data = await response.json();
          if (data.success && data.data) {
            const userRsvp = data.data.find(rsvp => rsvp.user_id === userId);
            match.userRsvpStatus = userRsvp ? userRsvp.status : null;
            match.rsvpCount = data.data.length;
          }
        } catch (err) {
          console.error(`Failed to load RSVP for match ${match.id}:`, err);
        }
        return match;
      })
    );
    
    this.renderSchedule(matchesWithRSVP);
  }
  
  renderSchedule(matches) {
    const transformed = matches.map(m => {
      const eventDate = new Date(m.event_date);
      const today = new Date();
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      let dateDisplay;
      if (eventDate.toDateString() === today.toDateString()) {
        dateDisplay = 'Today';
      } else if (eventDate.toDateString() === tomorrow.toDateString()) {
        dateDisplay = 'Tomorrow';
      } else {
        dateDisplay = eventDate.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
      }
      
      return {
        ...m,
        dateDisplay,
        time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
    });
    
    this.renderList('#schedule-list', transformed,
      m => {
        const attendingClass = m.userRsvpStatus === 'attending' ? 'btn-success' : 'btn-secondary';
        const notAttendingClass = m.userRsvpStatus === 'not_attending' ? 'btn-danger' : 'btn-secondary';
        
        const scoreDisplay = (m.home_team_score != null) && (m.away_team_score != null)
          ? `<div class="match-score">
              <span class="score">${m.home_team_score} - ${m.away_team_score}</span>
            </div>` : '';
        
        const homeLogo = m.home_team_logo 
          ? `<img src="${m.home_team_logo}" class="team-logo" alt="Home">`
          : `<div class="team-logo-placeholder">H</div>`;
        const awayLogo = m.away_team_logo 
          ? `<img src="${m.away_team_logo}" class="team-logo" alt="Away">`
          : `<div class="team-logo-placeholder">A</div>`;
        
        const rsvpSection = m.has_ended ? '' : `
          <div class="match-card-actions">
            <button data-action="rsvp" data-id="${m.id}" data-status="attending"
              class="btn btn-sm ${attendingClass}">
              ✓ Attending
            </button>
            <button data-action="rsvp" data-id="${m.id}" data-status="not_attending"
              class="btn btn-sm ${notAttendingClass}">
              ✗ Can't Make It
            </button>
          </div>`;
        
        return `
          <div class="card match-card">
            <div class="match-logos">
              ${homeLogo}
              <span class="match-vs">VS</span>
              ${awayLogo}
            </div>
            <div class="match-card-header" style="text-align:center;">
              <h3 style="font-size:var(--text-base); margin:0;">${m.title}</h3>
              ${m.rsvpCount ? `<span class="badge badge-info" style="margin-top:var(--space-1);">${m.rsvpCount} responses</span>` : ''}
            </div>
            ${scoreDisplay}
            <div class="match-card-meta">
              <div class="meta-item"><span class="meta-icon">📅</span><span>${m.dateDisplay}</span></div>
              <div class="meta-item"><span class="meta-icon">🕐</span><span>${m.time}</span></div>
              ${m.venue_name ? `<div class="meta-item"><span class="meta-icon">📍</span><span>${m.venue_name}</span></div>` : ''}
            </div>
            ${rsvpSection}
            <div class="match-card-actions" style="margin-top:var(--space-2); border-top:1px solid var(--gray-200); padding-top:var(--space-2); display:grid; grid-template-columns:1fr 1fr; gap:var(--space-2);">
              <button data-action="stats" data-id="${m.id}" data-title="${m.title}" class="btn btn-secondary btn-sm">📊 Stats</button>
              <button data-action="tactics" data-id="${m.id}" data-title="${m.title}" class="btn btn-secondary btn-sm">📋 Tactics</button>
            </div>
          </div>
        `;
      },
      '<div class="empty-state"><p>No matches scheduled</p><p class="text-muted">Check back later for upcoming matches</p></div>'
    );
  }
  
  handleRSVP(matchId, status) {
    const userId = this.auth.getUser()?.id;
    const roleType = this.navigation.context.role;
    
    if (!userId || !roleType) {
      alert('Unable to record RSVP. Please log in again.');
      return;
    }
    
    this.auth.fetch(`/api/events/${matchId}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user_id: userId, role_type: roleType, status, notes: '' })
    })
    .then(r => { if (!r.ok) throw new Error('RSVP failed'); return r.json(); })
    .then(() => { this.matchesLoaded = false; this.loadSchedule(); })
    .catch(err => this.handleError(err, 'rsvp'));
  }
  
  // --- Roster Tab ---
  
  loadRoster() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) return;
    
    const container = this.find('#roster-content');
    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading roster...</p></div>';
    
    this.safeFetch(`/api/teams/${teamId}/roster`, response => {
      const players = response.data || [];
      this.rosterLoaded = true;
      this.renderRoster(players);
    });
  }
  
  renderRoster(players) {
    const container = this.find('#roster-content');
    
    if (!players.length) {
      container.innerHTML = '<div class="empty-state"><p>No players on roster</p></div>';
      return;
    }
    
    // Separate coaches and players
    const coaches = players.filter(p => p.roleType === 'COACH');
    const rosterPlayers = players.filter(p => p.roleType !== 'COACH');
    
    let html = '';
    
    // Quick actions
    const role = this.navigation.context.role;
    if (role === 'coach') {
      html += `
        <div style="padding:var(--space-4) var(--space-4) 0;">
          <button data-action="manage-roster" class="btn btn-primary btn-sm" style="width:auto;">
            ⚙️ Manage Roster
          </button>
        </div>`;
    }
    
    // Coaches section
    if (coaches.length > 0) {
      html += `<div class="roster-section">
        <h3 class="roster-section-title">Coaching Staff</h3>`;
      coaches.forEach(c => {
        html += this.renderRosterCard(c, true);
      });
      html += `</div>`;
    }
    
    // Players section
    html += `<div class="roster-section">
      <h3 class="roster-section-title">Players <span class="badge badge-info">${rosterPlayers.length}</span></h3>`;
    rosterPlayers.forEach(p => {
      html += this.renderRosterCard(p, false);
    });
    html += `</div>`;
    
    container.innerHTML = html;
  }
  
  renderRosterCard(player, isCoach) {
    const jersey = player.jerseyNumber != null ? `<span class="roster-jersey">#${player.jerseyNumber}</span>` : '';
    const position = player.position && player.position !== 'No Position' ? `<span class="roster-position">${player.position}</span>` : '';
    const badges = [];
    if (player.isCaptain) badges.push('<span class="badge badge-warning">C</span>');
    if (player.isViceCaptain) badges.push('<span class="badge badge-info">VC</span>');
    
    return `
      <div class="roster-card">
        <div class="roster-card-left">
          ${jersey}
          <div class="roster-card-info">
            <span class="roster-name">${player.name}</span>
            <span class="roster-detail">${isCoach ? player.position : (position || '')}</span>
          </div>
        </div>
        <div class="roster-card-right">
          ${badges.join(' ')}
        </div>
      </div>`;
  }
  
  // --- Standings Tab ---
  
  loadStandings() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) return;
    
    const container = this.find('#standings-content');
    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading standings...</p></div>';
    
    this.safeFetch(`/api/teams/${teamId}/standings`, response => {
      const data = response.data || {};
      this.standingsLoaded = true;
      this.renderStandings(data);
    });
  }
  
  renderStandings(data) {
    const container = this.find('#standings-content');
    const standings = data.standings || [];
    const currentTeamId = String(this.navigation.context.team?.id);
    
    if (!standings.length) {
      container.innerHTML = '<div class="empty-state"><p>No standings available</p><p class="text-muted">Standings will appear once matches are played</p></div>';
      return;
    }
    
    let html = `
      <div class="standings-wrapper">
        <div class="standings-header-info">
          <h3>${data.division_name || 'Division'}</h3>
          ${data.league_name ? `<span class="text-muted">${data.league_name}</span>` : ''}
        </div>
        <div class="standings-table-wrapper">
          <table class="standings-table">
            <thead>
              <tr>
                <th class="standings-pos">#</th>
                <th class="standings-team">Team</th>
                <th>P</th>
                <th>W</th>
                <th>D</th>
                <th>L</th>
                <th class="hide-mobile">GF</th>
                <th class="hide-mobile">GA</th>
                <th>GD</th>
                <th>Pts</th>
              </tr>
            </thead>
            <tbody>`;
    
    standings.forEach((s, i) => {
      const isCurrentTeam = String(s.team_id) === currentTeamId;
      const rowClass = isCurrentTeam ? 'standings-highlight' : '';
      
      html += `
              <tr class="${rowClass}">
                <td class="standings-pos">${s.position || (i + 1)}</td>
                <td class="standings-team">${s.team_name}</td>
                <td>${s.played}</td>
                <td>${s.wins}</td>
                <td>${s.draws}</td>
                <td>${s.losses}</td>
                <td class="hide-mobile">${s.goals_for}</td>
                <td class="hide-mobile">${s.goals_against}</td>
                <td>${s.goal_diff > 0 ? '+' : ''}${s.goal_diff}</td>
                <td class="standings-pts">${s.points}</td>
              </tr>`;
    });
    
    html += `
            </tbody>
          </table>
        </div>
      </div>`;
    
    container.innerHTML = html;
  }
  
  // --- Chat Tab ---
  
  loadChat() {
    const container = this.find('#chat-content');
    container.innerHTML = `
      <div class="empty-state">
        <p style="font-size:2rem;">💬</p>
        <p>Team Chat</p>
        <p class="text-muted">Coming soon — team messaging and event coordination</p>
        <div style="margin-top:var(--space-4);">
          <button data-action="practices" class="btn btn-primary btn-sm" style="width:auto;">
            ⚽ View Practices
          </button>
        </div>
      </div>`;
  }
}
