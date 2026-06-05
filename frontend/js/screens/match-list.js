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

      <div id="groupme-sync-status" class="groupme-sync-status" style="display: none;"></div>
      <div id="leagues-sync-status"></div>
      
      <div id="match-list" class="match-cards"></div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadMatches();
    this.loadSyncStatus();
    
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

      // Social button - opens calendar view with this match highlighted
      const socialBtn = e.target.closest('[data-action="social"]');
      if (socialBtn) {
        const matchId = socialBtn.getAttribute('data-id');
        const match = this.currentMatches?.find(m => String(m.id) === String(matchId));
        this.navigation.context.match = match || { id: parseInt(matchId), title: socialBtn.getAttribute('data-title') };
        this.navigation.goTo('match-social', {
          team: this.navigation.context.team
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

    // Resolve which match the team's public views currently point at.
    this.auth.fetch(`/api/teams/${teamId}/share-info`)
      .then(r => r.ok ? r.json() : null)
      .then(j => {
        this._liveMatchId = (j && j.data && j.data.live_match_id) ? j.data.live_match_id : null;
        this._livePinned  = !!(j && j.data && j.data.live_match_pinned);
      })
      .catch(() => { this._liveMatchId = null; });

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
    // Store for social button lookups
    this.currentMatches = matches;

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
        
        const homeLogo = this.buildTeamLogoMarkup(m.home_team_logo, { alt: 'Home Team', placeholder: '🏠' });
        const awayLogo = this.buildTeamLogoMarkup(m.away_team_logo, { alt: 'Away Team', placeholder: '✈️' });
        
        return `
          <div class="card match-card">
            <div class="match-logos">
              ${homeLogo}
              <span class="match-vs">VS</span>
              ${awayLogo}
            </div>
            <div class="match-card-header" style="text-align: center; justify-content: center; flex-direction: column; gap: var(--space-2);">
              <h3>${this._liveMatchId && m.id == this._liveMatchId ? `<span style="display:inline-block;background:#ffd166;color:#0d1b2a;font-size:10px;font-weight:800;padding:2px 6px;border-radius:4px;margin-right:6px;letter-spacing:0.5px;vertical-align:middle;">${this._livePinned ? '📌 ' : ''}📍 LIVE</span>` : ''}${m.title}</h3>
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
            
            <div class="match-card-actions" style="margin-top: var(--space-2); border-top: 1px solid var(--border-color); padding-top: var(--space-2); display: grid; grid-template-columns: 1fr 1fr 1fr; gap: var(--space-2);">
              <button 
                data-action="stats" 
                data-id="${m.id}" 
                data-title="${m.title}"
                class="btn btn-secondary">
                📊 Stats
              </button>
              <button 
                data-action="tactics" 
                data-id="${m.id}" 
                data-title="${m.title}"
                class="btn btn-secondary">
                📋 Tactics
              </button>
              <button 
                data-action="social" 
                data-id="${m.id}" 
                data-title="${m.title}"
                class="btn btn-secondary">
                📱 Social
              </button>
            </div>
          </div>
        `;
      },
      '<div class="empty-state"><p>🏆 No matches scheduled yet</p><p class="text-muted">Check back later</p></div>'
    );
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

  async loadSyncStatus() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) return;

    const banner = this.find('#groupme-sync-status');
    const leaguesBanner = this.find('#leagues-sync-status');

    try {
      const response = await this.auth.fetch(`/api/groupme/leagues-sync-status/${teamId}`);
      const result = await response.json();
      if (!result.success || !result.data) return;

      const { groupme, scrape } = result.data;

      // ── GroupMe match chat (chat_type=1) ────────────────────────────
      const matchChat = groupme.find(c => c.chatType === 1);
      if (matchChat?.lastSyncedAt && banner) {
        const d = new Date(matchChat.lastSyncedAt);
        const mins = Math.round((Date.now() - d) / 60000);
        const timeStr = d.toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
        let icon, level;
        if (mins <= 60)        { icon = '✅'; level = 'success'; }
        else if (mins <= 1440) { icon = '⏳'; level = 'warning'; }
        else                   { icon = '⚠️'; level = 'error'; }
        banner.className = `groupme-sync-status groupme-sync-${level}`;
        banner.innerHTML = `<span>${icon} GroupMe last synced: ${timeStr}</span>`;
        banner.style.display = 'block';
      }

      // ── Per-league scrape + training sync banners ────────────────────
      if (!leaguesBanner) return;

      // Map scrape keys → display info
      const leagueMap = {
        apsl: { label: 'APSL', keys: ['apsl-teams', 'apsl-standings'] },
        casa: { label: 'CASA', keys: ['casa-schedule', 'casa-rosters', 'casa-standings'] },
        csl:  { label: 'Liga 1 & 2', keys: ['csl-teams', 'csl-standings'] },
      };

      // Training/pickup GroupMe chat
      const trainingChat = groupme.find(c => c.chatType === 5);
      const pickupChat   = groupme.find(c => c.chatType === 3);
      const trainingSync = trainingChat?.lastSyncedAt || pickupChat?.lastSyncedAt;

      const rows = [];

      // Scrape rows per league
      for (const [key, info] of Object.entries(leagueMap)) {
        const timestamps = info.keys
          .map(k => scrape[k]?.updatedAt)
          .filter(Boolean)
          .map(t => new Date(t));
        if (!timestamps.length) continue;
        const latest = new Date(Math.max(...timestamps));
        const days = Math.round((Date.now() - latest) / 86400000);
        const icon = days <= 7 ? '✅' : days <= 14 ? '⏳' : '⚠️';
        const cls  = days <= 7 ? 'success' : days <= 14 ? 'warning' : 'error';
        const timeStr = latest.toLocaleString([], { month: 'short', day: 'numeric' });
        rows.push(`<div class="league-sync-row groupme-sync-${cls}">
          <span class="league-sync-label">${info.label}</span>
          <span class="league-sync-val">${icon} Schedule scraped: ${timeStr}</span>
        </div>`);
      }

      // Training GroupMe sync row
      if (trainingSync) {
        const d = new Date(trainingSync);
        const mins = Math.round((Date.now() - d) / 60000);
        const timeStr = d.toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
        const icon = mins <= 60 ? '✅' : mins <= 1440 ? '⏳' : '⚠️';
        const cls  = mins <= 60 ? 'success' : mins <= 1440 ? 'warning' : 'error';
        rows.push(`<div class="league-sync-row groupme-sync-${cls}">
          <span class="league-sync-label">Training</span>
          <span class="league-sync-val">${icon} GroupMe synced: ${timeStr}</span>
        </div>`);
      }

      if (rows.length) {
        leaguesBanner.innerHTML = `<div class="leagues-sync-grid">${rows.join('')}</div>`;
      }
    } catch (err) {
      console.warn('Failed to load sync status:', err.message);
    }
  }
}
