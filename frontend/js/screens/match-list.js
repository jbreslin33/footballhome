// MatchListScreen - view matches and RSVP
class MatchListScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-match-list';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">
          ← Back
        </button>
        <h1>🏆 Match Schedule</h1>
        <p class="subtitle">Tap a button to RSVP</p>
      </div>
      
      <div id="match-list" class="match-cards"></div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadMatches();
    
    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Stats button
      const statsBtn = e.target.closest('[data-action="stats"]');
      if (statsBtn) {
        const matchId = statsBtn.getAttribute('data-id');
        const matchTitle = statsBtn.getAttribute('data-title');
        
        this.navigation.goTo('match-detail', { 
          matchId: matchId,
          matchTitle: matchTitle
        });
        return;
      }
      
      // Tactics button
      const tacticsBtn = e.target.closest('[data-action="tactics"]');
      if (tacticsBtn) {
        const matchId = tacticsBtn.getAttribute('data-id');
        const matchTitle = tacticsBtn.getAttribute('data-title');
        const team = this.navigation.context.team;
        
        this.navigation.goTo('tactical-board', { 
          matchId: matchId,
          matchTitle: matchTitle,
          team: team
        });
        return;
      }
      
      // RSVP buttons
      const rsvpBtn = e.target.closest('[data-action="rsvp"]');
      if (rsvpBtn) {
        const matchId = rsvpBtn.getAttribute('data-id');
        const status = rsvpBtn.getAttribute('data-status');
        this.handleRSVP(matchId, status);
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
    
    this.safeFetch(`/api/matches/team/${teamId}`, response => {
      // Extract matches from standardized response format
      const matches = response.data || [];
      
      // Load RSVP status for each match
      this.loadMatchesWithRSVP(matches);
    });
  }
  
  async loadMatchesWithRSVP(matches) {
    const userId = this.auth.getUser()?.id;
    const roleType = this.navigation.context.role; // 'coach', 'player', or 'parent'
    
    console.log('Loading matches with RSVP for:', { userId, roleType });
    
    if (!userId || !roleType) {
      console.error('Missing user ID or role type');
      this.renderMatches(matches);
      return;
    }
    
    // Fetch RSVP status for each match
    const matchesWithRSVP = await Promise.all(
      matches.map(async (match) => {
        try {
          const response = await this.auth.fetch(`/api/events/${match.id}/rsvps?role_type=${roleType}`);
          const data = await response.json();
          
          console.log(`RSVPs for match ${match.id}:`, data);
          
          if (data.success && data.data) {
            // Find current user's RSVP
            const userRsvp = data.data.find(rsvp => rsvp.user_id === userId);
            match.userRsvpStatus = userRsvp ? userRsvp.status : null;
            match.rsvpCount = data.data.length;
            
            console.log(`Match ${match.id} - User RSVP status:`, match.userRsvpStatus);
          }
        } catch (err) {
          console.error(`Failed to load RSVP for match ${match.id}:`, err);
        }
        return match;
      })
    );
    
    this.renderMatches(matchesWithRSVP);
  }
  
  renderMatches(matches) {
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
      
      return {
        ...m,
        dateDisplay: dateDisplay,
        time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
    });
    
    this.renderList('#match-list', transformedMatches,
      m => {
        // Determine current RSVP status styling
        console.log(`Rendering match ${m.id} with RSVP status: "${m.userRsvpStatus}"`);
        const attendingClass = m.userRsvpStatus === 'attending' ? 'btn-success' : 'btn-secondary';
        const notAttendingClass = m.userRsvpStatus === 'not_attending' ? 'btn-danger' : 'btn-secondary';
        console.log(`Classes: attending=${attendingClass}, notAttending=${notAttendingClass}`);
        
        // Display score for completed matches
        const scoreDisplay = (m.home_team_score !== null && m.home_team_score !== undefined) && (m.away_team_score !== null && m.away_team_score !== undefined)
          ? `<div class="match-score">
              <span class="score">${m.home_team_score} - ${m.away_team_score}</span>
              <span class="status-badge ${m.match_status}">${m.match_status}</span>
            </div>`
          : '';
        
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
              ${m.rsvpCount ? `<span class="badge">${m.rsvpCount} responses</span>` : ''}
            </div>
            
            ${scoreDisplay}
            
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
            
                        <div class="match-card-actions">
              <button 
                data-action="rsvp" 
                data-id="${m.id}" 
                data-status="attending"
                class="btn ${attendingClass}">
                ✓ Attending
              </button>
              <button 
                data-action="rsvp" 
                data-id="${m.id}" 
                data-status="not_attending"
                class="btn ${notAttendingClass}">
                ✗ Can't Make It
              </button>
            </div>
            
            <div class="match-card-actions" style="margin-top: var(--space-2); border-top: 1px solid var(--border-color); padding-top: var(--space-2); display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-2);">
              <button 
                data-action="stats" 
                data-id="${m.id}" 
                data-title="${m.title}"
                class="btn btn-secondary">
                📊 View Stats
              </button>
              <button 
                data-action="tactics" 
                data-id="${m.id}" 
                data-title="${m.title}"
                class="btn btn-secondary">
                📋 Tactics
              </button>
            </div>
          </div>
        `;
      },
      '<div class="empty-state"><p>🏆 No matches scheduled yet</p><p class="text-muted">Check back later</p></div>'
    );
  }
  
  onEnter(params) {
    this.loadMatches();
    
    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Tactics button
      const tacticsBtn = e.target.closest('[data-action="tactics"]');
      if (tacticsBtn) {
        const matchId = tacticsBtn.getAttribute('data-id');
        const matchTitle = tacticsBtn.getAttribute('data-title');
        const team = this.navigation.context.team;
        
        this.navigation.goTo('tactical-board', { 
          matchId: matchId,
          matchTitle: matchTitle,
          team: team
        });
        return;
      }
      
      // RSVP buttons
      const rsvpBtn = e.target.closest('[data-action="rsvp"]');
      if (rsvpBtn) {
        const matchId = rsvpBtn.getAttribute('data-id');
        const status = rsvpBtn.getAttribute('data-status');
        this.handleRSVP(matchId, status);
      }
    });
  }
  
  handleRSVP(matchId, status) {
    const userId = this.auth.getUser()?.id;
    const roleType = this.navigation.context.role;
    
    if (!userId || !roleType) {
      console.error('Missing user ID or role type for RSVP');
      alert('Unable to record RSVP. Please log in again.');
      return;
    }
    
    console.log('Submitting match RSVP:', { matchId, userId, roleType, status });
    
    this.auth.fetch(`/api/events/${matchId}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        user_id: userId,
        role_type: roleType,
        status: status,
        notes: ''
      })
    })
    .then(r => {
      if (!r.ok) throw new Error('RSVP failed');
      return r.json();
    })
    .then((response) => {
      console.log('RSVP response:', response);
      console.log(`Match RSVP recorded: ${status}`);
      
      // Refresh list to show updated status
      this.loadMatches();
    })
    .catch(err => {
      console.error('Match RSVP error:', err);
      this.handleError(err, 'rsvp');
    });
  }
}
