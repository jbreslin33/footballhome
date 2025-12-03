// MatchFormScreen - create or edit a match
class MatchFormScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.mode = 'create'; // 'create' or 'edit'
    this.matchId = null;
    this.teams = [];
  }
  
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-match-form';
    div.innerHTML = `
      <div class="screen-header">
        <h1 id="form-title">🏆 Create Match</h1>
        <p class="subtitle">Fill in the match details below</p>
      </div>
      
      <div class="card" style="max-width: 600px; margin: var(--space-4) auto;">
        <form id="match-form">
          <div class="form-group">
            <label for="title" class="form-label">Match Title *</label>
            <input type="text" id="title" name="title" class="form-input" required 
                   placeholder="e.g., League Match vs Eagles FC">
          </div>
          
          <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-3);">
            <div class="form-group">
              <label for="date" class="form-label">Date *</label>
              <input type="date" id="date" name="date" class="form-input" required>
            </div>
            
            <div class="form-group">
              <label for="time" class="form-label">Kick-off Time *</label>
              <input type="time" id="time" name="time" class="form-input" required>
            </div>
          </div>
          
          <div class="form-group">
            <label for="home_away" class="form-label">Home / Away *</label>
            <select id="home_away" name="home_away" class="form-input" required>
              <option value="home">Home</option>
              <option value="away">Away</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="opponent_team_id" class="form-label">Opponent Team *</label>
            <select id="opponent_team_id" name="opponent_team_id" class="form-input" required>
              <option value="">Select opponent...</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="venue_id" class="form-label">Venue</label>
            <select id="venue_id" name="venue_id" class="form-input">
              <option value="">Select a venue...</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="competition_name" class="form-label">Competition / League</label>
            <input type="text" id="competition_name" name="competition_name" class="form-input" 
                   placeholder="e.g., Premier League, Cup Semi-Final">
          </div>
          
          <div class="form-group">
            <label for="match_status" class="form-label">Match Status</label>
            <select id="match_status" name="match_status" class="form-input">
              <option value="scheduled">Scheduled</option>
              <option value="in_progress">In Progress</option>
              <option value="completed">Completed</option>
              <option value="postponed">Postponed</option>
            </select>
          </div>
          
          <div id="score-fields" style="display: none;">
            <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-3);">
              <div class="form-group">
                <label for="home_team_score" class="form-label">Home Score</label>
                <input type="number" id="home_team_score" name="home_team_score" class="form-input" min="0">
              </div>
              
              <div class="form-group">
                <label for="away_team_score" class="form-label">Away Score</label>
                <input type="number" id="away_team_score" name="away_team_score" class="form-input" min="0">
              </div>
            </div>
          </div>
          
          <div class="form-group">
            <label for="notes" class="form-label">Notes</label>
            <textarea id="notes" name="notes" class="form-input" rows="3"
                      placeholder="Any additional details about this match..."></textarea>
          </div>
          
          <div style="display: flex; gap: var(--space-3); margin-top: var(--space-6);">
            <button type="button" id="cancel-btn" class="btn btn-secondary" style="flex: 1;">Cancel</button>
            <button type="submit" id="submit-btn" class="btn btn-primary" style="flex: 2;">Create Match</button>
          </div>
        </form>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.mode = params.mode || 'create';
    this.matchId = params.matchId || null;
    
    // Show/hide score fields based on status
    const statusSelect = this.find('#match_status');
    const scoreFields = this.find('#score-fields');
    statusSelect.addEventListener('change', () => {
      scoreFields.style.display = statusSelect.value === 'completed' ? 'block' : 'none';
    });
    
    // Update UI based on mode
    if (this.mode === 'edit') {
      this.find('#form-title').textContent = '🏆 Edit Match';
      this.find('#submit-btn').textContent = 'Save Changes';
      // Load venues and teams first, then load match data
      Promise.all([
        this.loadVenues(),
        this.loadTeams()
      ]).then(() => {
        this.loadMatch(this.matchId);
      });
    } else {
      // For create mode, just load venues and teams
      this.loadVenues();
      this.loadTeams();
      // Set today as default date for new matches
      const today = new Date().toISOString().split('T')[0];
      this.find('#date').value = today;
      this.find('#time').value = '15:00'; // Default 3 PM kick-off
    }
    
    // Handle form submission
    const form = this.find('#match-form');
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      
      const formData = new FormData(e.target);
      const homeAway = formData.get('home_away');
      const myTeamId = this.navigation.context.team.id;
      const opponentId = formData.get('opponent_team_id');
      
      const match = {
        team_id: myTeamId,
        home_team_id: homeAway === 'home' ? myTeamId : opponentId,
        away_team_id: homeAway === 'away' ? myTeamId : opponentId,
        title: formData.get('title'),
        date: formData.get('date'),
        start_time: formData.get('time'),
        venue_id: formData.get('venue_id') || null,
        competition_name: formData.get('competition_name') || null,
        match_status: formData.get('match_status'),
        home_team_score: formData.get('home_team_score') || null,
        away_team_score: formData.get('away_team_score') || null,
        notes: formData.get('notes') || null
      };
      
      if (this.mode === 'create') {
        this.createMatch(match);
      } else {
        this.updateMatch(this.matchId, match);
      }
    });
    
    // Handle cancel
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'cancel-btn' || e.target.closest('#cancel-btn')) {
        this.navigation.goBack();
      }
    });
  }
  
  loadVenues() {
    return new Promise((resolve) => {
      this.safeFetch('/api/venues', response => {
        const venues = response.data || [];
        const select = this.find('#venue_id');
        
        select.innerHTML = '<option value="">Select a venue...</option>';
        
        venues.forEach(venue => {
          const option = document.createElement('option');
          option.value = venue.id;
          option.textContent = `${venue.name}${venue.city ? ' - ' + venue.city : ''}`;
          select.appendChild(option);
        });
        
        resolve();
      });
    });
  }
  
  loadTeams() {
    return new Promise((resolve) => {
      this.safeFetch('/api/teams', response => {
        const teams = response.data || [];
        this.teams = teams;
        const select = this.find('#opponent_team_id');
        const myTeamId = this.navigation.context.team?.id;
        
        select.innerHTML = '<option value="">Select opponent...</option>';
        
        // Filter out current team
        teams
          .filter(team => team.id !== myTeamId)
          .forEach(team => {
            const option = document.createElement('option');
            option.value = team.id;
            option.textContent = team.name;
            select.appendChild(option);
          });
        
        resolve();
      });
    });
  }
  
  loadMatch(matchId) {
    this.safeFetch(`/api/matches/${matchId}`, response => {
      const match = response.data || response;
      const myTeamId = this.navigation.context.team?.id;
      
      this.find('#title').value = match.title || '';
      
      // Parse date and time from event_date
      if (match.event_date) {
        const eventDate = new Date(match.event_date);
        this.find('#date').value = eventDate.toISOString().split('T')[0];
        this.find('#time').value = eventDate.toTimeString().slice(0, 5);
      }
      
      // Determine home/away and opponent
      if (match.home_team_id === myTeamId) {
        this.find('#home_away').value = 'home';
        this.find('#opponent_team_id').value = match.away_team_id || '';
      } else {
        this.find('#home_away').value = 'away';
        this.find('#opponent_team_id').value = match.home_team_id || '';
      }
      
      this.find('#venue_id').value = match.venue_id || '';
      this.find('#competition_name').value = match.competition_name || '';
      this.find('#match_status').value = match.match_status || 'scheduled';
      
      // Show scores if completed
      if (match.match_status === 'completed') {
        this.find('#score-fields').style.display = 'block';
        this.find('#home_team_score').value = match.home_team_score || '';
        this.find('#away_team_score').value = match.away_team_score || '';
      }
      
      this.find('#notes').value = match.notes || '';
    });
  }
  
  createMatch(match) {
    this.auth.fetch('/api/matches', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(match)
    })
    .then(r => {
      if (!r.ok) throw new Error('Failed to create match');
      return r.json();
    })
    .then(() => {
      console.log('Match created successfully');
      this.navigation.goBack(); // Back to management screen
    })
    .catch(err => {
      this.handleError(err, 'create');
    });
  }
  
  updateMatch(matchId, match) {
    this.auth.fetch(`/api/matches/${matchId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(match)
    })
    .then(r => {
      if (!r.ok) throw new Error('Failed to update match');
      return r.json();
    })
    .then(() => {
      console.log('Match updated successfully');
      this.navigation.goBack(); // Back to management screen
    })
    .catch(err => {
      this.handleError(err, 'update');
    });
  }
}
