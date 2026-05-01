// MatchSocialScreen - Social media calendar view
// Shows all upcoming matches + post statuses with links to relevant pages
class MatchSocialScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-match-social';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📱 Social Media Calendar</h1>
        <p class="subtitle">All upcoming posts across matches</p>
      </div>

      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <!-- Schedule template link -->
        <div class="card" style="margin-bottom: var(--space-4); padding: var(--space-3); display: flex; align-items: center; justify-content: space-between;">
          <div>
            <strong>⏱️ Auto-Schedule</strong>
            <span style="opacity: 0.7; margin-left: 8px;">Set default posting times for all matches</span>
          </div>
          <button id="schedule-settings-btn" class="btn btn-secondary">⚙️ Schedule Settings</button>
        </div>

        <!-- Calendar container -->
        <div id="calendar-container">
          <div class="loading-state"><div class="spinner"></div><p>Loading social calendar...</p></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.team = this.navigation.context.team;
    // Accept match from context if navigating from match-list social button
    this.highlightMatchId = this.navigation.context.match?.id || null;

    if (!this.team) {
      this.navigation.goBack();
      return;
    }

    this.loadCalendar();

    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }

      if (e.target.id === 'schedule-settings-btn' || e.target.closest('#schedule-settings-btn')) {
        this.navigation.goTo('social-schedule', { team: this.team });
        return;
      }

      // Navigate to relevant page links
      const link = e.target.closest('[data-nav]');
      if (link) {
        const screen = link.dataset.nav;
        const matchId = parseInt(link.dataset.matchId);
        const match = this.matchMap?.[matchId] || { id: matchId };

        // Set match context for target screens
        this.navigation.context.match = match;
        this.navigation.context.lineupTeamId = this.team?.id || '';

        if (screen === 'game-day-roster' || screen === 'game-day-lineup') {
          this.navigation.goTo(screen, { matchId });
        } else if (screen === 'match-form') {
          this.navigation.goTo(screen, { mode: 'edit', matchId });
        } else if (screen === 'match-list') {
          this.navigation.goTo(screen);
        }
        return;
      }

      // Apply schedule button
      const applyBtn = e.target.closest('[data-action="apply-schedule"]');
      if (applyBtn) {
        const matchId = applyBtn.dataset.matchId;
        this.applyScheduleToMatch(matchId);
        return;
      }
    });
  }

  loadCalendar() {
    const container = this.find('#calendar-container');
    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading social calendar...</p></div>';

    this.safeFetch(`/api/social/calendar/team/${this.team.id}`, response => {
      const rows = response.data || [];
      this.renderCalendar(rows);
    });
  }

  renderCalendar(rows) {
    const container = this.find('#calendar-container');
    container.innerHTML = '';

    if (rows.length === 0) {
      container.innerHTML = '<div class="empty-state"><p>📅 No upcoming matches found</p></div>';
      return;
    }

    // Group by match
    const matchGroups = new Map();
    this.matchMap = {};

    rows.forEach(row => {
      if (!matchGroups.has(row.match_id)) {
        matchGroups.set(row.match_id, {
          match: row,
          posts: []
        });
        this.matchMap[row.match_id] = {
          id: row.match_id,
          title: row.match_title || `${row.home_team_name || 'Home'} vs ${row.away_team_name || 'Away'}`,
          event_date: row.match_date && row.match_time ? `${row.match_date} ${row.match_time}` : row.match_date,
          match_date: row.match_date,
          match_time: row.match_time,
          home_team_name: row.home_team_name,
          away_team_name: row.away_team_name,
          home_team_logo: row.home_team_logo,
          away_team_logo: row.away_team_logo,
          venue_name: row.venue_name,
          home_score: row.home_score,
          away_score: row.away_score,
          match_status: row.match_status
        };
      }
      matchGroups.get(row.match_id).posts.push(row);
    });

    // Render each match as a card
    matchGroups.forEach((group, matchId) => {
      const m = group.match;
      const posts = group.posts;
      const isHighlighted = matchId === this.highlightMatchId;

      const matchTitle = m.match_title || `${m.home_team_name || 'TBD'} vs ${m.away_team_name || 'TBD'}`;
      const dateStr = this.formatMatchDate(m.match_date);
      const timeStr = m.match_time ? m.match_time.substring(0, 5) : '';

      const card = document.createElement('div');
      card.className = 'card';
      card.style.cssText = `margin-bottom: var(--space-4); padding: 0; overflow: hidden;${isHighlighted ? ' border: 2px solid #3b82f6;' : ''}`;

      // Match header
      let headerHtml = `
        <div style="background: var(--surface-color); padding: var(--space-3) var(--space-4); border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;">
          <div>
            <strong style="font-size: 1.1em;">${this.escapeHtml(matchTitle)}</strong>
            <div style="opacity: 0.6; font-size: 0.85em; margin-top: 2px;">
              📅 ${dateStr}${timeStr ? ` ⏰ ${timeStr}` : ''}${m.venue_name ? ` 📍 ${this.escapeHtml(m.venue_name)}` : ''}
            </div>
          </div>
          <button class="btn btn-secondary btn-sm" data-action="apply-schedule" data-match-id="${matchId}" style="font-size: 0.8em;">
            📅 Apply Schedule
          </button>
        </div>
      `;

      // Post rows
      let postsHtml = '<div style="padding: var(--space-3) var(--space-4);">';

      const typeConfig = {
        pre_match_announcement: { icon: '📢', color: '#3b82f6', nav: 'match-list', label: 'Match List' },
        game_day:               { icon: '⚽', color: '#f59e0b', nav: 'game-day-roster', label: 'Game Day Roster' },
        lineup:                 { icon: '📋', color: '#8b5cf6', nav: 'game-day-lineup', label: 'Lineup Page' },
        post_game:              { icon: '🏆', color: '#22c55e', nav: 'match-form', label: 'Match Form' }
      };

      posts.forEach(post => {
        const cfg = typeConfig[post.post_type] || { icon: '📱', color: '#6b7280', nav: '', label: '' };
        const status = post.post_status;
        const hasPost = post.post_id !== null;

        let statusBadge = '';
        if (status === 'posted') {
          statusBadge = '<span style="background:#22c55e;color:white;padding:2px 8px;border-radius:12px;font-size:0.75em;">✅ Posted</span>';
        } else if (status === 'scheduled') {
          const schedDate = this.formatShortDate(post.scheduled_at);
          statusBadge = `<span style="background:#f59e0b;color:white;padding:2px 8px;border-radius:12px;font-size:0.75em;">📅 ${schedDate}</span>`;
        } else if (status === 'publishing') {
          statusBadge = '<span style="background:#3b82f6;color:white;padding:2px 8px;border-radius:12px;font-size:0.75em;">⏳ Publishing</span>';
        } else if (hasPost) {
          statusBadge = '<span style="background:#6b7280;color:white;padding:2px 8px;border-radius:12px;font-size:0.75em;">Draft</span>';
        } else {
          statusBadge = '<span style="background:#374151;color:#9ca3af;padding:2px 8px;border-radius:12px;font-size:0.75em;">—</span>';
        }

        const navLink = cfg.nav
          ? `<a href="#" data-nav="${cfg.nav}" data-match-id="${matchId}" style="color: ${cfg.color}; text-decoration: none; font-size: 0.8em; white-space: nowrap;">→ ${cfg.label}</a>`
          : '';

        postsHtml += `
          <div style="display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--border-color, #333);">
            <span style="font-size: 1.1em; width: 28px; text-align: center;">${cfg.icon}</span>
            <span style="flex: 1; font-size: 0.9em; font-weight: 500; border-left: 3px solid ${cfg.color}; padding-left: 8px;">${this.escapeHtml(post.display_name)}</span>
            <span style="min-width: 90px; text-align: center;">${statusBadge}</span>
            <span style="min-width: 110px; text-align: right;">${navLink}</span>
          </div>
        `;
      });

      postsHtml += '</div>';

      card.innerHTML = headerHtml + postsHtml;
      container.appendChild(card);
    });
  }

  applyScheduleToMatch(matchId) {
    if (!confirm('Apply your team schedule template to this match?')) return;

    this.auth.fetch(`/api/social/schedule/apply/${matchId}/${this.team.id}`, {
      method: 'POST'
    }).then(r => r.json()).then(data => {
      if (data.success) {
        alert(data.message);
        this.loadCalendar();
      } else {
        alert('Failed: ' + data.message);
      }
    });
  }

  formatMatchDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr + 'T12:00:00');
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    if (d.toDateString() === today.toDateString()) return 'Today';
    if (d.toDateString() === tomorrow.toDateString()) return 'Tomorrow';

    return d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
  }

  formatShortDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
