// GameDayRosterScreen - Coach selects players for game day roster
// Features Instagram-style match card header with share capability
class GameDayRosterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.matchDetails = null;
    this.selectedPlayerIds = new Set();
    this._listenersAttached = false;
  }

  render() {
    this._listenersAttached = false;
    
    const div = document.createElement('div');
    div.className = 'screen screen-game-day-roster';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Game Day Roster</h1>
      </div>
      
      <div class="gdr-container">
        <div id="roster-loading" class="gdr-loading">
          <div class="spinner"></div>
          <p>Loading...</p>
        </div>
        
        <div id="roster-content" style="display: none;">
          <!-- Match Card (Instagram-style, shareable) -->
          <div id="match-card-share" class="gdr-match-card">
            <div class="gdr-card-inner" id="gdr-card-inner">
              <div class="gdr-card-header">GAME DAY</div>
              <div class="gdr-card-logos">
                <div class="gdr-team gdr-team-home">
                  <div class="gdr-logo-wrap" id="gdr-home-logo"></div>
                  <div class="gdr-team-name" id="gdr-home-name">Home</div>
                </div>
                <div class="gdr-vs">VS</div>
                <div class="gdr-team gdr-team-away">
                  <div class="gdr-logo-wrap" id="gdr-away-logo"></div>
                  <div class="gdr-team-name" id="gdr-away-name">Away</div>
                </div>
              </div>
              <div class="gdr-card-details">
                <div class="gdr-detail" id="gdr-date">📅 —</div>
                <div class="gdr-detail" id="gdr-time">🕐 —</div>
                <div class="gdr-detail" id="gdr-venue">📍 —</div>
              </div>
              <div class="gdr-card-roster" id="gdr-card-roster" style="display:none;">
                <div class="gdr-roster-title">📋 Game Day Roster</div>
                <div class="gdr-roster-names" id="gdr-roster-names"></div>
              </div>
            </div>
            <div class="gdr-share-actions">
              <button id="share-card-btn" class="btn btn-secondary btn-sm">📸 Share Image</button>
              <button id="copy-text-btn" class="btn btn-secondary btn-sm">📋 Copy Text</button>
            </div>
          </div>

          <!-- Player Selection -->
          <div class="gdr-selection-header">
            <div id="selected-count" class="gdr-count-badge">0 / 20 selected</div>
            <button id="select-all-attending-btn" class="btn btn-secondary btn-sm">✓ Select All Attending</button>
          </div>
          
          <div id="player-list" class="gdr-player-list"></div>
          
          <div class="gdr-actions">
            <button id="save-roster-btn" class="btn btn-primary btn-lg" style="flex: 1;">💾 Save Game Day Roster</button>
          </div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    if (this._listenersAttached) return;
    this._listenersAttached = true;
    
    this.loadMatchAndPlayers();
    
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      const playerCard = e.target.closest('.player-select-card');
      if (playerCard) {
        this.togglePlayer(playerCard.getAttribute('data-player-id'));
        return;
      }
      if (e.target.id === 'save-roster-btn' || e.target.closest('#save-roster-btn')) {
        this.saveRoster();
        return;
      }
      if (e.target.id === 'select-all-attending-btn' || e.target.closest('#select-all-attending-btn')) {
        this.selectAllAttending();
        return;
      }
      if (e.target.id === 'share-card-btn' || e.target.closest('#share-card-btn')) {
        this.shareAsImage();
        return;
      }
      if (e.target.id === 'copy-text-btn' || e.target.closest('#copy-text-btn')) {
        this.copyAsText();
        return;
      }
    });
  }

  async loadMatchAndPlayers() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) {
      this.find('#roster-loading').innerHTML = '<p style="color:red;">No match selected</p>';
      return;
    }

    try {
      // Load match details and eligible players in parallel
      const [matchRes, playersRes] = await Promise.all([
        this.auth.fetch(`/api/matches/${matchId}`),
        this.auth.fetch(`/api/matches/${matchId}/eligible-players`)
      ]);
      const [matchData, playersData] = await Promise.all([matchRes.json(), playersRes.json()]);

      if (matchData.success) {
        this.matchDetails = matchData.data;
        this.renderMatchCard();
      }

      if (playersData.success) {
        this.players = playersData.data || [];
        this.selectedPlayerIds = new Set(
          this.players.filter(p => p.onGameRoster).map(p => p.playerId)
        );
      }

      this.find('#roster-loading').style.display = 'none';
      this.find('#roster-content').style.display = 'block';
      this.renderPlayers();
      this.updateSelectedCount();
    } catch (error) {
      console.error('Error loading:', error);
      this.find('#roster-loading').innerHTML = `<p style="color:red;">❌ ${error.message}</p>`;
    }
  }

  renderMatchCard() {
    const m = this.matchDetails;
    if (!m) return;

    const homeLogo = this.find('#gdr-home-logo');
    const awayLogo = this.find('#gdr-away-logo');
    if (m.home_team_logo) {
      homeLogo.innerHTML = `<img src="${m.home_team_logo}" alt="Home">`;
    } else {
      homeLogo.innerHTML = `<div class="gdr-logo-placeholder">🏠</div>`;
    }
    if (m.away_team_logo) {
      awayLogo.innerHTML = `<img src="${m.away_team_logo}" alt="Away">`;
    } else {
      awayLogo.innerHTML = `<div class="gdr-logo-placeholder">🏟️</div>`;
    }

    this.find('#gdr-home-name').textContent = m.home_team_name || 'Home';
    this.find('#gdr-away-name').textContent = m.away_team_name || 'Away';

    if (m.event_date) {
      const d = new Date(m.event_date);
      this.find('#gdr-date').textContent = '📅 ' + d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
      this.find('#gdr-time').textContent = '🕐 ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
    if (m.venue_name) {
      this.find('#gdr-venue').textContent = '📍 ' + m.venue_name;
    }
  }
  
  renderPlayers() {
    const container = this.find('#player-list');
    if (this.players.length === 0) {
      container.innerHTML = '<div class="empty-state"><p>No eligible players found</p></div>';
      return;
    }
    
    const attending = this.players.filter(p => p.rsvpStatus === 'yes');
    const maybe = this.players.filter(p => p.rsvpStatus === 'maybe');
    const notResponded = this.players.filter(p => !p.rsvpStatus);
    const notAttending = this.players.filter(p => p.rsvpStatus === 'no');
    
    let html = '';
    const renderGroup = (label, cls, players) => {
      if (players.length === 0) return '';
      return `<div class="gdr-group-header ${cls}">${label} (${players.length})</div>` +
        players.map(p => this.renderPlayerCard(p)).join('');
    };

    html += renderGroup('✓ Attending', 'gdr-group-yes', attending);
    html += renderGroup('? Maybe', 'gdr-group-maybe', maybe);
    html += renderGroup('— No Response', 'gdr-group-none', notResponded);
    html += renderGroup('✗ Not Attending', 'gdr-group-no', notAttending);
    
    container.innerHTML = html;
  }
  
  renderPlayerCard(player) {
    const isSelected = this.selectedPlayerIds.has(player.playerId);
    const jerseyDisplay = player.jerseyNumber ? `#${player.jerseyNumber}` : '';
    const positionDisplay = player.position || '';
    const initial = player.firstName ? player.firstName[0] : '?';
    
    return `
      <div class="player-select-card ${isSelected ? 'selected' : ''}" data-player-id="${player.playerId}">
        <div class="psc-avatar ${isSelected ? 'psc-avatar-selected' : ''}">
          ${isSelected ? '✓' : initial}
        </div>
        <div class="psc-info">
          <div class="psc-name">${player.firstName} ${player.lastName}</div>
          <div class="psc-detail">${[jerseyDisplay, positionDisplay].filter(Boolean).join(' · ') || '—'}</div>
        </div>
        <div class="psc-check">${isSelected ? '☑️' : '☐'}</div>
      </div>
    `;
  }
  
  togglePlayer(playerId) {
    if (this.selectedPlayerIds.has(playerId)) {
      this.selectedPlayerIds.delete(playerId);
    } else {
      this.selectedPlayerIds.add(playerId);
    }
    this.renderPlayers();
    this.updateSelectedCount();
    this.updateCardRoster();
  }
  
  selectAllAttending() {
    this.players.filter(p => p.rsvpStatus === 'yes').forEach(p => this.selectedPlayerIds.add(p.playerId));
    this.renderPlayers();
    this.updateSelectedCount();
    this.updateCardRoster();
  }
  
  updateSelectedCount() {
    const countEl = this.find('#selected-count');
    const count = this.selectedPlayerIds.size;
    countEl.textContent = `${count} / 20 selected`;
    countEl.className = 'gdr-count-badge' + (count > 20 ? ' gdr-count-over' : count >= 18 ? ' gdr-count-good' : '');
  }

  updateCardRoster() {
    const rosterSection = this.find('#gdr-card-roster');
    const namesEl = this.find('#gdr-roster-names');
    if (!rosterSection || !namesEl) return;

    if (this.selectedPlayerIds.size === 0) {
      rosterSection.style.display = 'none';
      return;
    }

    rosterSection.style.display = 'block';
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    namesEl.innerHTML = selected.map(p => {
      const jersey = p.jerseyNumber ? `#${p.jerseyNumber} ` : '';
      return `<span class="gdr-roster-chip">${jersey}${p.firstName} ${p.lastName}</span>`;
    }).join('');
  }

  async shareAsImage() {
    const card = this.find('#gdr-card-inner');
    if (!card || typeof html2canvas === 'undefined') {
      alert('Image sharing not available');
      return;
    }
    try {
      this.updateCardRoster();
      const canvas = await html2canvas(card, { backgroundColor: null, scale: 2 });
      const link = document.createElement('a');
      link.download = 'game-day-roster.png';
      link.href = canvas.toDataURL('image/png');
      link.click();
    } catch (err) {
      console.error('Share error:', err);
      alert('Failed to generate image');
    }
  }

  copyAsText() {
    const m = this.matchDetails || {};
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    const d = m.event_date ? new Date(m.event_date) : null;

    let text = `⚽ GAME DAY\n`;
    text += `${m.home_team_name || 'Home'} vs ${m.away_team_name || 'Away'}\n`;
    if (d) text += `📅 ${d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}\n`;
    if (d) text += `🕐 ${d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}\n`;
    if (m.venue_name) text += `📍 ${m.venue_name}\n`;
    text += `\n📋 Game Day Roster (${selected.length}):\n`;
    selected.forEach((p, i) => {
      const jersey = p.jerseyNumber ? `#${p.jerseyNumber} ` : '';
      text += `${i + 1}. ${jersey}${p.firstName} ${p.lastName}\n`;
    });

    navigator.clipboard.writeText(text).then(() => {
      alert('✓ Copied to clipboard!');
    }).catch(() => {
      // Fallback
      const ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      alert('✓ Copied to clipboard!');
    });
  }

  async saveRoster() {
    const matchId = this.navigation.context.match?.id;
    const userId = this.auth.getUser()?.id;
    if (!matchId) { alert('No match selected'); return; }
    
    const playerIds = Array.from(this.selectedPlayerIds);
    
    try {
      const response = await this.auth.fetch(`/api/matches/${matchId}/game-roster`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ player_ids: playerIds, added_by: userId })
      });
      const data = await response.json();
      if (data.success) {
        alert(`✓ Game day roster saved! ${data.count} players.`);
      } else {
        throw new Error(data.message || 'Failed to save');
      }
    } catch (error) {
      console.error('Error saving roster:', error);
      alert('Failed to save: ' + error.message);
    }
  }
}
